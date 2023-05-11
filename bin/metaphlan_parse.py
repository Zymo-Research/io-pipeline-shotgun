#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np
import re

def metaphlan_profileparse(headertext, mpa_profiletable, label):
    
    #Retrieve number of unknown reads

    #Process Metaphlan4 input table
    
    #For relative abundance: remove all entries that are not on species level
    profile = pd.read_csv(mpa_profiletable, sep="\t")
    profile = profile[["clade_name", "relative_abundance"]]
    profile.columns = ["clade_name",label]
    profile = profile[profile["clade_name"].str.contains("s__") == True]
    profile = profile[profile["clade_name"].str.contains("t__") == False]
    profile.to_csv((label+"_parsed_mpaprofile.txt"), sep="\t", index=False)
    
    #Formatting supplemental taxonomy table needed by qiime2
    #Column names MUST be "Feature ID", "Taxon"
    taxonomy = pd.DataFrame(profile["clade_name"].str.replace("|", ";", regex=False))
    taxonomy = pd.concat((profile["clade_name"], taxonomy), axis=1)
    taxonomy.columns = ["Feature ID", "Taxon"]
    taxonomy.to_csv(label+"_profile_taxonomy.txt", sep="\t", index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Parse metaphlan table""")
    parser.add_argument("-i", "--infotext", dest="headertext", type=str, help="header text from metaphlan that contains unassigned read info")
    parser.add_argument("-t", "--mpa_table", dest="mpa_profiletable", type=str, help="metaphlan assigned reads")
    parser.add_argument("-l", "--label", dest="label", type=str, help="sample label")
    args = parser.parse_args()
    metaphlan_profileparse(args.headertext, args.mpa_profiletable, args.label)
