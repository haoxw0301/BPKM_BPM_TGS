library(tidyr)
library(dplyr)

args <- commandArgs(TRUE)

### load data
df <- read.table(args[1], header = FALSE, sep = "\t")

### total number of bases
all_reads <- read.table(args[2], header = FALSE, sep = "\t")

all_reads$length <- all_reads$V3 - all_reads$V2 + 1

### exon base number of each gene
df_2 <- aggregate(df$V13,
                by = list(
                    V4 = df$V10
                ),
                FUN = sum)
names(df_2)[2] <- "base_num"
### exon length of each gene

anno <- read.table(args[4], header = FALSE, sep = "\t") ## exon annotation

anno$exon_length <- anno$V3 - anno$V2 + 1

anno_2 <- aggregate(anno$exon_length,
                by = list(
                    V4 = anno$V4
                ),
                FUN = sum)
names(anno_2)[2] <- "exon_length"

### merge
df_3 <- merge(df_2, anno_2, by = "V4")

## base number per kiobase per million mapped bases, BPKM
df_3$bpkm <- df_3$base_num / df_3$exon_length / sum(all_reads$length) * 1e9

## base number per million mapped bases, BPM
df_3$bpm <- df_3$base_num / sum(all_reads$length) * 1e6

write.table(df_3, args[3],
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)