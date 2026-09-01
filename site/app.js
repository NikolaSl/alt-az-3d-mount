import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { STLLoader } from "three/addons/loaders/STLLoader.js";

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
let currentMesh;

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 5000);
camera.up.set(0, 0, 1);

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
viewerEl.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.target.set(0, 0, 0);

scene.add(new THREE.HemisphereLight(0xffffff, 0x253047, 2.0));
const keyLight = new THREE.DirectionalLight(0xffffff, 2.5);
keyLight.position.set(100, -120, 180);
scene.add(keyLight);

const grid = new THREE.GridHelper(240, 24, 0x59657a, 0x2d3748);
grid.rotation.x = Math.PI / 2;
grid.position.z = -0.02;
scene.add(grid);

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

function resizeViewer() {
  const width = Math.max(1, viewerEl.clientWidth);
  const height = Math.max(1, viewerEl.clientHeight);
  renderer.setSize(width, height, false);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
}

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
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
  const response = await fetch(new URL(`./repo-src/${file.path}`, import.meta.url));
  if (!response.ok) throw new Error(`Cannot load ${file.path}: HTTP ${response.status}`);
  const buffer = await response.arrayBuffer();
  const digest = await sha256Hex(buffer);
  if (digest !== file.sha256) {
    throw new Error(`SHA-256 mismatch for ${file.path}`);
  }
  return new Uint8Array(buffer);
}

async function loadOpenSCAD() {
  if (scad) return scad;
  if (scadLoading) return scadLoading;

  scadLoading = (async () => {
    setStatus("Loading OpenSCAD WebAssembly runtime… first load is about 13 MB.");
    const moduleUrl = new URL("./vendor/openscad.js", import.meta.url).href;
    const { default: OpenSCAD } = await import(moduleUrl);
    const instance = await OpenSCAD({
      noInitialRun: true,
      print: text => log(text),
      printErr: text => log(text, true)
    });

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

function selectedEntry() {
  return manifest.entries.find(entry => entry.path === modelSelect.value);
}

async function showSelectedSource() {
  const entry = selectedEntry();
  if (!entry) return;

  const file = manifest.files.find(item => item.path === entry.path);
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

function removeCurrentMesh() {
  if (!currentMesh) return;
  scene.remove(currentMesh);
  currentMesh.geometry.dispose();
  currentMesh.material.dispose();
  currentMesh = undefined;
}

function displayStl(bytes) {
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
      "--enable=manifold",
      "-o",
      output
    ]);

    if (exitCode !== 0) throw new Error(`OpenSCAD returned exit code ${exitCode}`);
    generatedStl = instance.FS.readFile(output);
    displayStl(generatedStl);
    downloadButton.disabled = false;
    setStatus(`Rendered ${entry.path} locally from repository commit ${manifest.commit.slice(0, 8)}.`);
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
  resizeViewer();
  animate();

  const response = await fetch(new URL("./scad-manifest.json", import.meta.url));
  if (!response.ok) throw new Error(`Cannot load manifest: HTTP ${response.status}`);
  manifest = await response.json();

  if (!manifest.entries.length) throw new Error("No renderable SCAD entry points were found.");
  for (const entry of manifest.entries) {
    const option = document.createElement("option");
    option.value = entry.path;
    option.textContent = entry.label || entry.path;
    modelSelect.appendChild(option);
  }

  modelSelect.addEventListener("change", () => showSelectedSource().catch(error => setStatus(error.message)));
  renderButton.addEventListener("click", renderSelected);
  downloadButton.addEventListener("click", downloadStl);
  window.addEventListener("resize", resizeViewer);

  await showSelectedSource();
}

init().catch(error => {
  log(error?.stack || String(error), true);
  setStatus(`Viewer initialization failed: ${error?.message || error}`);
});
