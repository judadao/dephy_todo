# dephy_todo

Reusable TODO management module for Dephy repos.

The intent is simple: each repo owns `docs/todo.yaml`, and automation uses this
module to validate, render, and update it. AI agents should update TODO status
before starting or completing work.

## Commands

```sh
tools/dephy_todo.py validate /path/to/docs/todo.yaml
tools/dephy_todo.py render-md /path/to/docs/todo.yaml /path/to/docs/todo.md
tools/dephy_todo.py list /path/to/docs/todo.yaml
tools/dephy_todo.py set-status /path/to/docs/todo.yaml item-id done
tools/dephy_todo.py add /path/to/docs/todo.yaml new-id area "Task title"
tools/dephy_todo.py global-validate /home/judd/moxa/personal
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only
tools/dephy_todo.py global-list /home/judd/moxa/personal --open-only --format json
tools/dephy_todo.py global-render-md /home/judd/moxa/personal /home/judd/moxa/personal/TODO.md
tools/dephy_todo.py global-audit /home/judd/moxa/personal
tools/dephy_todo.py global-audit /home/judd/moxa/personal --format json
```

Valid statuses are `todo`, `in_progress`, `done`, and `blocked`.

## AI workflow

Use `dephy_todo` as the global TODO entry point. Before starting work, add or
mark the item `in_progress`. When behavior changes, update status and render
the affected Markdown summary in the same change.
