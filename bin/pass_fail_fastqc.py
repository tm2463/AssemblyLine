#!/usr/bin/env python3

import json
from pathlib import Path
import argparse

class InvalidFastQCReportError(Exception):
    pass


def process_report(reports, criteria_file):
    with open(criteria_file) as j:
        pass_criteria = set(json.load(j))

    for report in reports:
        with open(report) as f:
            for line in f:
                fields = line.strip("\n").split('\t')

                if len(fields) != 3:
                    raise InvalidFastQCReportError(f"Invalid FastQC Report: {report}")

                if fields[1] in pass_criteria and fields[0] == "FAIL":
                    return "FAIL"

    return "PASS"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Return 'PASS' or 'FAIL' after parsing FastQC report based on pass criteria"
    )
    parser.add_argument(
        "--summary_files",
        nargs="+",
        type=Path,
        help="List of summary.txt files produced by FastQC"
    )
    parser.add_argument(
        "--pass_criteria_json",
        type=Path,
        help="Path to json containing FastQC pass criteria"
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    outcome = process_report(
        args.summary_files,
        args.pass_criteria_json
    )

    print(outcome)
