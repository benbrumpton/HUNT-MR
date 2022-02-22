#calculate r2 from logistic regression

#install.packages("devtools")

#install.packages("rcompanion")
library(rcompanion)
#install.packages("broom")
library(broom)

#calculate pseudo r-squared using the Nagelkerke function. 
#Will give Nagelkerke pseudo r-sq values for the generalisezed linear model 

outcome <- data2$BMI_NT3BLM
exposure <- data2$rs1558902_A
#age <- data2$PartAg_NT3BLQ1
#sex <- data2$Sex
#PC1 = data2$PC1
#PC2 =data2$PC2
#PC3 =data2$PC3
#PC4 =data2$PC4

#model <- lm(outcome ~ exposure + age + sex + PC1 +PC2 +PC3 +PC4)
model <- lm(outcome ~ exposure)

model_sum <-tidy(model)

  Beta=model_sum[2,2]
  Standard_Error=model_sum[2,3]
  P_value=model_sum[2,5]

#res <- nagelkerke(model)
#res <- summary(model)

#p.rsq <- res$Pseudo.R.squared.for.model.vs.null[3]
p.rsq <- summary(model)$r.squared

f <- summary(model)$fstatistic[1]

output <- as.data.frame(c(Beta, Standard_Error, P_value, f, p.rsq), row.names=c("Beta", "SE", "P.val", "F-statistic", "R.sq"))
colnames(output) <- "Value"
print(output)

#save result
#write.csv(output, "M:\\Projects\\Ellen\\results\\f_stat_bmi_FTO_unrel.csv")
write.csv(output, "/Volumes/benb/Projects/Ellen/results/f_stat_bmi_FTO_unrel_v2.csv")
