#!/usr/bin/env python3

import argparse
from pathlib import Path

import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser(
        description="Combine quast, fastani and checkm2 reports into one"
    )
    parser.add_argument(
        "--id",
        type=str,
        required=True,
        help="ID of sample"
    )
    parser.add_argument(
        "--quast",
        type=Path,
        required=True,
        help="Path to quast summary report"
    )
    parser.add_argument(
        "--fastani",
        type=Path,
        required=True,
        help="Path to fastani report"
    )
    parser.add_argument(
        "--checkm2",
        type=Path,
        required=True,
        help="Path to checkm2 report"
    )
    return parser.parse_args()


def main():
    args = parse_args()

    quast_df = pd.read_csv(args.quast, sep='\t')
    quast_df = quast_df.rename(columns={quast_df.columns[0]: "ID"})

    fastani_df = pd.read_csv(args.fastani, sep='\t', header=None, names=["file", "ref", "est. ANI", "orthos", "fragments"])
    fastani_df = fastani_df[["file", "est. ANI"]]
    fastani_df["file"] = fastani_df["file"].str.replace(r'\.fa$', '', regex=True)
    fastani_df = fastani_df.rename(columns={"file": "ID"})

    checkm2_df = pd.read_csv(args.checkm2, sep='\t')
    checkm2_df = checkm2_df[["Name", "Completeness", "Contamination", "GC_Content", "Total_Coding_Sequences", "Total_Contigs", "Max_Contig_Length"]]
    checkm2_df = checkm2_df.rename(columns={"Name": "ID"})

    merged_df = quast_df.merge(fastani_df, on="ID", how="outer") \
                        .merge(checkm2_df, on="ID", how="outer")
    
    merged_df.to_csv(f"{args.id}_report.tsv", sep='\t', index=None)


if __name__ == "__main__":
    main()
