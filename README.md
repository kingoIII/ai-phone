# 🧠 FoldMind

### Local AI Inference on a Broken Samsung Fold

**FoldMind** is a project that transforms a physically damaged Samsung Fold into a dedicated AI node, running quantized large language models (LLMs) like **Mistral 7B** locally at 2.5+ tokens/sec — with no cloud, no external GPU, and no front display.

---

## 🔧 Specs

- **Device**: Samsung Fold (cover screens physically disconnected)
- **RAM**: 12GB
- **Model**: Mistral 7B (Q4 quantized, ~4.1GB)
- **Context**: 1024 tokens
- **Performance**:
  - Prompt: ~7.65 tokens/sec
  - Generation: ~2.53 tokens/sec
  - Peak RAM usage: 7GB
  - Inference time: ~5m53s

---

## ⚙️ Setup

See `setup/setup.md` for installation and deployment steps.

---

## 📦 Use Cases

- Offline AI chatbot or assistant
- Edge inference node
- Secure, private text generation
- Experimental mobile AI lab

---

## 🧪 Why This Matters

FoldMind proves that a repurposed, screenless Samsung Fold can outperform low-end laptops in running local AI models. It turns broken hardware into a fully operational inference node — lean, focused, and free from cloud dependencies.
