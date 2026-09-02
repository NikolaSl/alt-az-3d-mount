// OpenSCAD rendering worker.
// Heavy WASM compilation/rendering stays off the UI thread so mobile browsers
// remain responsive even for complex assemblies.

let currentJobId = null;

function send(type, payload = {}, transfer = []) {
  self.postMessage({ type, jobId: currentJobId, ...payload }, transfer);
}

function ensureDirectory(fs, path) {
  const parts = path.split('/').filter(Boolean);
  let current = '';
  for (const part of parts) {
    current += `/${part}`;
    try {
      fs.mkdir(current);
    } catch {
      // Already exists.
    }
  }
}

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
}

async function fetchVerifiedSource(file) {
  const url = new URL(`./repo-src/${file.path}`, self.location.href);
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) throw new Error(`Cannot load ${file.path}: HTTP ${response.status}`);
  const buffer = await response.arrayBuffer();
  const digest = await sha256Hex(buffer);
  if (digest !== file.sha256) throw new Error(`SHA-256 mismatch for ${file.path}`);
  return new Uint8Array(buffer);
}

async function loadOpenSCAD() {
  send('phase', {
    phase: 'runtime',
    progress: 8,
    detail: 'Loading OpenSCAD WebAssembly runtime in background worker…'
  });

  const moduleUrl = new URL('./vendor/openscad/openscad.js', self.location.href).href;
  const wasmModule = await import(moduleUrl);
  const OpenSCAD = wasmModule.default || wasmModule.OpenSCAD || wasmModule.createOpenSCAD;
  if (typeof OpenSCAD !== 'function') {
    throw new Error('OpenSCAD WebAssembly module has no supported factory export');
  }

  const options = {
    noInitialRun: true,
    print: text => send('stdout', { text: String(text) }),
    printErr: text => send('stderr', { text: String(text) }),
    locateFile: path => {
      if (path.endsWith('.wasm')) {
        return new URL(`./vendor/openscad/${path}`, self.location.href).href;
      }
      return path;
    }
  };

  // The pinned official Playground build exports the low-level factory directly.
  // Keep compatibility with wrapper-style builds that expose getInstance().
  const created = await OpenSCAD(options);
  const instance = typeof created?.getInstance === 'function' ? created.getInstance() : created;
  if (!instance?.FS || typeof instance.callMain !== 'function') {
    throw new Error('OpenSCAD WebAssembly runtime did not initialize correctly');
  }

  ensureDirectory(instance.FS, '/workspace/src');
  try { instance.FS.mkdir('/locale'); } catch { /* already exists */ }
  return instance;
}

async function mountSources(instance, files) {
  const count = files.length;
  for (let i = 0; i < count; i += 1) {
    const file = files[i];
    const bytes = await fetchVerifiedSource(file);
    const target = `/workspace/src/${file.path}`;
    const slash = target.lastIndexOf('/');
    ensureDirectory(instance.FS, target.slice(0, slash));
    instance.FS.writeFile(target, bytes);

    // Don't spam messages for huge dependency sets, but keep visible activity.
    if (i === 0 || i === count - 1 || (i + 1) % 4 === 0) {
      send('phase', {
        phase: 'sources',
        progress: 12 + Math.round(((i + 1) / Math.max(count, 1)) * 18),
        detail: `Verified source ${i + 1}/${count}: ${file.path}`
      });
    }
  }
}

async function render(job) {
  const started = performance.now();
  const instance = await loadOpenSCAD();

  send('phase', {
    phase: 'sources',
    progress: 12,
    detail: `Loading ${job.files.length} required SCAD source file(s)…`
  });
  await mountSources(instance, job.files);

  const input = `/workspace/src/${job.entryPath}`;
  const output = '/output.stl';
  try { instance.FS.unlink(output); } catch { /* no previous output */ }

  send('phase', {
    phase: 'render',
    progress: null,
    detail: `OpenSCAD is rendering ${job.entryPath} with the Manifold backend…`
  });

  let exitCode;
  try {
    exitCode = instance.callMain([
      input,
      '-o', output,
      '--backend=manifold',
      '--export-format=binstl'
    ]);
  } catch (error) {
    if (typeof error === 'number' && typeof instance.formatException === 'function') {
      error = instance.formatException(error);
    }
    throw new Error(`OpenSCAD invocation failed: ${error}`);
  }

  if (typeof exitCode === 'number' && exitCode !== 0) {
    throw new Error(`OpenSCAD returned exit code ${exitCode}`);
  }

  send('phase', {
    phase: 'output',
    progress: 94,
    detail: 'Reading generated STL…'
  });

  const bytes = instance.FS.readFile(output);
  if (!bytes?.length) throw new Error('OpenSCAD produced an empty STL file');

  const exact = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
  send('done', {
    elapsedMs: performance.now() - started,
    byteLength: bytes.byteLength,
    buffer: exact
  }, [exact]);
}

self.addEventListener('message', event => {
  const message = event.data || {};
  if (message.type !== 'render') return;
  currentJobId = message.jobId;
  render(message).catch(error => {
    send('error', {
      message: error?.message || String(error),
      stack: error?.stack || String(error)
    });
  });
});
