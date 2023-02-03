library(tidyr)
library(dplyr)

args <- commandArgs(TRUE)

### load data
df <- read.table(args[1], header = FALSE, sep = "\t")

# ### all genes
# txps <- df %>% distinct(
#     V7, V8, V9, V10, .keep_all = FALSE
# )
### total number of bases
all_reads <- read.table(args[2], header = FALSE, sep = "\t")

all_reads$length <- all_reads$V3 - all_reads$V2 + 1

### reads base number of each gene
df_2 <- aggregate(df$V13,
                by = list(
                    V1 = df$V7,
                    V2 = df$V8,
                    V3 = df$V9,
                    V4 = df$V10,
                    V5 = df$V11,
                    V6 = df$V12
                ),
                FUN = sum)

names(df_2)[7] <- "base_num"
df_2$txp_length <- df_2$V3 - df_2$V2 + 1

## base number per kiobase per million mapped bases, BPKM
df_2$bpkm <- df_2$base_num / df_2$txp_length / sum(all_reads$length) * 1e9

## base number per million mapped bases, BPM
df_2$bpm <- df_2$base_num / sum(all_reads$length) * 1e6

write.table(df_2, args[3],
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)

