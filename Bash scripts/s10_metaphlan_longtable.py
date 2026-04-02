"""
Creates a long table in a directory, given a folder from metaphlan_Extract.

Author: Jessica Tung, j.l.tung@wustl.edu

Parameters:
    input_path: folder with output from metaphlan_Extract. Should contain .txt files
    output_file_name: (optional) file name of output tsv. defaults to longtable.csv
    trailing: (optional) the trailing text to remove while creating the sample column. Defaults to `.txt`

Output:
    A .csv file with three columns: sample, species, abundance. Sample is the name of the input file minus `trailing`

Example usage:
    $ python3 metaphlan_longtable.py /path/to/metaphlan/extracted/species/ name_of_output.csv _profile_species.txt

"""

import os
import sys
import glob

def create_long_table(input_path, output_file_name="longtable.csv", trailing=".txt"):
    # open output file
    output_file_path = os.path.join(input_path, output_file_name)
    with open(output_file_path, "w+") as output_file:
        # write header
        output_file.write(f"sample,taxa,abundance\n")

        # for each file in the folder
        path = os.path.join(input_path, "*.txt")
        for file in glob.glob(path):
            # get the sample name from the file name
            sample_name = os.path.basename(file).rstrip(trailing)

            # process file
            with open(file, "r") as in_file:
                in_file.readline() # skip the header

                # write to output
                for line in in_file.readlines():
                    line = line.strip().split("\t")

                    if len(line) != 2:
                        sys.stderr.write(f"skipping malformed line in {sample_name}: {line}\n")
                        continue

                    taxa, abundance = line
                    output_file.write(f"{sample_name},{taxa},{abundance}\n")

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 4:
        sys.stderr.write("Error: Invalid number of parameters\n")
        sys.stderr.write("Usage: python3 create_long_table.py input_path [output_file_name] [trailing]\n")
        sys.stderr.write("Example: python3 create_long_table.py extracted/species/ species_long_table.csv _species.txt\n")
        sys.exit(1)

    create_long_table(*sys.argv[1:])
