const modelSelect = document.querySelector("#modelSelect");
const renderButton = document.querySelector("#renderButton");
const downloadButton = document.querySelector("#downloadButton");
const sourceLink = document.querySelector("#sourceLink");
const statusEl = document.querySelector("#status");
const sourceCode = document.querySelector("#sourceCode");
const commitInfo = document.querySelector("#commitInfo");
const meshInfo = document.querySelector("#meshInfo");
const consoleLog = document.querySelector("#consoleLog");
const viewerEl = document.querySelector("#viewer");

let manifest;
let scad;
let scadLoading;
let generatedStl;

let THREE;
let OrbitControls;
let STLLoader;
let scene;
let camera;
let renderer;
let controls;
let grid;
let currentMesh;
let viewerReady = false;
let viewerLoading;

function setStatus(text) {
  statusEl.textContent = text;
}

function log(text, isError = false) {
  const line = `${isError ? "ERR " : ""}${text}`;
  consoleLog.textContent += `${line}\n`;
  consoleLog.scrollTop = consoleLog.scrollHeight;
}

function clearLog() {
  consoleLog.textContent = "";
}

function ensureDirectory(fs, path) {
  const parts = path.split("/").filter(Boolean);
  let current = "";
  for (const part of parts) {
    current += `/${part}`;
    try {
      fs.mkdir(current);
    } catch {
      // Directory already exists.
    }
  }
}

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, "0")).join("");
}

async function fetchRepoFile(file) {
  const url = new URL(`./repo-src/${file.path}`, import.meta.url);
  const response = await fetch(url, { cache: "no-store" });
  if (!response.ok) throw new Error(`Cannot load ${file.path}: HTTP ${response.status}`);
  const buffer = await response.arrayBuffer();
  const digest = await sha256Hex(buffer);
  if (digest !== file.sha256) {
    throw new Error(`SHA-256 mismatch for ${file.path}`);
  }
  return new Uint8Array(buffer);
}

async function loadManifest() {
  setStatus("Loading repository manifest…");
  const url = new URL("./scad-manifest.json", import.meta.url);
  const response = await fetch(url, { cache: "no-store" });
  if (!response.ok) throw new Error(`Cannot load manifest: HTTP ${response.status}`);
  const data = await response.json();
  if (!Array.isArray(data.files) || !Array.isArray(data.entries)) {
    throw new Error("Invalid repository manifest format");
  }
  if (!data.entries.length) throw new Error("No renderable SCAD entry points were found.");
  manifest = data;
  log(`Manifest loaded: ${manifest.files.length} SCAD files, ${manifest.entries.length} entry point(s).`);
}

function selectedEntry() {
  return manifest?.entries.find(entry => entry.path === modelSelect.value);
}

async function showSelectedSource() {
  const entry = selectedEntry();
  if (!entry) return;

  const file = manifest.files.find(item => item.path === entry.path);
  if (!file) throw new Error(`Manifest entry ${entry.path} has no source file record`);

  setStatus(`Loading and verifying ${entry.path}…`);
  const bytes = await fetchRepoFile(file);
  sourceCode.textContent = new TextDecoder().decode(bytes);

  const commit = manifest.commit;
  sourceLink.href = `https://github.com/${manifest.repository}/blob/${commit}/src/${entry.path}`;
  commitInfo.textContent = commit.slice(0, 8);
  generatedStl = undefined;
  downloadButton.disabled = true;
  meshInfo.textContent = "not rendered";
  setStatus(`Selected ${entry.path}. Source SHA-256 verified.`);
}

async function loadViewerModules() {
  const threeUrl = new URL("./vendor/three/three.module.js", import.meta.url).href;
  const controlsUrl = new URL("./vendor/three/addons/controls/OrbitControls.js", import.meta.url).href;
  const loaderUrl = new URL("./vendor/three/addons/loaders/STLLoader.js", import.meta.url).href;

  const [threeModule, controlsModule, loaderModule] = await Promise.all([
    import(threeUrl),
    import(controlsUrl),
    import(loaderUrl)
  ]);

  THREE = threeModule;
  OrbitControls = controlsModule.OrbitControls;
  STLLoader = loaderModule.STLLoader;
}

