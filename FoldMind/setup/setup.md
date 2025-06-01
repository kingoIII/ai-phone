# 🛠 Setup Instructions for FoldMind

This guide walks through setting up FoldMind on a Samsung Fold running Android with Termux and scrcpy.

## 1. Prerequisites

- Samsung Fold with functional inner screen
- USB debugging enabled
- PC with `scrcpy` installed
- Termux installed on the phone

## 2. Install Llama.cpp

```bash
pkg update && pkg upgrade
pkg install git clang cmake termux-tools
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make -j6
```

## 3. Transfer Model

Place your quantized `.gguf` file in Termux-accessible storage, e.g., `~/models/`.

## 4. Run Benchmark

```bash
./main -m models/mistral-7b.gguf -p "Who are you?" -n 128 --ctx-size 1024 --threads 6 --batch-size 512
```

## 5. Mirror with scrcpy

```bash
scrcpy
```

You now have a fully functional local LLM terminal powered by your Fold.
