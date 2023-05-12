#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np
import re

def qiimebarplot_tomultiqc(table, levelnum):
    f = pd.read_csv(table, sep=",")
    #Drop first unecessary column
    f=f.transpose()
    f.columns = f.iloc[0]
    f = f.iloc[1:,:]
    f.insert(0, "#OTU ID", f.index)

    f.to_csv("allsamples_exported_QIIME_barplot/level-"+levelnum+".csv", index=False, header=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Parse metaphlan table""")
    parser.add_argument("-d", "--dataframe", dest="table", type=str, help="output csv from qiime barplot export")
    parser.add_argument("-l", "--levelnum", dest="levelnum", type=str, help="level number")
    args = parser.parse_args()
    qiimebarplot_tomultiqc(args.table, args.levelnum)
