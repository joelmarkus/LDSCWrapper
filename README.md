# LDSCWrapper

**Script to calculate summary statistics, LD scores and heritabilty, given PLINK formatted files, and using the [LDSC python code](https://github.com/bulik/ldsc)**

Download the original python code and place the ./LDSC.sh file into the folder.

```
git clone https://github.com/bulik/ldsc.git
cd ldsc
```

**Files required:**

- PLINK formatted .bed/.bim/.fam files
- Covariate file
- Phenotype file
- Number of samples

**Usage:**

./LDSC.sh -b \<PLINK formatted file\> -c \<covarite file\> -p \<phenotype file\> -n \<number of samples\>
