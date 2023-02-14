#!/bin/bash

#############################################################################
#NOTE: READ BEFORE RUNNING!

#Calculate LD scores
#Files needed:
#.bed/.bim/.fam
#.cov/.pheno
#input the number of samples too
#############################################################################

usage="$(basename "$0") [-h] [-b str] [-c str] [-p str] [-n int] -- Script to calculate summary statistics, LD scores and heritabilty, given PLINK formatted files.

WARNING: please specify the entire path of your files.

options:
    -h	help text
    -b	path to the PLINK formatted .bed/.bim/.fam files
    -p	path to the phenotype file
    -c	path to the covariate file
    -n	number of samples"
    
#Input arguments
e=0;z=0;v=0;i=0;h=0;t=1;
while getopts “hb:p:n:c:” option 
do 
		case "$option" in 
			h) echo "$usage";exit;;
			b) bfile=$OPTARG;;
			p) pheno=$OPTARG;;
			c) cov=$OPTARG;;
			n) nsample=$OPTARG;;
		esac 
done 

#conda create and activate envt
conda env update --file environment.yml
source activate
conda activate ldsc
ldscout="${bfile}.LDSC"
#Generate LD scores
./ldsc.py --bfile $bfile --l2 --ld-wind-cm 1 --out $ldscout --yes-really
#GWAS
plink --bfile $bfile --logistic --out $bfile --keep-allele-order  --pheno $pheno --allow-no-sex --threads 10 --ci 0.95 --freq --covar $cov
#summary stat file formating
assoc="${bfile}.assoc.logistic"
assoc_ldsc="${assoc}.LDSC"
awk -F' ' '{print $2,$2,$6,$7,$12}' $assoc | tr ' ' $'\t' | sed 's/:/\t/;s/:/\t/;s/:/\t/' | awk -F'\t' '{print $5,$4,$3,$8,$7,$6}' | tr ' ' $'\t' | tail -n +2 > $assoc_ldsc
sed  -i '1i SNP\tA1\tA2\tP\tOR\tN' $assoc_ldsc #adding headers
#Using munge_sumstats to inalize the format
./munge_sumstats.py --sumstats $assoc_ldsc --N 20 --out $assoc_ldsc --snp SNP --N-col N --a1 A1 --a2 A2 --p P --signed-sumstats OR,1
#heritabilty
assoc_ldsc_munge="${assoc_ldsc}.sumstats.gz"
./ldsc.py --h2 $assoc_ldsc_munge --ref-ld $ldscout --w-ld $ldscout --out $ldscout