# dephy_todo

Global TODO and routine automation module for the Dephy workspace.

## Overview

`dephy_todo` is the global TODO entry point. Each repo owns `docs/todo.yaml`;
this module validates, lists, renders, and audits TODO state across the whole
workspace.

## Key Value

- Structured TODO state instead of chat-only memory.
- One global command surface for all repos.
- Markdown rendering for human summaries.
- Routine local scans and parallel quick-test helpers.

## How To Use

```sh
tools/dephy_todo.py validate docs/todo.yaml
tools/dephy_todo.py render-md docs/todo.yaml docs/todo.md
tools/dephy_todo.py global-validate /home/judd/moxa/personal
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only
tools/workspace_routine.sh /home/judd/moxa/personal
tools/parallel_test_runner.sh /home/judd/moxa/personal
```

## Simple Principle

Before work starts, update TODO state. After behavior changes, update TODO state
and rerender Markdown in the same change.

## Performance

On this host, 10 repo quick tests measured about 2.40s with `JOBS=1` and 0.82s
with `JOBS=12`.

## Docs

- `docs/module_structure.md`: CLI and schema structure.
- `docs/todo.md`: current TODO summary.
