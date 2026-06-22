# dephy_todo

Global TODO and routine automation module for the Dephy workspace.

Each repo owns `docs/todo.yaml`. This module validates TODO files, renders
Markdown summaries, audits workspace coverage, and provides local routine tools
that reduce repeated agent context gathering.

## Commands

```sh
tools/dephy_todo.py validate docs/todo.yaml
tools/dephy_todo.py render-md docs/todo.yaml docs/todo.md
tools/dephy_todo.py list docs/todo.yaml
tools/dephy_todo.py add docs/todo.yaml item-id area "Task title"
tools/dephy_todo.py set-status docs/todo.yaml item-id done

tools/dephy_todo.py global-validate /home/judd/moxa/personal
tools/dephy_todo.py global-audit /home/judd/moxa/personal
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only --format json
tools/dephy_todo.py global-render-md /home/judd/moxa/personal /home/judd/moxa/personal/TODO.md
```

## Routine Tools

```sh
tools/workspace_routine.sh /home/judd/moxa/personal
tools/local_accel_routine.sh /home/judd/moxa/personal
tools/parallel_test_runner.sh /home/judd/moxa/personal
DEPHY_GPU_ROUTINE_CMD='your-gpu-indexer --root {root}' \
  tools/gpu_routine_hook.sh /home/judd/moxa/personal
```

- `workspace_routine.sh`: repo dirtiness, open TODOs, suggested tests, key files.
- `local_accel_routine.sh`: CPU/GPU detection and code-shape summary.
- `parallel_test_runner.sh`: CPU-parallel quick tests across repos.
- `gpu_routine_hook.sh`: optional GPU-backed analysis command with CPU fallback.

On this host, 10 repo quick tests measured about 2.40s with `JOBS=1` and 0.82s
with `JOBS=12`.

## AI Workflow

Before starting work, add or set the relevant TODO to `in_progress`. When
behavior changes, update the status and rerender Markdown in the same change.

## Test

```sh
make test
```

## TODO

TODO state is tracked in `docs/todo.yaml` and summarized in `docs/todo.md`.
