#!/bin/bash
usage() {
    echo "Usage: ${0} [-b | --bam] [-a | --annotation] [-e | --exp_script]
    -b | --bam: the bam file
    -a | --annotation: the annotation file
    -e | --exp_script: the script to calculate the expression level
    -o | --output: the output file
    " 1>&2
    exit 1
}

while getopts b:a:e:o: OPT
do
    case ${OPT} in
        b) bam=${OPTARG} ;;
        a) annotation=${OPTARG} ;;
        e) exp_script=${OPTARG} ;;
        o) output=${OPTARG} ;;
        *) usage ;;
    esac
done

### bed12tobed6
mkdir tmp
bedtools bamtobed -bed12 -i ${bam} > tmp/$(basename ${bam} ".bam").bed12
bedtools bed12tobed6 -i tmp/$(basename ${bam} ".bam").bed12 \
    > tmp/$(basename ${bam} ".bam").bed6

####---- intersect with anation ----####
bedtools intersect -a tmp/$(basename ${bam} ".bam").bed6 \
    -b ${annotation} -wo | uniq \
    > tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed").txt

### calculate the expression level
Rscript ${exp_script} \
    tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed").txt \
    tmp/$(basename ${bam} ".bam").bed6 \
    ${output} \
    ${annotation}

### sense and antisense
if [ $exp_script = "exon_exp_base.R" ] || [$exp_script = "txp_exon_base.R"];
then
    ## sense
    bedtools intersect -a tmp/$(basename ${bam} ".bam").bed6 \
        -b ${annotation} -wo -s | uniq \
        > tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed")_sense.txt

    Rscript ${exp_script} \
        tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed")_sense.txt \
        tmp/$(basename ${bam} ".bam").bed6 \
        ${output}_sense \
        ${annotation}
    ## antisense
    bedtools intersect -a tmp/$(basename ${bam} ".bam").bed6 \
        -b ${annotation} -wo -S | uniq \
        > tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed")_antisense.txt
    
    Rscript ${exp_script} \
        tmp/$(basename ${bam} ".bam")_$(basename ${annotation} ".bed")_antisense.txt \
        tmp/$(basename ${bam} ".bam").bed6 \
        ${output}_antisense \
        ${annotation}
fi
