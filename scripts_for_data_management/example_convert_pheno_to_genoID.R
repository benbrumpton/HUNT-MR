#!/usr/bin/env Rscript
#Create a file with the phenotypes, covariates and the genotype ID

# Read master key file
key <- read.table(gzfile("/mnt/work/genotypes/DATASET_20161002/SAMPLE_QC/Masterkey_DATASET.20161002.txt.gz"), header=T)

# Read the phenotype bridge
library(foreign)
bridge <- read.spss("/mnt/work/bridge/bridges-from-hunt/Gunnhild_Aaberg_Vie/PID@107167-PID@105118.sav", to.data.frame=T) # Read in the bridge

# Merge the masters key with the bridge
names(bridge)[names(bridge)=="PID.105118"] <- "gid.current" # Rename bridge file
tmp <- merge(key, bridge, by="gid.current", sort=F)

# Add constructed pheno
custom_pheno <- read.table("/mnt/cargo/benb_in/bmi_for_gwas_2.csv", header=T, , sep = '\t', as.is=T)

# Check pheno PID and bridge PID are the same and correct if need be as below
names(custom_pheno)[names(custom_pheno)=="PID_107167"] <- "PID.107167" # Rename pheno

# merge tmp (bridge+key) with phenotype 
tmp2 <- merge(tmp, custom_pheno, by='PID.107167', all.y=T)

# restrict file to columns needed for analysis
#pheno_names <- names(pheno)
pheno_names <- c("zresbmi", "zbmi", "age", "male", "age_sq") # Add the phenotypes or cov from this file

# add PATID and MATID for BOLT-LMM
tmp2$PATID <- 0
tmp2$MATID <- 0

final <- tmp2[,c("FID", "IID", "PATID", "MATID", pheno_names, "BatchDetailed",
"Sex", "BirthYear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10",
"PC11", "PC12", "PC13", "PC14", "PC15", "PC16", "PC17", "PC18", "PC19", "PC20", "Ancestry4",
"UNRELATED", "batch")]

final2 <- unique(final)

# Save this as a text file to use in anlaysis
write.table(final2, "~/projects/bmi_hunt1/test_pheno_genotypeID.txt",row.names=F,quote=F, col.names=T, sep = "\t") 
