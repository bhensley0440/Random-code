
rm(list=ls(all=TRUE))

setwd("/users/bhensley/Documents")

###########################################################
###################### Input data #########################
###########################################################

data<-read.csv("data_file.csv")
d<-data.frame(data)
o<-d$DATA						

###########################################################
############# Calculate power spectrum ###################
###########################################################
x<-spectrum(o,plot=FALSE)
pwr<-x$spec
freq<-x$freq*24	# muliply by samples / day (i.e. 96=15 min, 24=hourly, 1=daily)

log.pwr<-log10(pwr)
log.freq<-log10(freq)

###########################################################
######################## Plot #############################
###########################################################

plot(log.freq,log.pwr,type="l",main="Spectral Analysis",ylab="Log Spectral Power",xlab="Log Frequency (1/days)",col="gray")

##################### Export CSV #################################
specdata = data.frame(log.freq, log.pwr)
write.csv(specdata, file = "specdata.csv")

