#!/bin/bash

# Define required variables
required_vars=("ref" "R1" "R2")

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --sample_name)
            sample="$2"
            shift # past argument
            shift # past value
            ;;
        --ref)
            ref="$2"
            shift
            shift
            ;;
        --primers)
            primers="$2"
            shift
            shift
            ;;
        --threads)
            threads="${2:-1}"
            shift
            shift
            ;;
        --script-path)
            script_path="$2"
            shift
            shift
            ;;
        --R1)
            R1="$2"
            shift
            shift
            ;;
        --R2)
            R2="$2"
            shift
            shift
            ;;
        --out_dir)
            out_dir="$2"
            shift
            shift
            ;;
        *)    # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if all required variables have values
missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

# If any required variables are missing, echo the list of required inputs
if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "Missing required inputs: ${missing_vars[*]}"
    echo "Please provide the following files:"
    echo "--ref: The reference genome to align to in FASTA format"
    echo "--R1: The first read file in FASTQ format"
    echo "--R2: The second read file in FASTQ format"
    echo "--primers: path to file containin primer sequences (optinal but recommended, require samtools ≥v1.4)"
    echo "--threads: Number of threads to use for alignment (optinal)"
    echo "--sample: Sample name (def = ${R1/R1*/})"
    echo "--script_dir: path to script dir (def = posix calculated)"
    echo "--out_dir:  path to output dir (def = cwd)"
    exit 1
fi


a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; sdir=$(cd $a; pwd)
script_path="${script_path:-$sdir}"
sample="${sample:-${R1/_R1*/}}"


cd "${out_dir:-.}"

TRIM="${script_path}/Trimmomatic-0.39/trimmomatic-0.39.jar"

R1_trim="${R1%.fastq.gz}.trimmed.fastq.gz"
R2_trim="${R2%.fastq.gz}.trimmed.fastq.gz"

java -jar "$TRIM" PE \
  -threads $threads \
  "$R1" "$R2" \
  "$R1_trim" "${R1%.fastq.gz}.trimmedUmpaired.fastq.gz" \
  "$R2_trim" "${R2%.fastq.gz}.trimmedUmpaired.fastq.gz" \
  ILLUMINACLIP:"${script_path}/Trimmomatic-0.39/adapters/TruSeq3-PE.fa":2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

bam="${sample}.bam"

bwa mem -t $threads "$ref" "$R1_trim" "$R2_trim" > "${sample}.sam"
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

# samtools view -F 4 "$bam" | gawk '{ if ( and($2, 16) == 0 ) { strand="+" } else { strand="-" }; print $3 "\t" $4 "\t" $4 + length($10) "\t"  strand }' > "${sample}.counts.tsv"


# bedtools genomecov -bg -strand + -ibam "$bam" | awk 'BEGIN{FS=OFS="\t+"}{print $0 OFS }' > "${sample}.counts.tsv"
# samtools view -b -F 4 -f 16 "$bam" | bedtools genomecov -bg -ibam - | awk 'BEGIN{FS=OFS="\t-"}{print $0 OFS }' > "${sample}.counts.tsv"
# samtools view -b -F 4 -f 32 "$bam" | bedtools genomecov -bg -ibam - | awk 'BEGIN{FS=OFS="\t+"}{print $0 OFS }' >> "${sample}.counts.tsv"
samtools view -F 4 -f 16 "$bam" | gawk '{ print $3 "\t" $4 "\t" $4 + length($10) "\t-"}' > "${sample}.counts.tsv"
samtools view -F 4 -f 32 "$bam" | gawk '{ print $3 "\t" $4 "\t" $4 + length($10) "\t+"}' >> "${sample}.counts.tsv"

Rscript "${script_path}/stillPCR_plots.R" "${PWD}/${sample}.counts.tsv" "${PWD}/${sample}.depth.tsv"


# samtools ampliconstats -@ $threads "$primers" "${sample}_clipped.bam" -o "${sample}_astats.txt"
# plot-ampliconstats -size 1200,900 mydata "${sample}_astats.txt"

bcftools mpileup --fasta-ref "$ref" \
  --max-depth 999999999 \
  --max-idepth 99999999 \
  --ignore-RG \
  --min-BQ 30 \
  --threads $threads \   # --skip-any-set "UNMAP,SECONDARY,QCFAIL" \
  -Ou \
  --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR \
  "$bam" |
  bcftools call -m --keep-masked-ref --threads $threads \
  --novel-rate 1e-100 \
  --pval-threshold 1.0 \
  --prior 0 \
  --keep-alts > "${sample}.vcf"
  #--variants-only


Rscript "${script_path}/variantAnalysis.R" "${PWD}/${sample}.vcf" "$ref"

# cleanup
rm "${sample}.sam" "${R1%.fastq.gz}.trimmed.fastq.gz" "${R1%.fastq.gz}.trimmedUmpaired.fastq.gz" "${R2%.fastq.gz}.trimmed.fastq.gz" "${R2%.fastq.gz}.trimmedUmpaired.fastq.gz"

