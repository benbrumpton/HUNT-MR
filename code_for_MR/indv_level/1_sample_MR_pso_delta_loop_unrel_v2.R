#install.packages("boot")
#install.packages("foreign")
#install.packages("tidyverse")

#library(foreign)
#library(boot)
#library(tidyverse)

#Run variable_definitions_v2.R to read in data2 and create variables

# function to return exp() IV ratio and CI using delta-method SE
delta <- function(x, y, g, PC1, PC2, PC3){
  bx = lm(x ~ g + PC1 + PC2 + PC3, subset=y==0)$coef[2]
  bxse = summary(lm(x ~ g + PC1 + PC2 + PC3, subset=y==0))$coef[2,2]
  by = glm(y ~ g, family="binomial")$coef[2]
  byse = summary(glm(y ~ g + PC1 + PC2 + PC3, family="binomial"))$coef[2,2]
  theta <- 0
  se_ratio_approx = sqrt(byse^2/bx^2 + by^2*bxse^2/bx^4 - 2*theta*by/bx^3)
  ratio = by/bx
  or = exp(ratio)
  low = exp(ratio - 1.96*se_ratio_approx)
  upp = exp(ratio + 1.96*se_ratio_approx)
  se = se_ratio_approx
  return(list(or=or, low=low, upp=upp, ratio=ratio, se=se))
}

#Run 2SPS and store results in data2 frame
names(data2)
a <- which(colnames(data2)=="rs977747_T") #103
b <- which(colnames(data2)=="rs2836754_C") #198
c <- which(colnames(data2)=="BGRSZSCORE") #549

snps_A = names(data2[a:b]) #BMI SNPs 
snps = c(snps_A, "BGRSZSCORE") # Add BMI GRS Z Score
n_snps = length(snps)

results.frame = data.frame(matrix(ncol=8, nrow=n_snps))
names(results.frame)=c("SNP", "Outcome", "Exposure","OR","OR_L95","OR_U95","Beta","SE")


# Loop over snps
for (i in 1:n_snps) {
  # PSO ----
  print(snps[i])
  results.frame[i,1] = snps[i]
  results.frame[i,2] = "Psoriasis"
  results.frame[i,3] = "BMI"
  x = data2$BMI_NT3BLM # BMI measured
  y <- data2$PsorEv_NT3BLQ1 # define outcome
  #g <- data2$BGRSZSCORE
  PC1 = data2$PC1 # Correct names of PCs here
  PC2 = data2$PC2
  PC3 = data2$PC3
  g <- eval(parse(text=paste0("data2$", snps[i]))) 
  res <- delta(x=x, y=y, g=g, PC1=PC1, PC2=PC2, PC3=PC3)
  
  # check estimate within CI limits
  if (((res$or < res$upp) & (res$or > res$low)) == FALSE) {
    print(paste("error for CI for", snps[i]))
  }
  
  results.frame[i,4] = res$or
  results.frame[i,5] = res$low
  results.frame[i,6] = res$upp
  results.frame[i,7] = res$ratio
  results.frame[i,8] = res$se
  res = NULL
}

# Number cases
numbers<-data2[c("BGRSZSCORE", "BMI_NT3BLM", "PsorEv_NT3BLQ1", "PC1", "PC2", "PC3")]
numbers<-na.omit(numbers)
print(addmargins(table(numbers$PsorEv_NT3BLQ1)))

#save results to excel file
# this is not working
# install.packages('rJava')
# library(rJava)
# library(xlsx)
# write.xlsx(results.frame, file="./Eczema_MR_project/Final_results/1_sample_MR/single_snp/ratio_estimate_single_snp_ECZ_outcome_BMI.xlsx", row.names=F)

#choose.files()
#write_csv(results.frame, path="M:\\Projects\\Ellen\\results\\1_sample_MR_pso_delta_loop_unrel_v3.csv", col_names = TRUE)
write.csv(results.frame, file="M:\\Projects\\Ellen\\results\\1_sample_MR_pso_delta_loop_unrel_v3.csv", row.names = F, quote = F)

