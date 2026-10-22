#!/usr/bin/env python3

"""Generate an HTML report from regression results."""

import argparse
import html
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "results",
        nargs="?",
        default="regression/results.json",
    )

    parser.add_argument(
        "--out",
        default="regression/report.html",
    )

    args = parser.parse_args()

    results = json.loads(
        Path(args.results).read_text()
    )

    rows = []

    for result in results:
        status = (
            "PASS"
            if result.get("passed", False)
            else "FAIL"
        )

        rows.append(
            "<tr>"
            f"<td>{html.escape(str(result.get('test', '')))}</td>"
            f"<td>{html.escape(str(result.get('seed', '')))}</td>"
            f"<td>{status}</td>"
            f"<td>{html.escape(str(result.get('elapsed_s', '')))}</td>"
            "</tr>"
        )

    passed = sum(
        bool(result.get("passed"))
        for result in results
    )

    document = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Interrupt Controller Regression</title>
<style>
body {{ font-family: sans-serif; margin: 2rem; }}
table {{ border-collapse: collapse; width: 100%; }}
th, td {{ border: 1px solid #aaa; padding: 8px; text-align: left; }}
</style>
</head>
<body>
<h1>Interrupt Controller Regression Report</h1>
<p>Tests passed: {passed}/{len(results)}</p>
<table>
<thead>
<tr><th>Test</th><th>Seed</th><th>Status</th><th>Duration (s)</th></tr>
</thead>
<tbody>
{''.join(rows)}
</tbody>
</table>
</body>
</html>
"""

    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(document)

    print(f"HTML report written to {output}")


if __name__ == "__main__":
    main()
