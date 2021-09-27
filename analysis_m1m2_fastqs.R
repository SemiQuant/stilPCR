require(tidyverse)
m1t1 <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m1T1.depth.tsv", col_names = F)
plot(m1t1$X2, m1t1$X3, type = "l")
axis(side = 1, at=seq(0, max(m1t1$X2), by = 50))

m1t2 <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m1T2.depth.tsv", col_names = F)
plot(m1t2$X2, m1t2$X3, type = "l")
axis(side = 1, at=seq(0, max(m1t2$X2), by = 50))




dat <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m1T1.counts.tsv", col_names = F)
dat$count <- 1

dat$X2[dat$X2 >= 0 & dat$X2 < 20] <- 1
dat$X2[dat$X2 > 230 & dat$X2 < 240] <- 230
dat$X2[dat$X2 > 730 & dat$X2 < 750] <- 739

dat$X3[dat$X3 > 230 & dat$X3 < 255] <- 250
dat$X3[dat$X3 > 450 & dat$X3 < 482] <- 480
dat$X3[dat$X3 > 670 & dat$X3 < 680] <- 673
dat$X3[dat$X3 > 980 & dat$X3 < 990] <- 990


dat_m1t1 <- dat %>% 
  select(-X1) %>% 
  group_by_all() %>% 
  summarise(count = sum(count)) %>% 
  filter(count > 2000) %>% 
  ungroup()
dat_m1t1


require(ggplot2)
m1t1_plot <- ggplot(dat_m1t1, aes(x = X2, xend = X3, y = count, yend = count, color = X4)) + 
  geom_segment() + expand_limits(y=c(0, 600000)) #+ scale_y_continuous(trans='log2')















m2t1 <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m2T1.depth.tsv", col_names = F)
plot(m2t1$X2, m2t1$X3, type = "l")
axis(side = 1, at=seq(0, max(m2t1$X2), by = 50))

# 
# m2t1_2 <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m2T1_2.depth.tsv", col_names = F)
# plot(m2t1_2$X2, m2t1_2$X3, type = "l")
# axis(side = 1, at=seq(0, max(m2t1_2$X2), by = 50))


dat <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/m2T1.bam.counts.tsv", col_names = F)
dat$count <- 1

dat$X3[dat$X3 > 800 & dat$X3 < 850] <- 828
dat$X3[dat$X3 > 950 & dat$X3 < 980] <- 963
dat$X3[dat$X3 > 240 & dat$X3 < 260] <- 250


dat$X2[dat$X2 > 700 & dat$X2 < 750] <- 712
dat$X2[dat$X2 >= 0 & dat$X2 < 20] <- 1


dat_m2t1 <- dat %>% 
  select(-X1) %>% 
  group_by_all() %>% 
  summarise(count = sum(count)) %>% 
  filter(count > 1000) %>% 
  ungroup()
dat_m2t1
sum(dat_m2t1$count)

require(ggplot2)
m2t1_plot <- ggplot(dat_m2t1, aes(x = X2, xend = X3, y = count, yend = count, color = X4)) + 
  geom_segment() + expand_limits(y=c(0, 600000)) #+ scale_y_continuous(trans='log2')






# 
# 
dat <- read_tsv("/Users/SemiQuant/Downloads/30-578401938/00_fastq/test.tsv", col_names = F)
a <- data.frame(table(dat$X4))
b <- data.frame(table(dat$X3))
# 1,231,740
# 250,480,670




670,740+250

0, 422 : 0, 480
441, 950 : 670, 990




cowplot::plot_grid(m1t1_plot, m2t1_plot, labels = c('stilPCT Method 1', 'stilPCT Method 2'))



