#!/usr/bin/env python
import re
import numpy as np
import pandas as pd
import argparse

#the following function takes in all taxonomy paths contained in filtered sample profiler output and creates a complete list of one of each taxonomy
def qiime_taxmerge(taxonomylist):
    complete_taxons = pd.DataFrame()
    for taxonpath in taxonomylist:
        taxonpath = re.sub(".*(?=\\/).", "", taxonpath)
        taxonpath = re.sub("\n", "", taxonpath)
        taxon_toadd = pd.read_csv(taxonpath, sep="\t")
        complete_taxons = pd.concat([complete_taxons, taxon_toadd]).drop_duplicates()

    complete_taxons.to_csv("allsamples_taxonomylist.tsv", index=False, sep="\t")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Merge together all taxonomy file output""")
    parser.add_argument("-t", "--taxonomy_data", dest="taxonomylist", nargs='+', type=str, help="list of taxonomic files")
    args = parser.parse_args()
    qiime_taxmerge(args.taxonomylist)
