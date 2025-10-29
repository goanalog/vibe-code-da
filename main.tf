
provider "ibm" {}

data "ibm_resource_group" "default" {
  is_default = true
}

resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  bucket_name = "vibe-bucket-${random_string.bucket_suffix.result}"
}

resource "ibm_resource_instance" "cos" {
  name              = "vibe-cos-${random_string.bucket_suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.default.id
}

resource "ibm_cos_bucket" "vibe" {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = "us-south"
  storage_class        = "standard"
}

resource "ibm_cos_bucket_object" "index" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.region_location
  key             = "index.html"
  content         = <<EOT
<!doctype html><html lang="en"><head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" /><title>Vibe IDE — Editor</title><link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet" /><style>
    :root { --bg:#0b0c0e; --fg:#e5e7eb; --muted:#9ca3af; --card:#121317; --accent:#10b981; }
    *{box-sizing:border-box}
    html,body{height:100%;margin:0;background:var(--bg);color:var(--fg);font-family:"IBM Plex Sans",system-ui,sans-serif}
    .wrap{max-width:1200px;margin:0 auto;padding:24px}
    h1{font-size:22px;margin:0 0 12px}
    .grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
    .card{background:var(--card);border-radius:16px;padding:16px;box-shadow:0 4px 20px rgba(0,0,0,.25)}
    textarea{width:100%;height:480px;background:#0a0b0d;color:var(--fg);border:1px solid #1f2937;border-radius:12px;padding:12px;font-family:"IBM Plex Mono",monospace;font-size:13px;line-height:1.4;resize:vertical}
    iframe{width:100%;height:480px;background:white;border:1px solid #1f2937;border-radius:12px}
    .row{display:flex;gap:8px;flex-wrap:wrap}
    button{background:var(--accent);color:#072016;border:0;border-radius:12px;padding:10px 14px;font-weight:600;cursor:pointer}
    .ghost{background:transparent;color:var(--fg);border:1px solid #374151}
    .muted{color:var(--muted);font-size:12px}
    .header{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px}
    .pill{display:inline-flex;align-items:center;gap:8px;background:#111827;border:1px solid #1f2937;border-radius:999px;padding:6px 10px;font-size:12px;color:var(--muted)}
    a{color:#93c5fd}
    .links{display:flex;gap:10px;flex-wrap:wrap;margin:8px 0 12px}
    code{background:#0b0c0e;border:1px solid #1f2937;border-radius:6px;padding:2px 6px}
    /* Guide overlay */
    .overlay{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:50}
    .guide{background:var(--card);border:1px solid #374151;border-radius:16px;padding:20px;max-width:560px}
    .guide h3{margin:0 0 8px}
    .guide ol{margin:0 0 8px 18px;line-height:1.5}
  </style></head><body><div class="wrap"><div class="header"><h1>Vibe IDE — Edit <code>app.html</code> (viewer on right)</h1><div class="pill" id="env-pill">loading…</div></div><div class="links"><a id="open-live" class="ghost" href="app.html" target="_blank">Open Live app.html</a><a id="open-bucket" class="ghost" href="#" target="_blank">Open Bucket in IBM Cloud</a><button id="guideBtn" class="ghost">Publish Guide</button></div><div class="grid"><div class="card"><div class="row" style="justify-content:space-between;align-items:center;margin-bottom:8px;"><strong>Editor</strong><span class="muted">Edits apply to <code>app.html</code>. The IDE (<code>index.html</code>) is never overwritten.</span></div><textarea id="editor" placeholder="Loading app.html…"></textarea><div class="row" style="margin-top:8px"><button id="previewBtn">Preview</button><button class="ghost" id="downloadBtn">Download app.html</button></div></div><div class="card"><div class="row" style="justify-content:space-between;align-items:center;margin-bottom:8px;"><strong>Viewer</strong><span class="muted">Preview updates before publishing.</span></div><iframe id="viewer" src="app.html" referrerpolicy="no-referrer"></iframe></div></div><p class="muted" style="margin-top:12px">
      Publish: upload the downloaded <code>app.html</code> into your bucket (replacing the existing file). The site updates immediately.
    </p></div><div class="overlay" id="overlay"><div class="guide"><h3>Publish Guide — Replace <code>app.html</code></h3><ol><li>Click <b>Download app.html</b> and save the file.</li><li>Click <b>Open Bucket</b> to open the IBM Cloud console.</li><li>Upload the file and overwrite <code>app.html</code> in your bucket.</li><li>Open <b>Live app.html</b> to verify your changes.</li></ol><div class="row"><button id="closeGuide">Close</button></div></div></div><script>
    const editor = document.getElementById('editor');
    const iframe = document.getElementById('viewer');
    const dlBtn = document.getElementById('downloadBtn');
    const previewBtn = document.getElementById('previewBtn');
    const envPill = document.getElementById('env-pill');
    const openBucket = document.getElementById('open-bucket');
    const guideBtn = document.getElementById('guideBtn');
    const overlay = document.getElementById('overlay');
    const closeGuide = document.getElementById('closeGuide');

    // Load app.html into the editor
    fetch('app.html', {cache:'no-store'}).then(r => r.text()).then(t => {
      editor.value = t;
    }).catch(() => {
      editor.value = '';
    });

    // Load vibe-config.json if present to populate console link and environment pill
    fetch('vibe-config.json', {cache:'no-store'}).then(r => r.ok ? r.json() : null).then(cfg => {
      if (cfg && cfg.bucket_console_url) {
        openBucket.href = cfg.bucket_console_url;
      } else {
        openBucket.style.display = 'none';
      }
      if (cfg && cfg.website_url) {
        try { envPill.textContent = new URL(cfg.website_url).host; } catch(e) { envPill.textContent = 'COS website ready'; }
      } else {
        envPill.textContent = 'COS website ready';
      }
    }).catch(() => {
      envPill.textContent = 'COS website ready';
      openBucket.style.display = 'none';
    });

    // Preview -> load the edited HTML in the iframe via blob URL
    previewBtn.addEventListener('click', () => {
      const blob = new Blob([editor.value], {type: 'text/html'});
      const url = URL.createObjectURL(blob);
      iframe.src = url;
      setTimeout(() => URL.revokeObjectURL(url), 5000);
    });

    // Download app.html
    dlBtn.addEventListener('click', () => {
      const blob = new Blob([editor.value], {type: 'text/html'});
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'app.html';
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        URL.revokeObjectURL(a.href);
        a.remove();
      }, 1000);
    });

    // Publish Guide
    guideBtn.addEventListener('click', () => overlay.style.display = 'flex');
    closeGuide.addEventListener('click', () => overlay.style.display = 'none');
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.style.display = 'none'; });
  </script><div id="toast" style="position:fixed;bottom:16px;left:50%;transform:translateX(-50%);background:#111827;color:#e5e7eb;border:1px solid #374151;border-radius:10px;padding:10px 14px;display:none;z-index:60">Ready.</div><script>
(function(){
  const toast = document.getElementById('toast');
  const editor = document.getElementById('editor') || document.querySelector('textarea');
  const iframe = document.getElementById('iframe') || document.querySelector('iframe');
  const btn = document.getElementById('manifestBtn');
  function showToast(msg){ if(!toast) return; toast.textContent = msg; toast.style.display = 'block'; setTimeout(()=>toast.style.display='none', 2200); }
  let cfg = null;
  fetch('vibe-config.json', {cache:'no-store'}).then(r => r.ok ? r.json() : null).then(j => { cfg = j || {}; }).catch(()=>{});
  async function getSignedPutUrl(bucket) {
    if (!cfg || !cfg.sign_url) throw new Error('Signer not configured');
    const res = await fetch(cfg.sign_url, { method:'POST', headers:{'content-type':'application/json'}, body: JSON.stringify({ bucket: bucket, key:'app.html', expires: 300 }) });
    if (!res.ok) throw new Error('Signer error ' + res.status);
    const j = await res.json(); if (!j.url) throw new Error('No URL from signer'); return j.url;
  }
  btn && btn.addEventListener('click', async () => {
    try{
      showToast('Publishing…');
      const bucket = cfg && cfg.bucket_name; if (!bucket) throw new Error('Missing bucket_name in config');
      const putUrl = await getSignedPutUrl(bucket);
      const html = editor ? (editor.value || editor.textContent || '') : '<!doctype html><html></html>';
      const res = await fetch(putUrl, { method:'PUT', body: new Blob([html], {type:'text/html'}) });
      if(!res.ok){ showToast('Publish failed: ' + res.status); return; }
      setTimeout(()=>{ if(iframe){ iframe.src = 'app.html?ts=' + Date.now(); } showToast('Published!'); }, 600);
    }catch(e){ showToast('Error: ' + (e && e.message ? e.message : e)); }
  });
})();
</script></body></html>
EOT
}

resource "ibm_cos_bucket_object" "app" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.region_location
  key             = "app.html"
  content         = <<EOT
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>IBM Plex Animation</title><link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@300;400;600&family=IBM+Plex+Serif:wght@300;400&display=swap" rel="stylesheet"><style>
        /* * Base setup for a fullscreen, no-scroll experience.
         * We set the background to a dark, IBM-style blue.
         */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100vh; /* Use vh to ensure it fills the viewport height */
            overflow: hidden; /* Prevents scrollbars */
            background-color: #0a192f; /* Dark, corporate blue */
            font-family: 'IBM Plex Serif', serif; /* Default font, though h1 and status use Mono */
            color: #e0e0e0;
        }

        /* * This container holds all the animated layers.
         * It's set to relative positioning so the absolute layers
         * inside are positioned relative to it.
         */
        .plex-container {
            position: relative;
            width: 100%;
            height: 100%;
        }

        /* * This is the base style for all animation layers.
         * Each is a fullscreen overlay.
         */
        .plex-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-repeat: repeat;
            /* A subtle fade-in for the whole effect on load */
            animation: fadeIn 2s ease-in-out;
        }

        /* * Layer 1: A static, subtle grid (the "plexy" part).
         * Created using two linear-gradients, one horizontal and one vertical.
         */
        .grid-layer {
            background-image: 
                linear-gradient(rgba(74, 144, 226, 0.1) 1px, transparent 1px),
                linear-gradient(90deg, rgba(74, 144, 226, 0.1) 1px, transparent 1px);
            background-size: 30px 30px;
        }

        /* * Layer 2: Slow-moving horizontal lines.
         * Created with a repeating-linear-gradient and animated
         * using the 'move-vertical' keyframes.
         */
        .h-lines-layer {
            background-image: repeating-linear-gradient(
                transparent,
                transparent 20px,
                rgba(173, 216, 230, 0.15) 21px, /* Light blue, IBM-like */
                rgba(173, 216, 230, 0.15) 22px
            );
            animation: move-vertical 25s linear infinite, fadeIn 2s ease-in-out;
        }

        /* * Layer 3: Faster-moving diagonal lines for a parallax effect.
         * These move at a different speed and angle.
         */
        .d-lines-layer {
            background-image: repeating-linear-gradient(
                -45deg,
                transparent,
                transparent 25px,
                rgba(74, 144, 226, 0.1) 26px,
                rgba(74, 144, 226, 0.1) 27px
            );
            animation: move-diagonal 15s linear infinite, fadeIn 2s ease-in-out;
        }

        /* * Layer 4: A very subtle "scanline" effect, like an old monitor.
         * This moves faster to create a high-frequency shimmer.
         */
        .scanline-layer {
             background-image: repeating-linear-gradient(
                transparent,
                transparent 2px,
                rgba(0, 0, 0, 0.2) 3px,
                rgba(0, 0, 0, 0.2) 4px
            );
            animation: move-vertical 5s linear infinite, fadeIn 2s ease-in-out;
        }

        /* Keyframes for the vertical animation */
        @keyframes move-vertical {
            from {
                background-position-y: 0;
            }
            to {
                /* This value is arbitrary, it just needs to be large enough
                   to create a smooth loop. */
                background-position-y: -200px;
            }
        }

        /* Keyframes for the diagonal animation */
        @keyframes move-diagonal {
            from {
                background-position: 0 0;
            }
            to {
                background-position: 100px 100px;
            }
        }

        /* Keyframes for the initial fade-in */
        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        /* Keyframes for the blinking cursor */
        @keyframes blink {
            from, to {
                opacity: 1;
            }
            50% {
                opacity: 0;
            }
        }

        /* Keyframes for the Vibe IDE text gradient animation */
        @keyframes hue-shift {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }

        /* * Optional: Add some text in the center to show it's a page.
         */
        .content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            z-index: 10; /* Ensures text is on top */
            display: flex; /* Use flexbox for horizontal alignment */
            flex-direction: column; /* Stack children vertically */
            align-items: center; /* Center children horizontally */
        }

        .content .vibe-ide-title {
            display: flex; /* Make the title itself a flex container */
            align-items: center; /* Align items vertically in the middle */
            gap: 15px; /* Space between decorators and text */
            margin-bottom: 10px;
        }

        .content h1 {
            font-family: 'IBM Plex Mono', monospace; /* Switched to Mono for the main title */
            font-weight: 600; /* Bolder weight */
            font-size: 3rem; /* Larger size */
            letter-spacing: 5px; /* Wider letter spacing for impact */
            text-transform: uppercase;
            text-shadow: 0 0 15px rgba(173, 216, 230, 0.7);
            animation: fadeIn 2s ease-in-out;

            /* Gradient properties for Vibe IDE */
            background: linear-gradient(90deg, #6dd5ed, #c0c0c0, #ff7e5f, #c0c0c0, #6dd5ed); /* Vibrant gradient */
            background-size: 400% 400%; /* Make gradient large for animation */
            -webkit-background-clip: text; /* Clip background to text */
            -webkit-text-fill-color: transparent; /* Make text transparent to show gradient */
            animation: hue-shift 10s ease infinite, fadeIn 2s ease-in-out; /* Apply gradient animation */
        }

        /* Cutesy decorators */
        .content .vibe-ide-title::before,
        .content .vibe-ide-title::after {
            content: "//"; /* Simple, code-like decorator */
            font-family: 'IBM Plex Mono', monospace;
            font-size: 1.8rem;
            color: #4a90e2; /* IBM blue */
            text-shadow: 0 0 8px rgba(74, 144, 226, 0.6);
            animation: fadeIn 2s ease-in-out;
        }

        /* New status line style */
        .content .status {
            font-family: 'IBM Plex Mono', monospace; /* Monospaced font for tech feel */
            font-size: 1.1rem;
            color: #c0c0c0;
            text-shadow: none;
            letter-spacing: 1px;
            animation: fadeIn 2.5s ease-in-out; /* Slightly delayed fade-in */
        }

        .content .status .online {
            color: #adff2f; /* Classic terminal green */
            font-weight: bold;
            text-shadow: 0 0 6px rgba(173, 255, 47, 0.6); /* Green glow */
        }

        .content .status .cursor {
            color: #adff2f;
            animation: blink 1s step-end infinite;
        }

    </style></head><body><div class="plex-container"><div class="plex-layer grid-layer"></div><div class="plex-layer h-lines-layer"></div><div class="plex-layer d-lines-layer"></div><div class="plex-layer scanline-layer"></div></div><div class="content"><div class="vibe-ide-title"><h1>Vibe IDE</h1></div><p class="status">SYSTEM STATUS: <span class="online">OPERATIONAL</span><span class="cursor">_</span></p></div></body></html>
EOT
}

resource "ibm_cos_bucket_object" "vibe_config" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.region_location
  key             = "vibe-config.json"
  content         = jsonencode({
    website_url: "https://${ibm_cos_bucket.vibe.bucket_name}.us-south.cloud-object-storage.appdomain.cloud",
    bucket_console_url: "https://cloud.ibm.com/objectstorage/buckets/${ibm_cos_bucket.vibe.bucket_name}?region=us-south",
    sign_url: "https://vibe-manifest-broker.brendanandrewfitzpatrick.workers.dev/sign",
    bucket_name: ibm_cos_bucket.vibe.bucket_name
  })
}

resource "ibm_cos_bucket_object" "error" {
  bucket_crn      = ibm_cos_bucket.vibe.crn
  bucket_location = ibm_cos_bucket.vibe.region_location
  key             = "404.html"
  content         = "<!DOCTYPE html><html><head><meta charset='utf-8'><title>Not Found</title></head><body style='font-family: IBM Plex Sans, sans-serif; background:#000; color:#e5e7eb; text-align:center; padding-top:20vh;'><h1 style='font-size:3rem;'>404</h1><p>This vibe isn’t manifest yet.</p></body></html>"
}

