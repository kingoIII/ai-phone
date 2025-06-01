
# 🧠 AI+Phone

---

## 🚦 Pick Your Path

1. **Advanced (llama.cpp)**  
   - Full local control, highest flexibility, runs quantized models in Termux via command line.  
   - Can leverage root access or software acceleration (e.g., NEON, SVE extensions) if available—though on our phone no root is used.  
2. **Easy (PocketPal)**  
   - Simple Android app with a built-in UI—just install, drop in a quantized model, and chat.  
   - No Termux, no manual build steps. Lower performance, but zero setup overhead.  

> **Difference in a nutshell:**  
> - **llama.cpp** is a DIY, command-line toolchain. You compile in Termux, manage models manually, and get maximum speed/tuning.  
> - **PocketPal** is an out-of-the-box Android app: minimal setup, easy interface, but limited to the app’s built-in optimizations.  

---

### Local AI Inference on a Repurposed Smartphone

**AI+Phone** is a proof-of-concept project that shows how any modern, high-end smartphone (even with broken or disconnected screens) can be transformed into a dedicated edge-AI node. In this setup, we use a Samsung Fold with its cover screens physically disconnected—but the same principles apply to any phone with sufficient RAM and CPU power. The phone runs quantized large language models (LLMs) like **Mistral 7B** locally (at roughly 2.5 tokens/sec generation) without relying on the cloud, external GPUs, or its original display hardware.