function resizeViewer() {
  if (!viewerReady || !renderer || !camera) return;
  const width = Math.max(1, viewerEl.clientWidth);
  const height = Math.max(1, viewerEl.clientHeight);
  renderer.setSize(width, height, false);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
}

function animate() {
  if (!viewerReady) return;
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

async function initViewer() {
  if (viewerReady) return;
  if (viewerLoading) return viewerLoading;

  viewerLoading = (async () => {
    setStatus("Loading 3D viewer modules…");
    await loadViewerModules();

    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(38, 1, 0.1, 5000);
    camera.up.set(0, 0, 1);

    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    viewerEl.replaceChildren(renderer.domElement);

    controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    controls.target.set(0, 0, 0);

    scene.add(new THREE.HemisphereLight(0xffffff, 0x253047, 2.0));
    const keyLight = new THREE.DirectionalLight(0xffffff, 2.5);
    keyLight.position.set(100, -120, 180);
    scene.add(keyLight);

    grid = new THREE.GridHelper(240, 24, 0x59657a, 0x2d3748);
    grid.rotation.x = Math.PI / 2;
    grid.position.z = -0.02;
    scene.add(grid);

    viewerReady = true;
    resizeViewer();
    animate();
    log("Three.js 3D viewer initialized.");
  })().catch(error => {
    viewerLoading = undefined;
    throw error;
  });

  return viewerLoading;
}

async function loadOpenSCAD() {
  if (scad) return scad;
  if (scadLoading) return scadLoading;

  scadLoading = (async () => {
    setStatus("Loading OpenSCAD WebAssembly runtime… first load is about 13 MB.");
    const moduleUrl = new URL("./vendor/openscad.js", import.meta.url).href;
    const wasmModule = await import(moduleUrl);
    if (typeof wasmModule.createOpenSCAD !== "function") {
      throw new Error("OpenSCAD WebAssembly module does not export createOpenSCAD()");
    }

    const api = await wasmModule.createOpenSCAD({
      print: text => log(text),
      printErr: text => log(text, true)
    });
    const instance = api.getInstance();
    if (!instance?.FS || typeof instance.callMain !== "function") {
      throw new Error("OpenSCAD WebAssembly runtime did not initialize correctly");
    }

    ensureDirectory(instance.FS, "/workspace/src");
    setStatus(`Verifying and mounting ${manifest.files.length} repository SCAD files…`);

    for (const file of manifest.files) {
      const bytes = await fetchRepoFile(file);
      const target = `/workspace/src/${file.path}`;
      const parent = target.slice(0, target.lastIndexOf("/"));
      ensureDirectory(instance.FS, parent);
      instance.FS.writeFile(target, bytes);
    }

    scad = instance;
    setStatus(`OpenSCAD ready. Source snapshot verified against commit ${manifest.commit.slice(0, 8)}.`);
    return instance;
  })().catch(error => {
    scadLoading = undefined;
    throw error;
  });

  return scadLoading;
}

function removeCurrentMesh() {
  if (!currentMesh || !scene) return;
  scene.remove(currentMesh);
  currentMesh.geometry.dispose();
  currentMesh.material.dispose();
  currentMesh = undefined;
}

function displayStl(bytes) {
  if (!viewerReady) throw new Error("3D viewer is not available");

  const exactBuffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
  const geometry = new STLLoader().parse(exactBuffer);
  geometry.computeVertexNormals();
  geometry.computeBoundingBox();

  const box = geometry.boundingBox;
  const originalSize = new THREE.Vector3();
  const center = new THREE.Vector3();
  box.getSize(originalSize);
  box.getCenter(center);
  geometry.translate(-center.x, -center.y, -center.z);
  geometry.computeBoundingBox();

  removeCurrentMesh();
  const material = new THREE.MeshStandardMaterial({
    color: 0xc9d1d9,
    roughness: 0.72,
    metalness: 0.05,
    side: THREE.DoubleSide
  });
  currentMesh = new THREE.Mesh(geometry, material);
  scene.add(currentMesh);

  const longest = Math.max(originalSize.x, originalSize.y, originalSize.z, 1);
  const distance = longest * 2.2;
  camera.near = Math.max(0.01, longest / 1000);
  camera.far = Math.max(5000, longest * 30);
  camera.position.set(distance * 0.75, -distance * 0.9, distance * 0.65);
  camera.updateProjectionMatrix();
  controls.target.set(0, 0, 0);
  controls.update();

  grid.scale.setScalar(Math.max(0.5, longest / 120));
  grid.position.z = -originalSize.z / 2;

  const triangles = geometry.attributes.position.count / 3;
  meshInfo.textContent = `${originalSize.x.toFixed(1)} × ${originalSize.y.toFixed(1)} × ${originalSize.z.toFixed(1)} mm · ${Math.round(triangles).toLocaleString()} triangles`;
}

async function renderSelected() {
  const entry = selectedEntry();
  if (!entry) return;

  renderButton.disabled = true;
  downloadButton.disabled = true;
  clearLog();

  try {
    const instance = await loadOpenSCAD();
    const output = "/output.stl";
    try { instance.FS.unlink(output); } catch { /* no previous output */ }

    setStatus(`Rendering ${entry.path} with OpenSCAD WebAssembly…`);
    const exitCode = instance.callMain([
      `/workspace/src/${entry.path}`,
      "-o",
      output
    ]);

    if (typeof exitCode === "number" && exitCode !== 0) {
      throw new Error(`OpenSCAD returned exit code ${exitCode}`);
    }

    generatedStl = instance.FS.readFile(output);
    if (!generatedStl?.length) throw new Error("OpenSCAD produced an empty STL file");
    downloadButton.disabled = false;

    try {
      await initViewer();
      displayStl(generatedStl);
      setStatus(`Rendered and displayed ${entry.path} from repository commit ${manifest.commit.slice(0, 8)}.`);
    } catch (viewerError) {
      log(`3D display unavailable: ${viewerError.message}`, true);
      meshInfo.textContent = `${generatedStl.length.toLocaleString()} STL bytes generated`;
      setStatus(`STL generated successfully, but 3D display is unavailable: ${viewerError.message}`);
    }
  } catch (error) {
    log(error?.stack || String(error), true);
    setStatus(`Render failed: ${error?.message || error}`);
  } finally {
    renderButton.disabled = false;
  }
}

function downloadStl() {
  if (!generatedStl) return;
  const entry = selectedEntry();
  const filename = entry.path.split("/").pop().replace(/\.scad$/i, ".stl");
  const blob = new Blob([generatedStl], { type: "model/stl" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

async function init() {
  await loadManifest();

  for (const entry of manifest.entries) {
    const option = document.createElement("option");
    option.value = entry.path;
    option.textContent = entry.label || entry.path;
    modelSelect.appendChild(option);
  }

  modelSelect.addEventListener("change", () => showSelectedSource().catch(error => {
    log(error?.stack || String(error), true);
    setStatus(`Source load failed: ${error.message}`);
  }));
  renderButton.addEventListener("click", renderSelected);
  downloadButton.addEventListener("click", downloadStl);
  window.addEventListener("resize", resizeViewer);

  await showSelectedSource();

  // Viewer initialization is deliberately after manifest/source loading.
  // This keeps repository files usable even in a browser/WebView where WebGL
  // or advanced module loading is unavailable.
  try {
    await initViewer();
    setStatus(`Ready. ${manifest.entries.length} renderable SCAD file(s) from commit ${manifest.commit.slice(0, 8)}.`);
  } catch (error) {
    log(`3D viewer initialization failed: ${error?.stack || error}`, true);
    setStatus(`Source loaded. 3D viewer unavailable: ${error?.message || error}`);
  }
}

init().catch(error => {
  log(error?.stack || String(error), true);
  setStatus(`Viewer initialization failed: ${error?.message || error}`);
});
