#!/usr/bin/env python
""" Extracts metaphlan data at every taxonomic level

Walks through every .txt file in a given directory, and for each file, creates
files by taxonomic level in an output folder, writing to the newly created file
only the lines from the original file that match the correct number of
delimiters. Default output path is a subfolder inside the input folder called
"extracted".

Author: Bejan Mahmud, bmahmud@wustl.edu
Edited by: Jessica Tung, jltung@wustl.edu

Args:
    input_path: Path of directory with unprocessed .txt files for extraction
    output_path: (optional) Path of directory to write 

Example Usage:
    > .metaphlanExtract.py .  # if script exists in the same folder as the files
    > .metaphlanExtract.py /path/to/files/  # if script is in a different folder
    > .metaphlanExtract.py /path/to/input/ /path/to/output/
"""

import glob
import os
import re
import sys

TAXONOMY_CATEGORIES = {
    "phyla": 2,
    "class": 3,
    "order": 4,
    "family": 5,
    "genus": 6,
    "species": 7,
}

def _make_if_not_exists(path):
    if not os.path.exists(path):
        print(f"creating folder {path}")
        os.makedirs(path)

def _process_line(line):
    """ return as Tuple (specificity, taxa_name, abundance)
    specificity is the numerical value associated with the specificity of that taxonomy name.
    for example: k__Bacteria|p__Firmicutes|c__Bacilli|o__Lactobacillales|f__Enterococcaceae|g__Enterococcus
      has a specificity of 6 because g__Enterococcus maps to a genus
    See TAXONOMY_CATEGORIES for the mapping. """

    # ignore if starts with #
    if line.startswith("#"):
        return None

    categorization, _, abundance, *_ = line.split("\t")

    # split categorization by |
    categorization = categorization.split("|")

    # return the most specific categorization and abundance
    return (len(categorization), categorization[-1], abundance)

def main(input_path, output_path=None):
    # verify input path exists
    if not os.path.exists(input_path):
        sys.stderr.write(f"Error: input_path={input_path} is not valid")
        sys.exit(1)

    # set default output path if not set
    if output_path is None:
        output_path = os.path.join(input_path, "extracted")
        print(f"setting default output path to {output_path}")

    print(f"running metaphlan extract with input={input_path}, output={output_path}")

    # create output path
    _make_if_not_exists(output_path)

    # create sub-folders inside output
    for taxa in TAXONOMY_CATEGORIES.keys():
        taxa_folder = os.path.join(output_path, taxa)
        _make_if_not_exists(taxa_folder)

    # process every file in input
    path = os.path.join(input_path, "*.txt")
    for file in glob.glob(path):
        # read input file
        input_file = []
        with open(file, "r") as f:
            f.readline() # skip the first line
            input_file = [_process_line(line.strip()) for line in f.readlines()] # read and process lines
            input_file = [v for v in input_file if v is not None]

        # write out taxa specific files
        for taxa, taxa_specificity in TAXONOMY_CATEGORIES.items():
            filename = os.path.basename(file)
            new_file = os.path.join(output_path, taxa, filename.replace(".txt", f"_{taxa}.txt"))
            with open(new_file, "w+") as out_file:
                # write header line
                out_file.write(f"{taxa}\tabundance\n")
                # write relative abundance data
                out_file.write("\n".join([f"{taxa}\t{abundance}" for (s, taxa, abundance) in input_file if s == taxa_specificity]))

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        sys.stderr.write("Error: Invalid number of parameters\n")
        sys.exit(1)

    main(*sys.argv[1:])
