#!/usr/bin/env python3

import sys

if __name__ == "__main__":
    ID = sys.argv[1]
    stats_file = sys.argv[2]
    threshold  = float(sys.argv[3]) if len(sys.argv) > 3 else 0.8

    total, mapped = None, None

    with open(stats_file) as f:
        for line in f:
            fields = line.strip().split('\t')
            if fields[0] == 'raw total sequences:':
                total = int(fields[1])
            elif fields[0] == 'reads mapped:':
                mapped = int(fields[1])

    if total is None or mapped is None:
        sys.exit("ERROR: could not parse total/mapped reads from stats file")

    if total == 0:
        sys.exit("ERROR: total reads is 0")

    pct = mapped / total

    if pct >= threshold:
        print("PASS")
    else:
        print("FAIL")
        with open(f"{ID}.fail", "w") as f:
            f.write(f"{ID} failed mapping filter: mapped reads ({mapped}) / total reads ({total}) = {pct:.2f} < threshold ({threshold})\n")
