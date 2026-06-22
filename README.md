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
```

Valid statuses are `todo`, `in_progress`, `done`, and `blocked`.

