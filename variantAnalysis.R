require(vcfR)
require(tidyverse)
require(plotly)
require(htmlwidgets)
args = commandArgs(trailingOnly=TRUE)
vcf_file <- args[1]
dna_file <- args[2]

nme <- gsub(".vcf", "", basename(vcf_file))

vcf <- read.vcfR(vcf_file, verbose = F)
dna <- ape::read.dna(dna_file, format = "fasta")
chrom <- create.chromR(name='Supercontig', vcf=vcf, seq=dna)


pdf(paste0(nme, "_info1.pdf"))
plot(chrom)
dev.off()

pdf(paste0(nme, "_info2.pdf"))
chromoqc(chrom, dp.alpha=20)
dev.off()


dp <- extract.gt(chrom, element="AD", as.numeric=T)
rownames(dp) <- 1:nrow(dp)
is.na(dp[na.omit(dp == 0)]) <- TRUE

pdf(paste0(nme, "_info3_ADs.pdf"))
heatmap.bp(dp) # this is really for many files and DP
dev.off()


vcf_t <- vcfR2tidy(vcf, single_frame = T)$dat
# vcf_t$meta


vcf_t <- vcf_t %>% 
  mutate(ALT = ifelse(INDEL, "INDEL", ALT))

if (max(str_count(vcf_t$ALT, ","), na.rm = T) > 2)
  print("cant handel this!!")

vcf_t <- vcf_t %>% 
  select("CHROM", "POS", "REF", "ALT", "QUAL", "INDEL", "DP", "AC", "AN", "Indiv", 
         "gt_AD", "gt_ADF", "gt_ADR", "gt_GT", "gt_GT_alleles") %>% 
  separate(gt_AD, c("AD_REF", "AD1", "AD2", "AD3")) %>% 
  separate(ALT, c("ALT1", "ALT2", "ALT3")) %>% 
  replace_na(list(AD1 = 0, AD2 = 0, AD3 = 0)) %>% 
  type_convert() %>% 
  mutate(DP = AD_REF + AD1 + AD2 + AD3) %>% # convert DP to only HQ base count
  mutate(ADrefp = round(AD_REF/DP*100, 2),
         AD1p = round(AD1/DP*100, 2),
         AD2p = round(AD2/DP*100, 2),
         AD3p = round(AD3/DP*100, 2))


# 
# # making it so the indels are seperated, at the bottom of the plot
# vcf_t <- vcf_t %>% 
#   mutate(ADrefp = ifelse(INDEL, ADrefp*-1, ADrefp),
#          AD1p = ifelse(INDEL, AD1p*-1, AD1p),
#          AD2p = ifelse(INDEL, AD2p*-1, AD2p),
#          AD3p = ifelse(INDEL, AD3p*-1, AD3p))
# )


# this is a bullshit way to do things! Fix it.

vcf_t <- vcf_t %>%
  select("Indiv", "CHROM", "POS", "ADrefp", "AD1p", "AD2p", "AD3p", 
         "REF", "ALT1", "ALT2", "ALT3") %>% 
  pivot_longer(cols = !Indiv:AD3p, 
               names_to = "Depth", 
               values_to = "Call") %>% 
  filter(!is.na(Call)) %>% 
  mutate(Call = ifelse(Depth == "REF", "REF", Call)) %>% 
  mutate(Depth = ifelse(Depth == "REF", ADrefp,
                        ifelse(Depth == "ALT1", AD1p,
                               ifelse(Depth == "ALT2", AD2p,
                                      AD3p
                               ))))


# if theres an indel, then this breaks, I'm sleepy so fix properly later
vcf_t <- vcf_t %>%
  group_by(Indiv, CHROM, POS, Call) %>% 
  summarize(Depth = mean(Depth))






varplots <- list()
count <- 1
for (chr in unique(vcf_t$CHROM)){
  varplots[[count]] <-  vcf_t %>% 
    filter(CHROM == chr) %>% 
    plot_ly(x = ~POS, y = ~Depth, type = 'bar', 
            color = ~Call) %>%
    layout(barmode = 'stack',
           yaxis = list(title = "Percentage"),
           xaxis = list(title = paste("Position in", chr)))
  
  count <- count + 1
}

var_plot <- subplot(varplots,
                    shareY = T, titleX = T)


try({
  saveWidget(as_widget(var_plot), paste0(nme, "_varPlot.html"), selfcontained = T)
})





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