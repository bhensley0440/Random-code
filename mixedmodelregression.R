

rm(list=ls(all=TRUE))

setwd("/users/bhensley/Documents/Spectral/Spectrum")

###########################################################
###################### Input data #########################
###########################################################
# Load data
values<-read.csv("chambergppregression.csv")
d<-data.frame(values)
DEP<-d$DEP
SITE<-d$SITE
L<-d$LGT
N<-d$NO3
GPP<-d$GPP

install.packages("lmerTest")
library(lmerTest)

fit<-	lmer(GPP~L+N+SITE+(1|DEP))
summary(fit)					

plot(fit)
resid(fit)
plotdata = data.frame(resid(fit))
write.csv(plotdata, file = "plotdata.csv")
