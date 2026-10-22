#!/usr/bin/env python3

"""Merge JSON coverage-bin summaries."""

import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "inputs",
        nargs="+",
        help="Input JSON coverage summaries",
    )

    parser.add_argument(
        "--out",
        default="regression/coverage_merged.json",
    )

    args = parser.parse_args()

    merged = {
        "inputs": args.inputs,
        "groups": {},
    }

    for filename in args.inputs:
        data = json.loads(
            Path(filename).read_text()
        )

        for group, bins in data.get("groups", {}).items():
            destination = merged["groups"].setdefault(
                group, {}
            )

            for bin_name, count in bins.items():
                destination[bin_name] = max(
                    destination.get(bin_name, 0),
                    count,
                )

    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)

    output.write_text(
        json.dumps(merged, indent=2)
    )

    print(f"Coverage summary written to {output}")


if __name__ == "__main__":
    main()
