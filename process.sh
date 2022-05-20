sample="$1"
ref="$2"
primers="$3" # requires samtools >=1.4
threads=${4:-1}
# Get script dir, posix version
a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; sdir=$(cd $a; pwd)
script_path="${5:-$sdir}"
# R1="${sample}_R1_001.fastq.gz"
# R2="${sample}_R2_001.fastq.gz"
R1="$6"
R2="$7"



cd "$8"

TRIM="${script_path}/Trimmomatic-0.39/trimmomatic-0.39.jar"

java -jar "$TRIM" PE \
  -threads $threads \
  "$R1" "$R2" \
  "${R1/_R1_001.fastq.gz/_R1_001.trimmed.fastq.gz}" "${R1/_R1_001.fastq.gz/_R1_001.trimmedUmpaired.fastq.gz}" \
  "${R2/_R2_001.fastq.gz/_R2_001.trimmed.fastq.gz}" "${R2/_R2_001.fastq.gz/_R2_001.trimmedUmpaired.fastq.gz}" \
  ILLUMINACLIP:"${script_path}/Trimmomatic-0.39/adapters/TruSeq3-PE.fa":2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36


R1="${R1/_R1_001.fastq.gz/_R1_001.trimmed.fastq.gz}"
R2="${R2/_R2_001.fastq.gz/_R2_001.trimmed.fastq.gz}"

bam="${sample}.bam"

bwa mem -t $threads "$ref" "$R1" "$R2" > "${sample}.sam"
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
Rscript "${script_path}/stillPCR_plots.R" "${PWD}/${sample}.counts.tsv" "${PWD}/${sample}.depth.tsv"



# samtools ampliconstats -@ $threads "$primers" "${sample}_clipped.bam" -o "${sample}_astats.txt"
# plot-ampliconstats -size 1200,900 mydata "${sample}_astats.txt"

bcftools mpileup --fasta-ref "$ref" --max-depth 999999999 \
  --ignore-RG \
  --min-BQ 30 \
  --threads $threads \
  --excl-flags "UNMAP,SECONDARY,QCFAIL" \
  --max-idepth 9999999999 \
  -Ou \
  --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR \
  "$bam" |
  bcftools call -m --keep-masked-ref --threads $threads \
  --novel-rate 1e-100 \
  --pval-threshold 1.0 \
  --prior 0 \
  --keep-alts > "${sample}.vcf"
  
  
Rscript "${script_path}/variantAnalysis.R" "${PWD}/${sample}.vcf" "$ref"
