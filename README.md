# stilPCR

<div>
    <img src="https://github.com/SemiQuant/stilPCR/blob/main/sq.png" width="30%" height="30%">
    <img src="https://github.com/SemiQuant/stilPCR/blob/main/drdx.png" width="30%" height="30%">
    <p>Analysis primer design and analysis for hissPCR (link to protocols.io)</p>
</div>

Analysis of Illumina amplicon sequencing. The program will trim off the primer sequences (so they do not interfere with variant calling), produce numerous plots of the data, and calls variants. Outputs will be in the cwd.

>bash stilPCR.sh \
>  --R1 "test_data/read_R1_001.fastq.gz" \
>  --R2 "test_data/read_R2_001.fastq.gz" \
>  --ref "refs/BDQ_duplex.fasta" \
>  --primers "refs/primers.bed"


| Flag              | Description                                                       |
|-------------------|-------------------------------------------------------------------|
| -t\|--threads     | number of threads (def = 1)                                       |
| -n\|--sample_name | sample name (def = ${R1/R1*/})                                    |
| -1\|--R1          | path to read 1 (required)                                         |
| -2\|--R2          | path to read 2 (required)                                         |
| -f\|--ref         | path to reference fasta (required)                                |
| -p\|--primers     | path to file containin primer sequences (optinal but recommended, requires samtools ≥v1.4) |
| -d\|--script_dir  | path to script dir (def = posix calculated)                       |
| -o\|--out_dir     | path to output dir (def = cwd)                                    |
| -a\|--adj         | path to bed file of reference positions to adjust                 |


#### Primers bed file
This file is highly recommended as otherwise primers will be used to call variants (or the lack of variants)
The file must contain three columns, in the first, the chromosome name matching the name in the reference fasta file, second, the start of where this primer binds to the reference sequence, and third, when the binding ends.
for example

>$cat primers.bed

```
Rv0678	0	20
Rv0678	421	441
```

#### Variant adjustment bed file
The file must contain three columns, in the first, the chromosome name matching the name in the reference fasta file, second, the gene start (this value can be negative if the primers target a portion withing the gene) and third, when the gene ends.


## Required software
These can be installed on linux systems by running 
>./install.sh

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
