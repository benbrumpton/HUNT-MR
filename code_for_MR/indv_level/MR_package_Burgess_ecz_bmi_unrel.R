#install.packages("MendelianRandomization")
#install.packages("tibble")
#install.packages("xlsx")
library(tibble)
library(MendelianRandomization)
#library(xlsx)
#library(devtools)
#library(tidyverse)

#read in exposure ~ G associations
#choose.files()
#exposure <- read.csv2("M:\\Projects\\Ellen\\results\\ECZ_single_snp_summary_unrel_v2.csv", 
#                      as.is=T, sep = ",", header = T, dec=".")
exposure <- read.csv2("/Volumes/benb/Projects/Ellen/results/ECZ_single_snp_summary_unrel_v2.csv", 
                      as.is=T, sep = ",", header = T, dec=".")
head(exposure)
str(exposure)
outcome <- read.csv2("/Volumes/benb/Projects/Ellen/results/ECZ_single_snp_on_BMI_summary_unrel_v2.csv",
                     as.is=T, sep = ",", header = T, dec=".")
head(outcome)
str(outcome)

#define bx and by, where x = exposure and y= outcome

bx <- exposure$Beta
bxse <- exposure$SE

by <- outcome$Beta
byse <-outcome$SE

#create MR_object
MR_object <- mr_input(bx, bxse, by, byse, exposure="Eczema", outcome="BMI",
                      snps=exposure$SNP, effect_allele = exposure$EA
                  )

#perform various analysis:
MR_egger<- mr_egger(MR_object)

#for I.sq
MR_egger$I.sq

#for intercept p-value
MR_egger$Pleio.pval

#IVW <- mr_median(MR_object, weighting = "weighted") #will perfrom Median Weighted MR
#IVW_simple <- mr_median(MR_object, weighting = "simple") #will perfrom Median Weighted MR
#all_methods <- mr_allmethods(MR_object) #all results
main_methods <-mr_allmethods(MR_object, method= "main")
main_methods_results <- main_methods@Values
colnames(main_methods_results)[4] <- "L95"
colnames(main_methods_results)[5] <- "U95"
main_methods_results$Egger_I.sq <- MR_egger$I.sq
main_methods_results[c(1:3,5), 7] <- "NA"

#save results to excel file
#write.xlsx(main_methods_results, file="filename.xlsx", row.names=F)
write_csv(main_methods_results, path="M:\\Projects\\Ellen\\results\\MR_package_Burgess_ecz_bmi_unrel_v2.csv", col_names = TRUE)


#produce plot
pdf("M:\\Projects\\Ellen\\results\\MR_package_Burgess_ecz_bmi_unrel_v2.pdf", width=15, height=10)
#for large image: width=25, height=25
plot <- mr_plot(main_methods)
#mr_plot(main_methods)
print(plot)
dev.off()
