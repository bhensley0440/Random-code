##### Clears existing variables #####
rm(list=ls())

##### Set working directory #####
setwd("~/Steam Metabolizer")

##### Loads required libraries #####
library(streamMetabolizer) 
library(tidyverse)

##### Calculates estimated light #####
# (Note you can skip if you already have this)
fitdata2<- read.csv("Metabolizer_input.csv",header=T,na.strings="")
fitdata2<- fitdata2 %>%
  mutate(solar.time = as.POSIXct(solar.time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))
light<- calc_light(fitdata2$solar.time,29.081389,-81.575833)
fitdata2<- cbind(fitdata2,light)
colnames(fitdata2)<- c("solar.time","DO.obs","DO.sat","temp.water","depth","light")


##### Prepares Bayesian model #####
# Our version of prep_metabolism for local data. 
prep_metab2<- function(data_metab, model="streamMetabolizer", type="bayes", fillgaps=TRUE, token=NULL, ...) {
  if(model=="BASE"){
    model_variables <- c("solar.time","DO.obs","temp.water","light","atmo.pressure")
  }else{ # streamMetabolizer
    model_variables <- c("solar.time","DO.obs","DO.sat","depth","temp.water","light")
    #if(type=="bayes") model_variables <- c(model_variables,"discharge")
  }
  if(!all(model_variables%in%colnames(data_metab))){
    stop("Insufficient data to fit this model.")
  }
  
  if(model=="BASE"){ # rename variables for BASE
    fitdata <- data_metab %>% select_(.dots=model_variables) %>%
      mutate(Date=as.Date(solar.time),Time=strftime(solar.time,format="%H:%M:%S"), salinity=0) %>%
      rename(I=light, tempC=temp.water, DO.meas=DO.obs) %>%
      dplyr::select(Date, Time, I, tempC, DO.meas, atmo.pressure, salinity)
    BASE <- setClass("BASE", contains="data.frame")
    outdata <- as(fitdata, "BASE")
  }else if(model=="streamMetabolizer"){
    fitdata <- dplyr::select_(data_metab, .dots=model_variables)
    streamMetabolizer <- setClass("streamMetabolizer", representation(type="character"), contains="data.frame")
    outdata <- as(fitdata, "streamMetabolizer")
    outdata@type <- type
  }
  return(outdata)
}


##### Correctly structures the data and fits model#####
fitdata2<- fitdata2 %>%
  mutate(solar.time = as.POSIXct(solar.time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))
fitdata2<- prep_metab2(data_metab = fitdata2)
class(fitdata2) = 'data.frame' 
##### Constrains k (comment out for unconstrained) #####
modname = mm_name(type='bayes', pool_K600='none',
                  err_obs_iid=TRUE, err_proc_acor=FALSE, err_proc_iid=TRUE,
                  ode_method = 'trapezoid', deficit_src='DO_mod', engine='stan')
modspecs = specs(modname)
modspecs$K600_daily_meanlog<- log(0.6) #mean k units d-1
modspecs$K600_daily_sdlog<- 0.4 #stdv k, must to be greater than 0


##### Creates CSV outpout file and plots of daily GPP and ER #####
modelfit = metab(specs=modspecs, data=fitdata2)
write.csv(modelfit@fit$daily,file="Metabolizer_output.csv")
plot_DO_preds(modelfit)
plot_metab_preds(modelfit)
