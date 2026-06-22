# Local Review Benchmark

Host: NVIDIA GeForce RTX 3060, Ollama on `127.0.0.1:11434`.

Measured against current `dephy_todo` working-tree changes on 2026-06-22.

| Mode | Model | Result | Time |
| --- | --- | --- | ---: |
| Context preparation, explicit model | n/a | pass | 31-37 ms average |
| Context preparation, auto model detect | `llama3.2:latest` | pass | 70-71 ms average |
| Ollama generation | `deepseek-coder:latest` | failed quality, summary response | 4.185 s |
| Ollama generation | `mistral:7b-instruct` | failed quality, summary response | 17.566 s |
| Ollama generation | `llama3.2:latest` | pass, emitted review sections | 11.422 s |
| Ollama generation, warmed auto path | `llama3.2:latest` | pass quality gate | 5.435 s |

Interpretation:

- CPU context preparation is already negligible for routine review input. Auto
  model detection adds a small Ollama `/api/tags` request.
- Local GPU/model review is useful as a first-pass signal, not final authority.
- Quality gating is required because faster local models can return generic
  summaries instead of actionable review findings.
- On this host, `llama3.2:latest` is the default practical Ollama model from
  the installed set. Stronger code-review models can be selected with
  `DEPHY_LOCAL_REVIEW_MODEL`.
- The local model can still produce noisy findings. Codex should treat it as an
  accelerator for first-pass review context, not as the final reviewer.
