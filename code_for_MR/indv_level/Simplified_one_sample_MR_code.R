#######################
#### One-sample MR ####
#######################

setwd("") # set your working directory
load(data) # load file with individual level data and phenotype information
attach(data)

# g incorporates instrument (snp) dosages
# x is exposure (continuous)
# y is outcome (continuous)
# y.bin is outcome in binary format



#### Ratio method for a continuous outcome (for one instrument only) ----

## Causal estimate
by1 = lm(y~g1)$coef[2] # numerator
bx1 = lm(x~g1)$coef[2] # denominator
beta.ratio1 = by1/bx1
beta.ratio1 # Ratio estimate for g1 (instrument 1)


## The standard error of the causal estimate can be calculated as:
# the standard error of the genetic association with the outcome divided by the genetic association with the risk factor
byse1 = summary(lm(y~g1))$coef[2,2] # Standard error of the G-Y association
se.ratio1first = byse1/sqrt(bx1^2)  
se.ratio1first # Standard error (first order) of the ratio estimate
# This is the simplest form of the standard error, 
# and is the first-order term from a delta method expansion for the standard error of a ratio


## The above approximation does not account for the uncertainty in the denominator of the ratio estimate. 
# This can be taken into account using the second term of the delta method expansion
bxse1 = summary(lm(x~g1))$coef[2,2] # Standard error of the G-X association
se.ratio1second = sqrt(byse1^2/bx1^2 + by1^2*bxse1^2/bx1^4)
se.ratio1second # Standard error (second order) of the ratio estimate


## F-statistic from the regression of the risk factor on the genetic variant(s) is used as a measure of ‘weak instrument bias’
fstat1 = summary(lm(x~g1))$f[1] # f stat
fstat1

## Minor allele frequency
MAF = (sum(g1==1) + 2*sum(g1==2))/(2*length(g1))
MAF



#### Two-stage least squares method for a continuous outcome (for one or more instruments) ----

## Causal estimate and SE (manual method)
mm.fitted.values<-lm(x~g1+g2+g3+g4)$fitted
mm<-lm(y~mm.fitted.values)
summary(mm)$coef[2]  # estimate
summary(mm)$coef[2,2] # SE

## Causal estimate nad SE (using ivreg package)
# install.packages("ivreg")
library(ivreg)
ivmodel.all = ivreg(y~x|g1+g2+g3+g4, x=TRUE)
summary(ivmodel.all)$coef[2] # 2SLS estimate 
summary(ivmodel.all)$coef[2,2] # Standard error of the 2SLS estimate 
# NB: SE from the "ivreg" automatically adjust for uncertainity so is different from manual method SE

## F-statistics
summary(lm(x~g1+g2+g3+g4))$f[1] # f stat

## Two-stage least squares method can also be used for single instrument variable
ivmodel.g1 = ivreg(y~x|g1, x=TRUE)
summary(ivmodel.g1)$coef[2] # 2SLS estimate for g1 only 
summary(ivmodel.g1)$coef[2,2] # Standard error of the 2SLS estimate for g1 only



#### Ratio method for a binary outcome (for one instrument only) ----

by1.bin   = glm(y.bin~g1, family=binomial)$coef[2] # logistic regression for G-Y association
byse1.bin = summary(glm(y.bin~g1, family=binomial))$coef[2,2]
bx1.bin   = lm(x[y.bin==0]~g1[y.bin ==0])$coef[2] # linear regression for G-X association in the controls only
beta.ratio1.bin = by1.bin/bx1.bin
beta.ratio1.bin # ratio estimate for g1
se.ratio1.bin   = byse1.bin/bx1.bin
se.ratio1.bin # standard error of the ratio estimate for g1



#### Two-stage least squares method for a binary outcome (for one or more instruments) ----

## Two-stage least squares method using single instrument variable
g1.con = g1[y.bin ==0] # values for g1 in the controls only 
x.con  = x[y.bin ==0] # values for the risk factor in the controls only 
predict.con.g1 = predict(lm(x.con~g1.con), newdata=list(g1.con=g1)) # Generate predicted
# values for all participants based on the linear regression in the controls only.  
tsls1.con = glm(y.bin~predict.con.g1, family=binomial) # Fit a logistic regression 
# model on all the participants
summary(tsls1.con)$coef[2] # log OR
summary(tsls1.con)$coef[2,2] # log SE

## Two-stage least squares method using multiple instrument variables
g2.con = g2[y.bin ==0] # values for g2 in the controls only 
g3.con = g3[y.bin ==0] # values for g3 in the controls only 
g4.con = g4[y.bin ==0] # values for g4 in the controls only 
predict.con<-predict(lm(x.con~g1.con+g2.con+g3.con+g4.con), # Predicted values 
                     newdata=c(list(g1.con=g1),list(g2.con=g2),
                               list(g3.con=g3),list(g4.con=g4)))
tsls1.con.all = glm(y.bin~predict.con, family=binomial) #L ogistic regression
summary(tsls1.con.all)$coef[2] #log OR
summary(tsls1.con.all)$coef[2,2] #logse


detach(data)