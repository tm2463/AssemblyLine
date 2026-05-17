#!/usr/bin/env python3

import json
import sys

ID = sys.argv[1]
fastp_out = sys.argv[2]
min_depth = sys.argv[3]
lower_assembly_length = sys.argv[4]

fastp = json.loads(fastp_out)
val = fastp["summary"]["after_filtering"]["total_bases"]

if val >= min_depth * lower_assembly_length:
    print("pass")
else:
    print("fail")
