.PHONY: test clean

build_out:
	mkdir -p build_out

test: build_out
	python3 tools/dephy_todo.py validate tests/sample.todo.yaml
	python3 tools/dephy_todo.py render-md tests/sample.todo.yaml build_out/sample.todo.md
	python3 tools/dephy_todo.py global-validate .
	python3 tools/dephy_todo.py global-list . --open-only
	python3 tools/dephy_todo.py global-render-md . build_out/global.todo.md

clean:
	rm -rf build_out
