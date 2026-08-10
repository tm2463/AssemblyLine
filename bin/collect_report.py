#!/usr/bin/env python3

import argparse
from pathlib import Path

import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser(description="Combine quast, fastani and checkm2 reports into one")

    parser.add_argument("--id", type=str, required=True, help="ID of sample")

    parser.add_argument("--quast", type=Path, required=True, help="Path to quast summary report")
    parser.add_argument("--fastani", type=Path, required=True, help="Path to fastani report")
    parser.add_argument("--checkm2", type=Path, required=True, help="Path to checkm2 report")
    parser.add_argument("--mlst", type=Path, required=True, help="Path to mlst report")

    parser.add_argument("--target_size", type=int, required=True, help="Target genome size in bp")
    parser.add_argument("--ani", type=float, required=True, help="Reference ANI % threshold (e.g. 95)")
    parser.add_argument("--completeness", type=float, required=True, help="Threshold CheckM2 completeness score")
    parser.add_argument("--contamination", type=float, required=True, help="Threshold CheckM2 contamination score")
    parser.add_argument("--gc", type=float, required=True, help="Target genome GC content")

    return parser.parse_args()


def qc_row(row, args, size_tol=0.20, gc_tol=0.10):
    """Check a merged row against QC thresholds. Returns (status, failed_fields)."""
    failed = []

    # Total length must be within +/- size_tol of target_size
    low, high = args.target_size * (1 - size_tol), args.target_size * (1 + size_tol)
    if pd.isna(row["Total length"]) or not (low <= row["Total length"] <= high):
        failed.append("Total length")

    # ANI must be >= threshold
    if pd.isna(row["est. ANI"]) or row["est. ANI"] < args.ani:
        failed.append("est. ANI")

    # Completeness must be >= threshold
    if pd.isna(row["Completeness"]) or row["Completeness"] < args.completeness:
        failed.append("Completeness")

    # Contamination must be <= threshold
    if pd.isna(row["Contamination"]) or row["Contamination"] > args.contamination:
        failed.append("Contamination")

    # GC content must be within +/- gc_tol of target gc
    gc_low, gc_high = args.gc * (1 - gc_tol), args.gc * (1 + gc_tol)
    if pd.isna(row["GC_Content"]) or not (gc_low <= row["GC_Content"] <= gc_high):
        failed.append("GC_Content")

    status = "PASS" if not failed else "FAIL"
    return status, ", ".join(failed)


def main():
    args = parse_args()

    quast_df = pd.read_csv(args.quast, sep='\t')
    quast_df = quast_df[['Assembly', 'N50', 'Total length', '# contigs', '# contigs (>= 1000 bp)']]
    quast_df['small contigs'] = (quast_df['# contigs'] - quast_df['# contigs (>= 1000 bp)'])
    quast_df['Proportion Contigs <= 1kbp'] = (quast_df['small contigs'] / quast_df['# contigs'])
    quast_df = quast_df[['Assembly', 'N50', 'Total length', 'Proportion Contigs <= 1kbp']]
    quast_df = quast_df.rename(columns={quast_df.columns[0]: "ID"})

    fastani_df = pd.read_csv(args.fastani, sep='\t', header=None, names=["file", "ref", "est. ANI", "orthos", "fragments"])
    fastani_df = fastani_df[["file", "est. ANI"]]
    fastani_df["file"] = fastani_df["file"].str.replace(r'\.fa$', '', regex=True)
    fastani_df = fastani_df.rename(columns={"file": "ID"})

    checkm2_df = pd.read_csv(args.checkm2, sep='\t')
    checkm2_df = checkm2_df[["Name", "Completeness", "Contamination", "GC_Content", "Total_Coding_Sequences", "Total_Contigs", "Max_Contig_Length"]]
    checkm2_df = checkm2_df.rename(columns={"Name": "ID"})

    mlst_df = pd.read_csv(args.mlst, sep='\t')
    mlst_df["FILE"] = mlst_df["FILE"].str.replace(r'\.fa$', '', regex=True)
    mlst_df = mlst_df[["FILE", "SCHEME", "ST", "ALLELES"]]
    mlst_df = mlst_df.rename(columns={"FILE": "ID"})

    merged_df = quast_df.merge(fastani_df, on="ID", how="outer") \
                        .merge(checkm2_df, on="ID", how="outer") \
                        .merge(mlst_df, on="ID", how="outer")

    merged_df[["QC Status", "QC Failed Fields"]] = merged_df.apply(
        lambda row: pd.Series(qc_row(row, args)), axis=1
    )

    status = merged_df["QC Status"].iloc[0]
    print(status)

    merged_df.to_csv(f"{args.id}_report.tsv", sep='\t', index=None)


if __name__ == "__main__":
    main()
