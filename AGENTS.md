# Repository Guidelines

## Project Structure & Module Organization

`tools/dephy_todo.py` is the CLI entry point. Repository-owned TODO state lives
in `docs/todo.yaml`, and `docs/todo.md` is the generated human-readable summary.
Schema and workflow notes live in `docs/schema.md`. Tests use
`tests/sample.todo.yaml` plus `make test` generated outputs under `build_out/`.

## Build, Test, and Development Commands

- `make test` validates the sample TODO, renders Markdown, runs global scans,
  checks JSON output, and verifies ignored directories stay ignored.
- `python3 tools/dephy_todo.py validate docs/todo.yaml` validates this repo.
- `python3 tools/dephy_todo.py global-audit /home/judd/moxa/personal` checks
  every repo with `repo.json` has valid TODO YAML.
- `python3 tools/dephy_todo.py global-render-md /home/judd/moxa/personal /home/judd/moxa/personal/TODO.md`
  renders the workspace summary.

## Coding Style & Naming Conventions

Use Python 3 with the standard library where practical. Keep CLI commands small,
explicit, and composable. Command names are kebab-case, item IDs are kebab-case,
and TODO statuses must stay within `todo`, `in_progress`, `done`, or `blocked`.

## TODO Workflow

Use `dephy_todo` as the global TODO entry point. Before starting work, set the
relevant item to `in_progress` or add one. When behavior changes, update the
status and regenerate the affected Markdown summary in the same change.

## Testing Guidelines

Add Makefile coverage for new CLI behavior. Prefer assertions that exercise the
public CLI instead of importing private helpers, so the tests match how other
repos use the module.

## Commit Guidelines

Use Conventional Commit prefixes such as `feat:`, `fix:`, `docs:`, and `test:`.
Keep commits focused on TODO tooling behavior, schema/docs, or generated TODO
summaries.
