# BPKM_BPM_TGS
calculate the expression level for long reads RNA-seq based on the base number

## main_exp.sh

the main pipeline to calculate the expression level for long reads by using the base number

## calculate BPKM and BPM

### txp_exp_base.R

calculate the expression level for each transcript or single element by using the base number

### exon_exp_base.R

calculate the expression level for each exon or intron by using the base number

## usage

```bash
./main_exp.sh -b <bamfile> -a <annotionfile> -e <Rscript>
```

### options

-b / --bam: bamfile;\
-a / --annotation: annotation file which should cantain six columns and the fourth column should be the gene name;\
-e /--exp_script: Rscript to calculate the expression level (txp_exp_base.R or exon_exp_base.R).
