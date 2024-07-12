#!/bin/python
import sys
import os
import vcf
import pandas as pd
input_vcf_path = sys.argv[1]
bed_file_path = sys.argv[2]

# Read the BED file into a pandas DataFrame
bed_df = pd.read_csv(bed_file_path, sep='\t', comment='#', header=None, names=["CHROM", "START", "END"])
nm = os.path.splitext(os.path.basename(input_vcf_path))[0]
output_vcf_path = nm + "_adjusted_positions.vcf"
output_csv_path = nm + "_adjusted_positions.csv"

# Open the input VCF file
vcf_reader = vcf.Reader(open(input_vcf_path, "r"))

# Create a new VCF writer for the output file
vcf_writer = vcf.Writer(open(output_vcf_path, "w"), vcf_reader)

# Iterate through each record (variant) in the input VCF
for record in vcf_reader:
    if record.CHROM == gyrAB_nanoUMI_ln_v2b_3 and record.POS >= 243:
        record.POS = record.POS + 243
    else:
        start_values = bed_df[bed_df['CHROM'] == record.CHROM]['START'].astype(int)[0]
        end_values = bed_df[bed_df['CHROM'] == record.CHROM]['END'].astype(int)[0]
        record.POS = record.POS - start_values
        if record.POS > end_values - start_values:
            record.CHROM = record.CHROM + "_upstream"
    # Write the modified record to the output VCF file
    vcf_writer.write_record(record)

# Close the VCF writer
vcf_writer.close()

# Open the input VCF file using PyVCF
vcf_reader = vcf.Reader(open(output_vcf_path, "r"))

# Create lists to hold the extracted data
chromosomes = []
positions = []
read_depths = []
freq = []
pval = []

# Extract data from the VCF file
for record in vcf_reader:
    chromosomes.append(record.CHROM)
    positions.append(record.POS)
    read_depths.append(record.samples[0]["DP"])
    freq.append(record.samples[0]["FREQ"])
    pval.append(record.samples[0]["PVAL"])

# Create a pandas DataFrame from the extracted data
vcf_df = pd.DataFrame({
    "CHROM": chromosomes,
    "POS": positions,
    "ReadDepth": read_depths,
    "ReadDepth": read_depths,
    "FREQ": freq,
    "PVAL" : pval
})

vcf_df.to_csv(output_csv_path, index=False)