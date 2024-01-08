# Looking at DifCover output (.DNAcopyout) - https://github.com/timnat/DifCover

# Guidance and code help from Phil Grayson, with some modifications

library(tidyverse)

setwd("~/Dropbox/killer_whale_genomics/DifCover")

# Enter in file infos
DNAcopyout ="ARPI_2013_4007__KW_2020_PG_09.ratio_per_w_CC0_a6_A54_b7_B60_v1000_l500.log2adj_1.111.DNAcopyout"
scaffold_info="KW_GCA_937001465.1_mOrcOrc1.1_genomic.fasta.fai"

# Some more labels for later (plot title/label)
sample1="ARPI_2013_4007"
sample2="KW_2020_Pg_09"

# Load in data, rename columns, and add bp spanned. Enrichment score: log2(sample1 coverage/sample2 coverage)
difcover <- read_tsv(file = DNAcopyout ,col_names = F) %>% 
  rename(scaf = X1, start = X2, stop = X3, windows = X4, enrichment_score = X5) %>% 
  mutate("bases spanned" = stop-start)

# Use fasta.fai for scaffold name and length
scaffold_lengths <- read_tsv(scaffold_info,col_names = c("scaf","length"))
scaffold_lengths <- scaffold_lengths[c("scaf", "length")]

# Join with difcover output
proportion <- full_join(difcover,scaffold_lengths) %>% 
  mutate(proportion = `bases spanned`/length)

# Initial plot of proportion of scaffold versus log2(male/female) coverage
proportion %>% 
  ggplot(aes(x=enrichment_score, y=proportion)) + 
  geom_point()+
  xlab("enrichment score")
  #geom_vline(xintercept=0, col="red")

# For killer whale, X chromosome is scaffold OW443365.1

# highlight scaffold OW443365.1
xchr <- subset(proportion, scaf=="OW443365.1")

proportion %>% 
  ggplot(aes(x=enrichment_score, y=proportion)) + 
  geom_point()+
  geom_point(data=xchr, aes(x=enrichment_score, y=proportion), color="orange")+
  xlab("enrichment score")

# Try without unplaced scaffolds
fullchr <- proportion[grepl("OW", proportion[["scaf"]]),]

fullchr %>% 
  ggplot(aes(x=enrichment_score, y=proportion)) + 
  geom_point()+
  geom_point(data=xchr, aes(x=enrichment_score, y=proportion), color="orange")+
  xlab("enrichment score")

ggsave(paste(sample1, "__", sample2, "_","_coverageplot_fullchr",".png",sep=""), width = 10, height = 6, dpi = 300)

