#The association between single BMI SNPs and PSO
outcome <- data2$PsorEv_NT3BLQ1
age <- data2$PartAg_NT3BLQ1
sex <- data2$Sex
PC1 <- data2$PC1
PC2 <- data2$PC2
PC3 <- data2$PC3

#apply function that will be used to loop through each SNP, where "i" = particular SNP

snp_reg <- function(i) {
  Res <- summary(glm(outcome ~ i + age + sex + PC1 + PC2 + PC3, family = binomial))
  Beta=Res$coefficients[2,1]
  Standard_Error=Res$coefficients[2,2]
  P_value=Res$coefficients[2,4]
  return(c(Beta, Standard_Error, P_value))
}

# Which column numbers are they?
names(data2)
a = which(colnames(data2)=="rs977747_T")
b = which(colnames(data2)=="rs2836754_C")

single_snp <- as.data.frame(lapply(data2[a:b], snp_reg)) #will loop through SNPs in dataframe, in mine this is columns 24 to 120

# Number of individuals
fit <- glm(outcome ~ data2$rs2836754_C + age + sex + PC1 + PC2 + PC3, family = binomial)
print(paste("totalN=", nobs(fit), sep = ""))

# Number cases
numbers<-data2[c("rs2836754_C", "PsorEv_NT3BLQ1","PartAg_NT3BLQ1", "Sex", "PC1", "PC2", "PC3")]
numbers<-na.omit(numbers)
print(addmargins(table(numbers$PsorEv_NT3BLQ1)))

#pull out results

single_snp <- as.data.frame(t(single_snp))
colnames(single_snp)[1] <- "Beta"
colnames(single_snp)[2] <- "SE"
colnames(single_snp)[3] <- "P-value"
single_snp$Beta_round <- round(single_snp$Beta, digits=2)
single_snp$L95 <- round(single_snp$Beta - (1.96*single_snp$SE), digits=2)
single_snp$U95 <- round(single_snp$Beta + (1.96*single_snp$SE),digits = 2)

#create column for "Beta (95% CI)"
#Beta_95_CI <- function(x){
#  paste(single_snp$Beta_round[x], " ", "(", single_snp$L95[x], "-", single_snp$U95[x], ")")
#}

# single_snp$Beta_L95_U95 <- lapply(c(1:length(single_snp$Beta)), Beta_95_CI)

# Do this so it does not create a list (i.e. lapply)
# single_snp$Beta_L95_U95_2 <- paste(round(single_snp$Beta, digits = 2), "(", round(single_snp$L95, digits = 2), "-", round(single_snp$U95, digits = 2, ")")
single_snp$Beta_L95_U95_2 <- paste(round(single_snp$Beta, digits = 2), "(", round(single_snp$L95, digits = 2), "-",  round(single_snp$U95, digits = 2), ")", sep = "")                                  

#also create column for SNP names
single_SNP_names <- rownames(single_snp)
single_snp$SNP <- single_SNP_names

#save results to excel file
#install.packages("xlsx")
#library(xlsx)
#write.xlsx(single_snp, file="filename.xlsx", row.names=F)

#library(tidyverse)
#write_csv(single_snp, path="M:\\Projects\\Ellen\\results\\BMI_single_snp_on_PSO_summary_unrel.csv", col_names = TRUE)
write.csv(single_snp, file="M:\\Projects\\Ellen\\results\\BMI_single_snp_on_PSO_summary_unrel_v2.csv", row.names = F, quote = F)
