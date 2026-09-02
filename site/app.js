const modelSelect = document.querySelector('#modelSelect');
const renderButton = document.querySelector('#renderButton');
const cancelButton = document.querySelector('#cancelButton');
const downloadButton = document.querySelector('#downloadButton');
const sourceLink = document.querySelector('#sourceLink');
const statusEl = document.querySelector('#status');
const sourceCode = document.querySelector('#sourceCode');
const commitInfo = document.querySelector('#commitInfo');
const meshInfo = document.querySelector('#meshInfo');
const consoleLog = document.querySelector('#consoleLog');
const viewerEl = document.querySelector('#viewer');
const progressPanel = document.querySelector('#renderProgress');
const progressBar = document.querySelector('#progressBar');
const progressStage = document.querySelector('#progressStage');
const progressDetail = document.querySelector('#progressDetail');
const progressElapsed = document.querySelector('#progressElapsed');

let manifest;
let generatedStl;
let activeWorker;
let activeJobId = 0;
let renderStartedAt = 0;
let elapsedTimer;
let renderPhase = '';
let renderDetail = '';
let selectionSerial = 0;

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
  const line = `${isError ? 'ERR ' : ''}${text}`;
  consoleLog.textContent += `${line}\n`;
  consoleLog.scrollTop = consoleLog.scrollHeight;
}

function clearLog() {
  consoleLog.textContent = '';
}

function formatElapsed(ms) {
  const total = Math.max(0, Math.floor(ms / 1000));
  const minutes = Math.floor(total / 60);
  const seconds = total % 60;
  return `${minutes}:${String(seconds).padStart(2, '0')}`;
}

function setProgress({ phase, progress, detail }) {
  renderPhase = phase || renderPhase;
  renderDetail = detail || renderDetail;
  progressPanel.hidden = false;
  progressStage.textContent = renderPhase || 'Working';
  progressDetail.textContent = renderDetail || '';

  if (progress == null) {
    progressBar.removeAttribute('value');
  } else {
    progressBar.value = Math.max(0, Math.min(100, progress));
  }
}

function startElapsedClock() {
  stopElapsedClock();
  renderStartedAt = performance.now();
  const tick = () => {
    const elapsed = performance.now() - renderStartedAt;
    progressElapsed.textContent = formatElapsed(elapsed);
    if (activeWorker && renderPhase === 'render') {
      setStatus(`Rendering in background worker… ${formatElapsed(elapsed)} elapsed. The page remains usable; Cancel is available.`);
    }
  };
  tick();
  elapsedTimer = setInterval(tick, 1000);
}

function stopElapsedClock() {
  if (elapsedTimer) clearInterval(elapsedTimer);
  elapsedTimer = undefined;
}

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
}

async function fetchRepoFile(file) {
  const url = new URL(`./repo-src/${file.path}`, import.meta.url);
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) throw new Error(`Cannot load ${file.path}: HTTP ${response.status}`);
  const buffer = await response.arrayBuffer();
  const digest = await sha256Hex(buffer);
  if (digest !== file.sha256) throw new Error(`SHA-256 mismatch for ${file.path}`);
  return new Uint8Array(buffer);
}

async function loadManifest() {
  setStatus('Loading repository manifest…');
  const url = new URL('./scad-manifest.json', import.meta.url);
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) throw new Error(`Cannot load manifest: HTTP ${response.status}`);
  const data = await response.json();
  if (!Array.isArray(data.files) || !Array.isArray(data.entries)) {
    throw new Error('Invalid repository manifest format');
  }
  if (!data.entries.length) throw new Error('No renderable SCAD entry points were found.');
  manifest = data;
  log(`Manifest loaded: ${manifest.files.length} SCAD files, ${manifest.entries.length} entry point(s).`);
}

function selectedEntry() {
  return manifest?.entries.find(entry => entry.path === modelSelect.value);
}

function filesForEntry(entry) {
  const requested = Array.isArray(entry.dependencies) && entry.dependencies.length
    ? entry.dependencies
    : manifest.files.map(file => file.path);
  const wanted = new Set([entry.path, ...requested]);
  const files = manifest.files.filter(file => wanted.has(file.path));
  if (!files.some(file => file.path === entry.path)) {
    throw new Error(`Manifest has no source record for ${entry.path}`);
  }
  return files;
}

async function showSelectedSource() {
  const serial = ++selectionSerial;
  const entry = selectedEntry();
  if (!entry) return;

  if (activeWorker) cancelRender('Selection changed; previous background render cancelled.');

  const file = manifest.files.find(item => item.path === entry.path);
  if (!file) throw new Error(`Manifest entry ${entry.path} has no source file record`);

  setStatus(`Loading and verifying ${entry.path}…`);
  const bytes = await fetchRepoFile(file);
  if (serial !== selectionSerial) return;
  sourceCode.textContent = new TextDecoder().decode(bytes);

  const commit = manifest.commit;
  sourceLink.href = `https://github.com/${manifest.repository}/blob/${commit}/src/${entry.path}`;
  commitInfo.textContent = commit.slice(0, 8);
  generatedStl = undefined;
  downloadButton.disabled = true;
  meshInfo.textContent = 'not rendered';
  progressPanel.hidden = true;
  progressElapsed.textContent = '0:00';

  const dependencyCount = filesForEntry(entry).length;
  setStatus(`Selected ${entry.path}. Source verified; ${dependencyCount} required SCAD file(s). Press “Render in browser”.`);
}

async function loadViewerModules() {
  const threeUrl = new URL('./vendor/three/three.module.js', import.meta.url).href;
  const controlsUrl = new URL('./vendor/three/addons/controls/OrbitControls.js', import.meta.url).href;
  const loaderUrl = new URL('./vendor/three/addons/loaders/STLLoader.js', import.meta.url).href;

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
    setStatus('Loading 3D viewer modules…');
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
    log('Three.js 3D viewer initialized.');
  })().catch(error => {
    viewerLoading = undefined;
    throw error;
  });

  return viewerLoading;
}

