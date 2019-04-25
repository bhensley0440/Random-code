
rm(list=ls(all=TRUE))

setwd("/users/bhensley/Documents")


###########################################################
###################### Input data #########################
###########################################################

data<-read.csv("data_file.csv")
d<-data.frame(data)
t2<-d$DATE
c1<-d$DATA						

output<-acf(c1, lag.max = 40000)

##################### Export CSV ##########################
results=data.frame(output$acf)
write.csv(results,file="autocorrelation results.csv")
