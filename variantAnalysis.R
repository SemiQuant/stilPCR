require(vcfR)
args = commandArgs(trailingOnly=TRUE)
vcf_file <- args[1]
dna_file <- args[2]

vcf <- read.vcfR(vcf_file, verbose = F)
dna <- ape::read.dna(dna_file, format = "fasta")
chrom <- create.chromR(name='Supercontig', vcf=vcf, seq=dna)
plot(chrom)
chromoqc(chrom, dp.alpha=20)

dp <- extract.gt(chrom, element="AD", as.numeric=T)
rownames(dp) <- 1:nrow(dp)
is.na(dp[na.omit(dp == 0)]) <- TRUE
heatmap.bp(dp)


vcf_t <- vcfR2tidy(vcf, single_frame = T)$dat
# vcf_t$meta
# tibble::tribble(
#        ~ID,     ~Type,                                                                                   ~Description,
#    "INDEL",    "Flag",                                                      "Indicates that the variant is an INDEL.",
#      "IDV", "Integer",                                              "Maximum number of raw reads supporting an indel",
#      "IMF",   "Float",                                            "Maximum fraction of raw reads supporting an indel",
#       "DP", "Integer",                                                                               "Raw read depth",
#      "VDB",   "Float", "Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",
#      "RPB",   "Float",                                 "Mann-Whitney U test of Read Position Bias (bigger is better)",
#      "MQB",   "Float",                               "Mann-Whitney U test of Mapping Quality Bias (bigger is better)",
#      "BQB",   "Float",                                  "Mann-Whitney U test of Base Quality Bias (bigger is better)",
#     "MQSB",   "Float",                     "Mann-Whitney U test of Mapping Quality vs Strand Bias (bigger is better)",
#      "SGB",   "Float",                                                                    "Segregation based metric.",
#     "MQ0F",   "Float",                                                    "Fraction of MQ0 reads (smaller is better)",
#       "AC", "Integer",                   "Allele count in genotypes for each ALT allele, in the same order as listed",
#       "AN", "Integer",                                                  "Total number of alleles in called genotypes",
#      "DP4", "Integer",          "Number of high-quality ref-forward , ref-reverse, alt-forward and alt-reverse bases",
#       "MQ", "Integer",                                                                      "Average mapping quality",
#    "gt_PL", "Integer",                                                    "List of Phred-scaled genotype likelihoods",
#    "gt_AD", "Integer",                                                          "Allelic depths (high-quality bases)",
#   "gt_ADF", "Integer",                                    "Allelic depths on the forward strand (high-quality bases)",
#   "gt_ADR", "Integer",                                    "Allelic depths on the reverse strand (high-quality bases)",
#    "gt_GT",  "String",                                                                                     "Genotype"
#   )





