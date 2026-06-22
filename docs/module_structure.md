# dephy_todo Module Structure

`dephy_todo` is the workspace TODO management module. It owns validation,
rendering, status updates, and global repository audit commands for repos that
carry `repo.json` and `docs/todo.yaml`.

## Public CLI

- `validate` checks one `docs/todo.yaml`.
- `render-md` renders one repo's Markdown summary.
- `list` prints one repo's TODO items.
- `set-status` updates one item status and optional note.
- `add` appends a new item.
- `global-validate` validates all discovered TODO YAML files.
- `global-list` prints all TODO items and supports `--format json`.
- `global-render-md` renders the workspace summary.
- `global-audit` checks every discovered repo and supports `--format json`.

## Files

- `tools/dephy_todo.py`: CLI implementation.
- `tools/local_code_review.sh`: optional local-model preliminary code review
  through Ollama or vLLM/OpenAI-compatible HTTP endpoints.
- `tools/benchmark_local_review.sh`: repeatable timing wrapper for local review
  context preparation and optional model generation.
- `tools/gpu_routine_hook.sh`: GPU-aware hook that can run a generic command or
  `local_code_review.sh` when `DEPHY_LOCAL_REVIEW=1`.
- `tools/workspace_cppcheck.sh`: workspace C static-analysis routine using
  cppcheck when available.
- `docs/todo.yaml`: source of truth for this repo's TODO state.
- `docs/todo.md`: generated summary for humans.
- `docs/schema.md`: TODO schema reference.
- `docs/local_review_benchmark.md`: local-model review benchmark notes.
- `tests/sample.todo.yaml`: validation and render fixture.
- `Makefile`: public test target and generated-output checks.
- `build_out/`: ignored generated test outputs.

## Discovery Rules

Global commands recursively scan the requested root and ignore `.git`, `build`,
`build_out`, `deps`, `out`, `zephyrproject`, and `archive`. `global-list` is
driven by `docs/todo.yaml`; `global-audit` is driven by `repo.json` so missing
TODO files are visible.
