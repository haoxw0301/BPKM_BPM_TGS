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
        b) i=${OPTARG} ;;
        a) annotation=${OPTARG} ;;
        e) exp_script=${OPTARG} ;;
        o) output=${OPTARG} ;;
        *) usage ;;
    esac
done

### bed12tobed6
bedtools bamtobed -bed12 -i ${i}
bedtools bamtobed -bed12 -i ${i} > $(basename ${i} ".bam").bed12
bedtools bed12tobed6 -i $(basename ${i} ".bam").bed12 > $(basename ${i} ".bam").bed6

####---- intersect with anation ----####
bedtools intersect -a $(basename ${i} ".bam").bed6 -b ${annotation} -wo | uniq \
    > exp/${i}_$(basename ${annotation} ".bed").txt

### calculate the expression level
Rscript ${exp_script} \
    exp/${i}_$(basename ${annotation} ".bed").txt \
    $(basename ${i} ".bam").bed6 \
    ${output} \
    ${annotation}
