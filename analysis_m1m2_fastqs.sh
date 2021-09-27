# stilPCRm1T1_R1_001.fastq.gz
# stilPCRm1T1_R2_001.fastq.gz
sample="m1T1"
ref="m1.fasta"
R1="stilPCRm1T1_R1_001.fastq.gz"
R2="stilPCRm1T1_R2_001.fastq.gz"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"

samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > ${sample}.counts.tsv

# stilPCRm1T2_R1_001.fastq.gz
# stilPCRm1T2_R2_001.fastq.gz
sample="m1T2"
ref="m1.fasta"
R1="stilPCRm1T2_R1_001.fastq.gz"
R2="stilPCRm1T2_R2_001.fastq.gz"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"



# stilPCRm2T1_R1_001.fastq.gz
# stilPCRm2T1_R2_001.fastq.gz
sample="m2T1"
ref="m2.fasta"
R1="stilPCRm2T1_R1_001.fastq.gz"
R2="stilPCRm2T1_R2_001.fastq.gz"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"

samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > ${sample}.counts.tsv

















# stilPCRm1T1_R1_001.fastq.gz
# stilPCRm1T1_R2_001.fastq.gz
sample="m1T1_atpe"
ref="m1_atpe.fasta"
R1="stilPCRm1T1_R1_001.fastq.gz"
R2="stilPCRm1T1_R2_001.fastq.gz"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"

samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > ${sample}.counts.tsv




# stilPCRm2T1_R1_001.fastq.gz
# stilPCRm2T1_R2_001.fastq.gz
sample="m2T1_atpe"
ref="m2_atpe.fasta"
R1="stilPCRm2T1_R1_001.fastq.gz"
R2="stilPCRm2T1_R2_001.fastq.gz"

bwa mem "$ref" "$R1" "$R2" > "${sample}.sam"
samtools view -bS "${sample}.sam" | samtools sort - > "${sample}.bam"
samtools index "${sample}.bam"
samtools flagstat "${sample}.bam"
samtools depth -a "${sample}.bam" -o "${sample}.depth.tsv"

samtools view -F 4 "${sample}.bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > ${sample}.counts.tsv





