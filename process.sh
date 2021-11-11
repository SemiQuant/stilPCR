sample="$1"
ref="$2"
primers="$3" # requires samtools >=1.4
threads=1
R1="${sample}_R1_001.fastq.gz"
R2="${sample}_R2_001.fastq.gz"

bam="${sample}.bam"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "$bam"


if [ ! -z "$primers" ]
then
  samtools ampliconclip --tolerance 8 -u --rejects-file "${sample}_NOclipped.bam" -b "$primers" --hard-clip "$bam" | samtools fixmate -@ $threads -O bam - "${sample}_clipped.tmp.bam"
  samtools sort -@ $threads "${sample}_clipped.tmp.bam" -o "${sample}_clipped.bam"
  bam="${sample}_clipped.bam"
fi

samtools index "$bam"
samtools flagstat "$bam" > "${sample}.flagstat.txt"
# samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"
bedtools genomecov -dz -ibam "$bam" > "${sample}.depth.tsv"

samtools view -F 4 "$bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > "${sample}.counts.tsv"
Rscript "stillPCR_plots.R" "${PWD}/${sample}.counts.tsv" "${PWD}/${sample}.depth.tsv"



# samtools ampliconstats -@ $threads "$primers" "${sample}_clipped.bam" -o "${sample}_astats.txt"
# plot-ampliconstats -size 1200,900 mydata "${sample}_astats.txt"

