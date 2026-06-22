# TODO

Source of truth: `docs/todo.yaml`. Update YAML before starting or completing work.

## global

- [x] Add global TODO validation, listing, and Markdown rendering commands.
- [x] Add a global audit command that reports repo.json repositories missing docs/todo.yaml.

## repo

- [x] Render repository Markdown summaries from docs/todo.yaml.
- [x] Support CLI status updates for individual TODO items.
- [ ] Align repository layout with dephy_module_golden_sample. (`in_progress`)
- [ ] Add AGENTS.md with TODO management workflow and validation commands.
- [ ] Add docs/module_structure.md describing CLI, schema, tests, and generated outputs.

## integration

- [ ] Add JSON output for global-list or audit results so automation can consume TODO state.

## performance

- [ ] Add a regression that global scans skip build output and remain fast on large workspaces.
