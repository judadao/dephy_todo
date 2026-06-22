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
- [x] Add a local-model code review routine that can call Ollama or vLLM/OpenAI-compatible endpoints from the GPU routine hook.
- [x] Add a workspace cppcheck routine so code review can consistently scan C repos for warning/style/performance issues.

## docs

- [x] Refresh all repository READMEs to reflect current module structure, TODO workflow, audits, and routine tooling.
- [x] Expand repository READMEs with project value, usage flow, and architecture principles while keeping long legacy details in docs.
- [x] Keep project summary, value proposition, and usage steps in root READMEs instead of moving them to docs.
- [x] Compact long root READMEs into a consistent template with overview, value, usage, docs links, simple principle, and optional performance results.
- [x] Rescan each repo and rebuild README content around repo-specific features, architecture flow, and user scenario flow diagrams.

## metadata

- [x] Add MIT license files and local repository metadata descriptions/topics for all workspace repos.
- [x] Refresh all workspace repo About descriptions and hashtags/topics so GitHub metadata is clearer.
