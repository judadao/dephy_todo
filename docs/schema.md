# dephy_todo schema

`docs/todo.yaml` is the source of truth for repository work tracking.

Required top-level fields:

- `version: 1`
- `policy.source_of_truth`
- `items`

Each item requires:

- `id`: stable unique identifier
- `area`: grouping label
- `title`: human-readable task
- `status`: `todo`, `in_progress`, `done`, or `blocked`

Optional fields:

- `notes`
- `depends_on`
- `evidence`

