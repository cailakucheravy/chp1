
#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#
#BiocManager::install("Omixer")

library(Omixer)
library(tidyverse)

# Load samples
sample_data <- read.csv('epigenetic_sample_list.csv') 
view(sample_data)
  
# Specify randomization variables
randVars <- c('Year', 'Species', 'Location') 
# Specify technical variables on which to test relationships
techVars <- c('row', 'chipPos')
# Specify number of plates in sample batch
n_plates <- 1

# Specify layout for mammal chip (96 per array, 8 chips, 12 samples per chip in 2 cols)
# The sample plate has 8 rows labeled A-H and 12 numbered columns
# Repeat the layout for each number of plates (i.e., n_plates)
# 
# We need to block by column (i.e., split column in half so that each side of a
# chip is blocked)
# To make sure this happens, first make each column 1:6 (i.e., half a column
# long), then block by "col-block". After the randomization, switch column back
# to rep(1-12), each = 8
layout <- tibble(plate = rep(1:n_plates, each = 96),
                 well = rep(1:96, n_plates), 
                 row = rep(rep(LETTERS[1:8], each = 12), n_plates), 
                 column = rep(rep(1:12, 8), n_plates),
                 chip = rep(rep(1:8, each = 12), n_plates), 
                 chipPos = rep(rep(1:6, 16), n_plates),
                 mask = 0)

# Run randomization
# We want everything to be under 0.05
omix_whales <- omixerRand(sampleId = 'Specimen_ID', 
                         df = sample_data, 
                         block = 'Individual_ID',     # Need to keep duplicates together 
                         iterNum = 500,
                         randVars = randVars,
                         div = "col-block", 
                         layout = layout,
                         techVars = techVars,
                         positional = T)

view(omix_whales)

# Save the randomizations by current date
#write.csv(omix_whales, paste0('whale_randomizations_', Sys.Date(), '.csv'))
#saveRDS(omix_whales, paste0('whale_randomizations_', Sys.Date(), '.rds'))
