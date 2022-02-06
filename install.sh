#!/bin/bash
sudo apt-get install -y samtools bcftools bwa bedtools r-base
Rscript -e 'install.packages(c("tidyverse", "ggplot2", "cowplot", "plotly", "htmlwidgets", "vcf"), repos="https://cloud.r-project.org")'