function removeCurrentMesh() {
  if (!currentMesh || !scene) return;
  scene.remove(currentMesh);
  currentMesh.geometry.dispose();
  currentMesh.material.dispose();
  currentMesh = undefined;
}

function displayStl(bytes) {
  if (!viewerReady) throw new Error('3D viewer is not available');

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
  meshInfo.textContent = `${originalSize.x.toFixed(1)} × ${originalSize.y.toFixed(1)} × ${originalSize.z.toFixed(1)} mm · ${Math.round(triangles).toLocaleString()} triangles · browser WASM render`;
}

function finishWorker() {
  if (activeWorker) activeWorker.terminate();
  activeWorker = undefined;
  stopElapsedClock();
  renderButton.disabled = false;
  cancelButton.disabled = true;
}

function cancelRender(message = 'Background render cancelled.') {
  if (!activeWorker) return;
  finishWorker();
  setProgress({ phase: 'cancelled', progress: 0, detail: message });
  progressElapsed.textContent = formatElapsed(performance.now() - renderStartedAt);
  setStatus(message);
  log(message);
}

async function renderSelected() {
  const entry = selectedEntry();
  if (!entry) return;

  if (activeWorker) cancelRender('Previous render cancelled before starting a new one.');

  renderButton.disabled = true;
  cancelButton.disabled = false;
  downloadButton.disabled = true;
  clearLog();

  const jobId = ++activeJobId;
  const workerUrl = new URL(`./openscad-worker.js?v=${encodeURIComponent(manifest.commit)}`, import.meta.url);
  const worker = new Worker(workerUrl, { type: 'module', name: 'openscad-renderer' });
  activeWorker = worker;
  startElapsedClock();
  setProgress({
    phase: 'starting',
    progress: 2,
    detail: 'Starting background OpenSCAD worker. The UI will remain responsive.'
  });
  setStatus('Starting background OpenSCAD render…');

  const finishWithError = error => {
    if (worker !== activeWorker) return;
    const elapsed = performance.now() - renderStartedAt;
    finishWorker();
    setProgress({ phase: 'failed', progress: 0, detail: error?.message || String(error) });
    progressElapsed.textContent = formatElapsed(elapsed);
    log(error?.stack || String(error), true);
    setStatus(`Render failed: ${error?.message || error}`);
  };

  worker.onerror = event => {
    finishWithError(new Error(event.message || 'OpenSCAD worker crashed'));
  };

  worker.onmessage = async event => {
    const message = event.data || {};
    if (message.jobId !== jobId || worker !== activeWorker) return;

    if (message.type === 'stdout') {
      log(message.text);
      return;
    }
    if (message.type === 'stderr') {
      log(message.text, true);
      return;
    }
    if (message.type === 'phase') {
      setProgress({ phase: message.phase, progress: message.progress, detail: message.detail });
      if (message.phase !== 'render') setStatus(message.detail || message.phase);
      return;
    }
    if (message.type === 'error') {
      finishWithError(new Error(message.message || 'OpenSCAD worker failed'));
      return;
    }
    if (message.type === 'done') {
      const elapsed = message.elapsedMs ?? (performance.now() - renderStartedAt);
      const result = new Uint8Array(message.buffer);
      finishWorker();
      generatedStl = result;
      downloadButton.disabled = false;
      setProgress({ phase: 'display', progress: 97, detail: 'OpenSCAD finished. Preparing interactive 3D view…' });
      progressElapsed.textContent = formatElapsed(elapsed);

      try {
        await initViewer();
        displayStl(generatedStl);
        setProgress({ phase: 'done', progress: 100, detail: `Completed in ${formatElapsed(elapsed)}.` });
        setStatus(`Rendered ${entry.path} in a background worker in ${formatElapsed(elapsed)}.`);
      } catch (viewerError) {
        log(`3D display unavailable: ${viewerError.message}`, true);
        meshInfo.textContent = `${generatedStl.length.toLocaleString()} STL bytes generated`;
        setProgress({ phase: 'done', progress: 100, detail: `STL generated in ${formatElapsed(elapsed)}; 3D display failed.` });
        setStatus(`STL generated successfully, but 3D display is unavailable: ${viewerError.message}`);
      }
    }
  };

  try {
    const files = filesForEntry(entry);
    log(`Background render source closure: ${files.length}/${manifest.files.length} repository SCAD files.`);
    worker.postMessage({
      type: 'render',
      jobId,
      entryPath: entry.path,
      files,
      commit: manifest.commit
    });
  } catch (error) {
    finishWithError(error);
  }
}

function downloadStl() {
  if (!generatedStl) return;
  const entry = selectedEntry();
  const filename = entry.path.split('/').pop().replace(/\.scad$/i, '.stl');
  const blob = new Blob([generatedStl], { type: 'model/stl' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
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
    const option = document.createElement('option');
    option.value = entry.path;
    option.textContent = entry.label || entry.path;
    modelSelect.appendChild(option);
  }

  modelSelect.addEventListener('change', () => showSelectedSource().catch(error => {
    log(error?.stack || String(error), true);
    setStatus(`Source load failed: ${error.message}`);
  }));
  renderButton.addEventListener('click', renderSelected);
  cancelButton.addEventListener('click', () => cancelRender());
  downloadButton.addEventListener('click', downloadStl);
  window.addEventListener('resize', resizeViewer);
  window.addEventListener('beforeunload', () => {
    if (activeWorker) activeWorker.terminate();
  });

  await showSelectedSource();

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
