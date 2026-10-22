#!/usr/bin/env python3

"""Run named UVM tests and generate a JSON regression summary."""

import argparse
import json
import subprocess
import time
from pathlib import Path


def run_test(simulator, test_name, seed):
    if simulator == "questa":
        command = [
            "vsim",
            "-c",
            f"+UVM_TESTNAME={test_name}",
            f"+ntb_random_seed={seed}",
            "-do",
            "run -all; quit -f",
        ]
    else:
        command = [
            "./simv",
            f"+UVM_TESTNAME={test_name}",
            f"+ntb_random_seed={seed}",
        ]

    start = time.time()

    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=1800,
        )

        log = result.stdout

        # Check both simulator exit status and UVM summary.
        passed = (
            result.returncode == 0
            and "UVM_FATAL" in log
            and "UVM_ERROR" in log
            and "UVM_FATAL :    0" in log
            and "UVM_ERROR :    0" in log
        )

        return {
            "test": test_name,
            "seed": seed,
            "passed": passed,
            "returncode": result.returncode,
            "elapsed_s": round(time.time() - start, 2),
            "log_tail": log[-2000:],
        }

    except (OSError, subprocess.TimeoutExpired) as error:
        return {
            "test": test_name,
            "seed": seed,
            "passed": False,
            "error": str(error),
        }


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--sim",
        choices=["questa", "vcs"],
        required=True,
    )

    parser.add_argument(
        "--tests",
        default="verif/uvm/tests/regression_test_list.f",
    )

    parser.add_argument("--seed", type=int, default=1)

    parser.add_argument(
        "--out",
        default="regression/results.json",
    )

    args = parser.parse_args()

    tests_path = Path(args.tests)

    tests = [
        line.strip()
        for line in tests_path.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]

    results = []

    for index, test_name in enumerate(tests):
        seed = args.seed + index

        result = run_test(
            args.sim,
            test_name,
            seed,
        )

        results.append(result)

        status = "PASS" if result["passed"] else "FAIL"

        print(
            f"{status}: {test_name}, seed={seed}"
        )

    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)

    output.write_text(
        json.dumps(results, indent=2)
    )

    passed_count = sum(
        result["passed"] for result in results
    )

    print(
        f"\nRegression summary: "
        f"{passed_count}/{len(results)} passed"
    )

    return 0 if passed_count == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
