# ECZ SNPs on BMI
# grep("rs61816761",(names(data2)), value=TRUE) #Search for variable by name

#perform 2SLS with IVpack

#install.packages("ivpack")
library(ivpack)

#install.packages("pbkrtest")
library(pbkrtest)

#create function to perform 2-stage least squares
TSLS<-function(i) {
  Res<-summary(ivreg(outcome ~ exposure + PC1 + PC2 + PC3 | i, x=T))
  Beta=Res$coefficients[2,1]
  SE=Res$coefficients[2,2]
  P_value=Res$coefficients[2,4]
  L95 = Beta-(1.96*SE)
  U95 = Beta + (1.96*SE)
  return(list(Beta=Beta, SE=SE, L95=L95, U95=U95, P_value=P_value))
}

# Which SNPs to include
names(data2)
a <- which(colnames(data2)=="rs61816761_A")#527 
#b <- which(colnames(data2)=="rs2897442_C") #534
b <- which(colnames(data2)=="rs6010620_G") #550
#b <- which(colnames(data2)=="rs6010620_A") #550

#which(colnames(data2)=="rs12153855_T")

snps_A <- names(data2[a:b])
#snps_B =names(data2[536:c])
snps = c(snps_A, "ESCORE") # Add GRS ESCORE 
#snps = c(snps_A, "ESCORE") # Add GRS ESCORE
n_snps=length(snps)

results.frame=data.frame(matrix(ncol=9, nrow=n_snps))
names(results.frame)=c("SNP", "Outcome", "Exposure", "Beta", "SE", "L95", "U95", "Beta_95_CI", "P_value")

#loop over SNPs
for (i in 1:n_snps){
  
  print(i)
  print(snps[i])
  results.frame[i,1] = snps[i]
  results.frame[i,2]= "BMI"
  results.frame[i,3]="Eczema"
  
  #define exposure and outcome variables, and the instrument
  exposure = data2$Eczema
  outcome = data2$BMI_NT3BLM
  PC1 = data2$PC1
  PC2 = data2$PC2
  PC3 = data2$PC3
  g <- eval(parse(text=paste0("data2$", snps[i])))
  res <- TSLS(i=g)
  
  results.frame[i,4] = res$Beta
  results.frame[i,5] = res$SE
  results.frame[i,6] = res$L95
  results.frame[i,7] = res$U95
  results.frame[i,8] = paste(round(res$Beta, digits=2), "", "(",round(res$L95, digits=2),",",round(res$U95, digits=2),")")
  results.frame[i,9] = res$P_value
  res = NULL
}

# Number cases
numbers<-data2[c("ESCORE", "Eczema","BMI_NT3BLM", "PC1", "PC2", "PC3")]
numbers<-na.omit(numbers)
print(length(numbers$ESCORE))

# library(xlsx)
# write.xlsx(results.frame, file="./Eczema_MR_project/Final_results/1_sample_MR/single_snp/bi-directional/bidirectional_PSO_BMI.xlsx", row.names=F)

#install.packages('readr')
library(readr)
#write_csv(results.frame, path="M:\\Projects\\Ellen\\results\\2SLS_ecz_bmi_loop_unrel_FLG_v2.csv", col_names = TRUE)
write.csv(results.frame, file="M:\\Projects\\Ellen\\results\\2SLS_ecz_bmi_loop_unrel_FLG_v3.csv", row.names = F, quote = F)
