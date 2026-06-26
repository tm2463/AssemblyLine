#!/usr/bin/env python3
import sys

stats_file = sys.argv[1]
threshold  = float(sys.argv[2]) if len(sys.argv) > 2 else 0.8

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
result = "PASS" if pct >= threshold else "FAIL"
print(result)
