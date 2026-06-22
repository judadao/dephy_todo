.PHONY: test clean

build_out:
	mkdir -p build_out
	mkdir -p build_out/ignored_repo
	printf '{"repo_type":"module","name":"ignored"}\n' > build_out/ignored_repo/repo.json

test: build_out
	python3 tools/dephy_todo.py validate tests/sample.todo.yaml
	python3 tools/dephy_todo.py render-md tests/sample.todo.yaml build_out/sample.todo.md
	python3 tools/dephy_todo.py global-validate .
	python3 tools/dephy_todo.py global-list . --open-only
	python3 tools/dephy_todo.py global-list . --open-only --format json > build_out/global-list.json
	python3 tools/dephy_todo.py global-render-md . build_out/global.todo.md
	python3 tools/dephy_todo.py global-audit .
	python3 tools/dephy_todo.py global-audit . --format json > build_out/global-audit.json
	python3 -m json.tool build_out/global-list.json > /dev/null
	python3 -m json.tool build_out/global-audit.json > /dev/null
	! grep -q ignored build_out/global-audit.json
	sh tools/workspace_routine.sh . > build_out/routine.txt
	grep -q "## open todo" build_out/routine.txt
	sh tools/local_accel_routine.sh . > build_out/local-accel.txt
	grep -q "## acceleration" build_out/local-accel.txt
	DEPHY_PARALLEL_SKIP_SELF=1 sh tools/parallel_test_runner.sh . > build_out/parallel-tests.txt
	grep -q "total_seconds=" build_out/parallel-tests.txt
	sh tools/gpu_routine_hook.sh . > build_out/gpu-hook.txt
	grep -q "gpu=" build_out/gpu-hook.txt
	sh tools/local_code_review.sh --dry-run . > build_out/local-code-review.txt
	grep -q "local code review dry run" build_out/local-code-review.txt
	sh tools/benchmark_local_review.sh . > build_out/local-review-benchmark.txt
	grep -q "avg_ms=" build_out/local-review-benchmark.txt
	OUT_DIR=build_out/cppcheck sh tools/workspace_cppcheck.sh . > build_out/cppcheck.txt
	grep -q "total_findings=" build_out/cppcheck.txt
	sh -n tools/local_code_review.sh
	sh -n tools/benchmark_local_review.sh
	sh -n tools/gpu_routine_hook.sh
	sh -n tools/workspace_cppcheck.sh

clean:
	rm -rf build_out
