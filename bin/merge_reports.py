#!/usr/bin/env python3

import argparse
import pandas as pd

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--reports", nargs="+")
    args = parser.parse_args()


    dfs = []
    for report in args.reports:
        df = pd.read_csv(report, sep="\t")
        dfs.append(df)

    merged = pd.concat(dfs, ignore_index=True)
    merged.to_csv("assembly_report.tsv", sep="\t", index=False)
