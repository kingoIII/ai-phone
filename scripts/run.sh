#!/data/data/com.termux/files/usr/bin/bash

# Simple script to launch llama.cpp inference on Termux
cd ~/llama.cpp
./main -m ~/models/mistral-7b.gguf -p "Hello, who are you?" -n 128 --ctx-size 1024 --threads 6 --batch-size 512