---
![Screenshot_2025-06-01_13-45-16](https://github.com/user-attachments/assets/b14c90a3-c97b-458f-a7b9-36ad4974787f)

## 🔧 Specs & Benchmark Results

- **Device:** Samsung Fold (inner screen only; cover/front screens removed or disconnected)  
- **OS Environment:** Android + Termux + scrcpy (for PC control)  
- **RAM:** 12 GB LPDDR5  
- **Model:** Mistral 7B (Q4 quantized, ~4.11 GB GGUF)  
- **Context Window:** 1024 tokens  
- **CPU Threads Used:** 6  
- **Benchmark Flags:**  
  - `--ctx-size 1024`  
  - `--batch-size 512`  
  - `--threads 6`  
  - Flash attention: disabled  

| Metric             | Value            |
|--------------------|------------------|
| Parameters         | 7.25 B           |
| File Size          | ~4.11 GB         |
| Prompt Speed       | ~7.65 tokens/sec |
| Generation Speed   | ~2.53 tokens/sec |
| Peak RAM Usage     | ~7 GB / 12 GB    |
| Total Run Time     | ~5 min 53 sec    |
| Context Size       | 1024             |
| CPU Threads        | 6                |

> **Key Takeaway:**  
> Running a quantized 7 B-parameter LLM locally on a smartphone can outperform many sub-$500 laptops in raw inference speed—especially because the phone’s silenced/removed display hardware frees up extra power for computation.

---

## ⚙️ Full Setup & Installation

Below is a consolidated setup guide. You can keep each section in a separate file or fold them all into this README—either way, all the steps are here.

### 1. Prerequisites

1. **Android smartphone** with at least 8 GB RAM (12 GB recommended). In our case: Samsung Fold with a working inner screen.  
2. **USB debugging enabled** on the phone:  
   - Go to **Settings → About phone → Tap “Build number” 7 times**.  
   - Go back to **Settings → Developer options → Enable “USB debugging”**.  
3. **PC (Linux, Windows, or macOS)** with `scrcpy` installed, to mirror/control the phone from your computer.  
4. **Termux** installed on the phone (for a minimal Linux environment).  
5. A **quantized GGUF model file** (e.g., `mistral-7b-Q4_0.gguf`) already downloaded or transferred to the phone.  

---

### 2. Install & Compile llama.cpp in Termux (Advanced)

_Open Termux on your phone (or connect via `adb shell`), then run:_

```bash
pkg update && pkg upgrade
pkg install git clang cmake make termux-tools
# Clone llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
# Build with 6 threads; if you have root or NEON/SVE acceleration, enable it via CFLAGS
make -j6
```

- **Outcome:** You’ll get an executable `main` inside `~/llama.cpp` that can load GGUF models for inference and benchmarking.  
- *(Optional root/acceleration note: If you have root access, you can enable CPU governor tweaks or install packages like `schedutil` for better performance. You can also compile with `CFLAGS="-march=armv8-a+crc -O3"` or similar to unlock SIMD extensions.)*

---

### 3. Transfer or Download the Quantized Model

- Place your `.gguf` file (e.g., `mistral-7b-Q4_0.gguf`) into a directory accessible by Termux, such as `~/models/`.  
  - You can use `adb push` from your PC, or download it directly inside Termux via `curl`/`wget`.  

```bash
mkdir -p ~/models
# Example: Use wget or curl if you have a direct link
# wget -O ~/models/mistral-7b-Q4_0.gguf https://example.com/path/to/mistral-7b-Q4_0.gguf
```

---

### 4. Run Benchmarks & Inference (Advanced)

_Place the model at `~/models/mistral-7b-Q4_0.gguf` and then:_

```bash
cd ~/llama.cpp

# Benchmark prompt processing + token generation:
./main \
  -m ~/models/mistral-7b-Q4_0.gguf \
  -p "Who are you?" \
  -n 128 \
  --ctx-size 1024 \
  --threads 6 \
  --batch-size 512
```

You’ll see output similar to:

```
Parameters: 7.25 B
File size: ~4.11 GB
Benchmark:
  Prompt-processing speed: 7.65 tokens/sec
  Token-generation speed: 2.53 tokens/sec
  Peak RAM used: ~7 GB / 12 GB
  Total elapsed: ~5 min 53 sec
```

> **Note:** These numbers will vary slightly depending on Android version, temperature (thermal throttling), and exact SoC configuration. But you’re in the right ballpark if you see > 2.0 tokens/sec for generation.

---

### 5. Mirror & Control with scrcpy (Advanced)

On your PC, install `scrcpy` if you haven’t already:

- **Ubuntu/Debian:**  
  ```bash
  sudo apt update
  sudo apt install scrcpy
  ```
- **Fedora:**  
  ```bash
  sudo dnf install scrcpy
  ```
- **Arch:**  
  ```bash
  sudo pacman -S scrcpy
  ```
- **macOS (Homebrew):**  
  ```bash
  brew install scrcpy
  ```
- **Windows (Scoop or Chocolatey):**  
  ```powershell
  scoop install scrcpy
  # or
  choco install scrcpy
  ```

Then, plug the phone in via USB cable, approve the USB debugging prompt on the phone, and run:

```bash
scrcpy
```

You’ll see your phone’s inner screen mirrored on your PC. You can now type in Termux, run the LLM, monitor performance, and even copy/paste between environments.  

> **Wireless Option:**  
> 1. Connect phone and PC to the same Wi-Fi network.  
> 2. In Termux or an `adb shell` on your PC, run:
>    ```bash
>    adb tcpip 5555
>    # On phone: get its IP via `ip addr show wlan0` (e.g., 192.168.1.42)
>    adb connect 192.168.1.42:5555
>    scrcpy --tcpip=192.168.1.42:5555
>    ```
> 3. Now you have a wireless mirror/control session—no cable needed.

---

## 📦 Easy Setup with PocketPal (Easy)

1. **Install “PocketPal”** from your favorite Android APK source (or F-Droid if available).  
2. **Copy your quantized `.gguf` model** (e.g., `mistral-7b-Q4_0.gguf`) into the app’s “models” folder (usually `Android/data/ai.pocketpal/files/models/`).  
3. **Open PocketPal**, select the model, and start chatting—no extra compilation or command-line steps required.  
4. **Performance trade-off:** PocketPal auto-configures threads and memory, but you won’t see the 2.5 tokens/sec that Termux/llama.cpp can deliver. You’ll get somewhere around 1–1.5 tokens/sec depending on the version.  

> **Root/Acceleration Note:**  
> - If your phone is rooted, PocketPal (and/or llama.cpp in Termux) can leverage kernel tweaks (e.g., CPU governor `performance`) or libraries like `libneon` for NEON acceleration.  
> - On our Fold, no root is used—so performance is purely based on default scheduler and software optimizations.

---

## 🔗 Combined Folder Structure (Optional)

```
ai-plus-phone/
├── README.md
├── setup/
│   └── setup.md        # Advanced llama.cpp instructions
├── benchmarks/
│   └── mistral7b_benchmark.md
├── scripts/
│   └── run.sh          # Quick-run script for llama.cpp
└── models/             # (Not in repo, user places .gguf here)
```

---

## 🧪 Use Cases & Workflows

1. **Offline AI Chatbot / Assistant (Advanced):**  
   - Run llama.cpp in Termux; pipe text through a simple loop.  
   - Use Android’s keyboard or a Bluetooth keyboard.  
   - No cloud API needed—full privacy.  

2. **Offline Chat via PocketPal (Easy):**  
   - Launch PocketPal, choose your model, and start generating text.  
   - Built-in UI, minimal controls—great for quick testing or demos.  

3. **Edge Inference Node:**  
   - Use llama.cpp + Flask (in Termux) or the built-in HTTP server in PocketPal to expose a local API.  
   - Other devices on LAN can query the phone for summarization or translation tasks.

4. **Secure, Private Text Generation:**  
   - All data stays on-device.  
   - Perfect for personal diaries, encrypted notes, or confidential prompts.

5. **Experimental Mobile AI Lab:**  
   - Benchmark and compare quantized LLMs (Mistral, LLaMA, Phi) directly on the phone.  
   - Explore on-device fine-tuning (e.g., LoRA via llama.cpp).  
   - Test tokenization, prompt engineering, and memory trade-offs at the hardware edge.

---

## 🧪 Why This Matters

1. **Repurposing “Broken” Hardware:**  
   - Removing or disabling the front/display panels eliminates their power draw.  
   - CPU/GPU and RAM can devote all thermal/power headroom to inference tasks.  
   - A device that “looks useless” becomes an incredibly capable mini server.  

2. **Edge vs. Cloud:**  
   - Most “AI phone” demos rely on cloud APIs. Here, everything is entirely local.  
   - No latency spikes, no data egress, no dependence on internet connectivity.  
   - Demonstrates that a $1k+ smartphone’s silicon can rival or exceed sub-$500 laptops for AI inference.  

3. **Democratizing AI Access:**  
   - Not everyone can afford desktop GPUs or cloud credits.  
   - High-end phones are ubiquitous—repurpose an older or broken device into your personal AI node.  
   - Encourages sustainable tech reuse (“don’t trash that broken foldable—turn it into an AI workstation”).

4. **Portable & Discreet:**  
   - Your “AI cluster” fits in your pocket.  
   - At a coffee shop, plug into any outlet (or run off battery) and you’ve got a private AI lab.  
   - No conspicuous GPU rigs, no power-hungry towers—just silent phone-level compute.

---

## 🚀 Step-by-Step Quickstart

If you just want the bare-bones commands to get spinning right now, choose your path:

---

### Advanced (llama.cpp)

1. **Enable USB debugging** on your phone.  
2. **Install scrcpy** on your PC; **install Termux** on the phone.  
3. In Termux:
   ```bash
   pkg update && pkg upgrade
   pkg install git clang cmake make termux-tools
   git clone https://github.com/ggerganov/llama.cpp
   cd llama.cpp
   make -j6
   mkdir -p ~/models
   # Transfer your quantized GGUF here (e.g., mistral-7b-Q4_0.gguf)
   ```
4. **Benchmark / run**:
   ```bash
   cd ~/llama.cpp
   ./main -m ~/models/mistral-7b-Q4_0.gguf \
          -p "Hello, who are you?" \
          -n 128 \
          --ctx-size 1024 \
          --threads 6 \
          --batch-size 512
   ```
5. **Mirror with scrcpy** on PC:
   ```bash
   scrcpy
   ```
6. **Interact** with llama.cpp in Termux via the mirrored screen.  

---

### Easy (PocketPal)

1. **Install PocketPal** on your Android phone.  
2. **Copy your quantized model** (e.g., `mistral-7b-Q4_0.gguf`) into `Android/data/ai.pocketpal/files/models/`.  
3. **Open PocketPal**, select the model, and start chatting.  

---

## 💡 Next Steps & Ideas

- **Voice I/O Integration:**  
  - Install Whisper (or use Android’s Speech API) for automatic speech recognition in Termux.  
  - Hook up a Text-to-Speech engine (like Piper or Android’s built-in TTS) for audible responses.  
  - Build a simple loop: “Wake word → transcribe → generate response → TTS output.”

- **Local Web UI:**  
  - Use Flask or FastAPI in Termux to serve a minimal web frontend.  
  - On your PC (or any LAN device), browse to `http://<phone-IP>:8000/` and chat via browser.

- **Model Swapping & Comparison:**  
  - Add scripts to download and benchmark different quantized models (LLaMA, Phi, Mistral).  
  - Track token rates, memory footprints, and accuracy trade-offs—all on one phone.

- **Battery & Thermal Profiling:**  
  - Use Termux’s `top`, `htop`, or Android’s battery stats to measure power draw during inference.  
  - Compare performance with screen on vs. screen off (or disconnected).

- **Automation & Scripting:**  
  - Write a simple shell script in `/scripts` (e.g., `run_infer.sh`) to launch favorite prompts automatically.  
  - Schedule periodic tasks: “Every day at 9 am, summarize my notes.”

- **Community & Publishing:**  
  - Publish this repo as `ai-plus-phone`.  
  - Share benchmarks, setup guides, encourage forks for other phone models.  
  - Document lessons: which phones are easiest to repurpose? Which quant methods yield best performance?

---

## 🙌 Acknowledgments & Credits

- **llama.cpp** by Georgi Gerganov and community  
- **Mistral 7B Quantized Model** (4-bit)  
- **scrcpy** developers for seamless Android mirroring  
- **Termux** and all open-source contributors  

---

## 📝 License

Consider a permissive license like **MIT** or **Apache 2.0**, since the core code is minimal and most work is done by external open-source libraries.

---

**AI+Phone** proves that even “broken” hardware can run serious AI workloads. Put down those dusty laptops—your next AI workstation could be the phone in your pocket.  
```
