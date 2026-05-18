#!/usr/bin/env python3

import sys
import pandas as pd

ID = sys.argv[1]
sylph_out = sys.argv[2]
min_depth = int(sys.argv[3])

df = pd.read_csv(sylph_out, sep='\t')
seq_abundance = float(df['Sequence_abundance'].iloc[0])
ANI = float(df['Adjusted_ANI'].iloc[0])
eff_cov = float(df['Eff_cov'].iloc[0])

if seq_abundance >= 98 and ANI >= 95 and eff_cov >= min_depth:
    print('PASS')
else:
    print('FAIL')
