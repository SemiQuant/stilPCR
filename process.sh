sample="$1"
ref="$2"
R1="${sample}_R1_001.fastq.gz"
R2="${sample}_R2_001.fastq.gz"


bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam" > "${sample}.flagstat.txt"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"

#samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > "${sample}.counts.tsv"
samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { print $3 "\t" $4 "\t" $4 - length($10) "\t" "+" } else { print $3 "\t" $4 "\t" $4 + length($10) "\t" "-"}}' > "${sample}.counts.tsv"

Rscript "stillPCR_plots.R" "${PWD}/${sample}.counts.tsv"
