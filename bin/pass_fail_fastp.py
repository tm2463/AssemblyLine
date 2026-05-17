#!/usr/bin/env python3

import json
import sys

ID = sys.argv[1]
fastp_out = sys.argv[2]
min_depth = int(sys.argv[3])
lower_assembly_length = int(sys.argv[4])

with open(fastp_out) as f:
    fastp = json.load(f)

val = fastp["summary"]["after_filtering"]["total_bases"]

if val >= min_depth * lower_assembly_length:
    print('PASS')
else:
    print('FAIL')
