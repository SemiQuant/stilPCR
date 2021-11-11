# stilPCR

In DEV.
Analysis of Illumina amplicon sequencing. The program will trim off the primer sequences (so they do not interfere with variant calling), produce numerous plots of the data, and call variants.

## process.sh
### Process fastq and create plots/ call variants
bash process.sh "Sample Name (excluding the RX_001.fastq.gz)" "path to reference fasta" "primer bed file (optional for primer trimming; requires samtools >=1.4)" "threads, default = 1"

## variantAnalysis.R
### Create plots of variants
To add, variant calling and summary (will be using the DP and AD, may also change the call behaviour of bcftools)

## Required software
- [samtools >=1.4](http://www.htslib.org/download/)
- [bcftools >=1.4](http://www.htslib.org/download/)
- [bwa >= 0.7.17](https://sourceforge.net/projects/bio-bwa/files/)
- [bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html)


R packages
- vcfR
- tidyverse
- ggplot2
- cowplot
- plotly
- htmlwidgets
