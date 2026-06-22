# dephy_todo

Global TODO and routine automation module for the Dephy workspace.

`dephy_todo` is the workspace memory layer. Each repo still owns its local
`docs/todo.yaml`, but this module provides the commands that validate, list,
render, and audit TODO state across the whole workspace.

## Overview

Use this repo as the global TODO entry point. It keeps work state in YAML,
renders Markdown for humans, and gives agents or scripts one place to inspect
what remains across all Dephy repos.

## Key Value

- TODO state should be structured data, not scattered chat context.
- Every repo can keep its own TODO file while still having one global entry
  point.
- Agents and humans can update work status before changing code.
- Routine scans and quick tests can run locally to reduce repeated manual
  context gathering.

## How To Use

1. Before work starts, add or set the relevant TODO item to `in_progress`.
2. Make the repo change.
3. Update the TODO status and notes in the same change.
4. Render Markdown from YAML for human reading.
5. Run global validation before committing.

Example:

```sh
tools/dephy_todo.py add docs/todo.yaml item-id docs "Improve README"
tools/dephy_todo.py set-status docs/todo.yaml item-id in_progress
tools/dephy_todo.py render-md docs/todo.yaml docs/todo.md
tools/dephy_todo.py global-validate /home/judd/moxa/personal
```

## How It Works

The YAML schema is intentionally small: version, policy, and items. The CLI
validates local files, renders Markdown, lists local or global tasks, and audits
workspace coverage. Global commands discover repos by `repo.json` while skipping
dependency and build output directories.

Routine scripts add a local automation layer for code review, TODO scanning,
parallel quick tests, and optional GPU-backed indexing commands. They are not
the source of truth; they are accelerators around the YAML files.

## Commands

```sh
tools/dephy_todo.py validate docs/todo.yaml
tools/dephy_todo.py render-md docs/todo.yaml docs/todo.md
tools/dephy_todo.py list docs/todo.yaml
tools/dephy_todo.py global-validate /home/judd/moxa/personal
tools/dephy_todo.py global-audit /home/judd/moxa/personal
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only
tools/dephy_todo.py global-render-md /home/judd/moxa/personal /home/judd/moxa/personal/TODO.md
```

Routine tools:

```sh
tools/workspace_routine.sh /home/judd/moxa/personal
tools/local_accel_routine.sh /home/judd/moxa/personal
tools/parallel_test_runner.sh /home/judd/moxa/personal
DEPHY_GPU_ROUTINE_CMD='your-gpu-indexer --root {root}' \
  tools/gpu_routine_hook.sh /home/judd/moxa/personal
```

On this host, 10 repo quick tests measured about 2.40s with `JOBS=1` and 0.82s
with `JOBS=12`.

## Test

```sh
make test
```

## TODO

TODO state is tracked in `docs/todo.yaml` and summarized in `docs/todo.md`.
