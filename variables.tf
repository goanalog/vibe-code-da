variable "region" {
  description = "Target region for IBM Cloud resources"
  type        = string
  default     = "us-south"
}

variable "initial_html" {
  description = "Initial HTML content for index.html (default Vibe animation)"
  type        = string
  default     = <<-EOT
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

# Optional IBM Cloud Projects metadata (if present, front-end can deep-link; otherwise ignored)
variable "project_id" {
  description = "IBM Cloud Project ID (optional)"
  type        = string
  default     = ""
}

variable "config_id" {
  description = "IBM Cloud Project Config ID (optional)"
  type        = string
  default     = ""
}
