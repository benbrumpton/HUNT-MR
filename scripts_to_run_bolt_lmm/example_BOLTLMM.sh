#!/bin/bash

prefix=/home/benb/archive/benb/OwnBW/OwnBW

dosageFileIn=/mnt/scratch/hunt24chunks/PART_${chunk}.dose.gz
dosageResults=${prefix}_BOLTLMM_PART_${chunk}.imputed.results.txt
genotypeResults=${prefix}_BOLTLMM_PART_${chunk}.genotyped.results.txt
logfile=${prefix}_BOLTLMM_PART_${chunk}.log.txt
phenoIn=/home/benb/archive/benb/OwnBW/OwnBW_pheno.txt
timefile=${prefix}_BOLTLMM_PART_${chunk}.time.txt

/usr/bin/time -o ${timefile} -v	\
/home/benb/source/boltlmm/BOLT-LMM_v2.3/bolt	\
	--bfile=/mnt/scratch/hunt24chunks/genotyped	\
	--statsFile=${genotypeResults}	\
	--dosageFile=${dosageFileIn}	\
	--dosageFidIidFile=/mnt/scratch/hunt24chunks/FidIid.txt	\
	--statsFileDosageSnps=${dosageResults}	\
	--phenoFile=${phenoIn}	\
	--phenoCol=OwnBW	\
	--covarFile=${phenoIn}	\
	--covarCol=batch		\
	--covarCol=Sex		\
	--qCovarCol=BirthYear		\
	--qCovarCol=PC1		\
	--qCovarCol=PC2		\
	--qCovarCol=PC3		\
	--qCovarCol=PC4		\
	--qCovarCol=GA_days		\
	--lmm	\
	--verboseStats	\
	--LDscoresFile=/home/benb/source/boltlmm/BOLT-LMM_v2.3/tables/LDSCORE.1000G_EUR.tab.gz	\
	--LDscoresMatchBp	\
	--geneticMapFile=/home/benb/source/boltlmm/BOLT-LMM_v2.3/tables/genetic_map_hg19_withX.txt.gz	\
	--numThreads=1	\
	> ${logfile}
