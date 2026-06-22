# TODO

Source of truth: `docs/todo.yaml`. Update YAML before starting or completing work.

## global

- [x] Add global TODO validation, listing, and Markdown rendering commands.
- [x] Add a global audit command that reports repo.json repositories missing docs/todo.yaml.

## repo

- [x] Render repository Markdown summaries from docs/todo.yaml.
- [x] Support CLI status updates for individual TODO items.
- [x] Align repository layout with dephy_module_golden_sample.
- [x] Add AGENTS.md with TODO management workflow and validation commands.
- [x] Add docs/module_structure.md describing CLI, schema, tests, and generated outputs.

## integration

- [x] Add JSON output for global-list or audit results so automation can consume TODO state.

## performance

- [x] Add a regression that global scans skip build output and remain fast on large workspaces.

## automation

- [x] Add local scripts or third-party-tool wrappers for routine code viewing, TODO scanning, and test execution to reduce agent token usage.
- [x] Add optional local GPU-aware acceleration hooks for routine scans, concurrent checks, simple tests, and code indexing with CPU fallback.
- [x] Add a CPU parallel workspace test runner and timing report for routine repo tests.
- [x] Add optional GPU routine hook for local accelerated code indexing or analysis commands with CPU fallback.

## docs

- [x] Refresh all repository READMEs to reflect current module structure, TODO workflow, audits, and routine tooling.
