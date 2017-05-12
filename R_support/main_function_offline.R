library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
library(Rlof)
library(HighDimOut) # to normalize output scores
rm(list=ls())

file1 <- "115.csv"
#path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/")
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)
# with energy data
dat <- df_xts$use
dat<- dat['2014-06-01/2014-08-30']
colnames(dat) <- "power"
dat_month <- split.xts(dat,"months",k=1)
dat_day <- split.xts(dat_month[[2]],"days",k=1)
date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
mat_day <- create_feature_matrix(dat_day)
energy_anom_score <- outlierfactor(mat_day)
energy_anom_score_xts <- xts(energy_anom_score,as.Date(date_index))
energy_anom_score_xts

# with weather/context data
occu_data <- create_time_series_occupancydata(dat,baseline_limit = 500)
weather_file <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/minute_Austinweather.csv"
df_con <- fread(weather_file)
df_con_xts <- xts(df_con[,2:3],fasttime::fastPOSIXct(df_con$localminute) - 19800)
df_sub <- df_con_xts['2014-06-01/2014-08-30']
df_sub <- cbind(df_sub,occu_data)
dat_con_month <- split.xts(df_sub,"months",k=1)
temp_data <- dat_con_month[[2]]

con_anom_score_xts <- summarize_context_with_individual_features(temp_data)
con_anom_score_xts

anomaly_threshold = 0.8
decide_final_anomaly_status(energy_anom_score_xts,con_anom_score_xts,anomaly_threshold)

decide_final_anomaly_status <- function(energy_anom_score_xts,con_anom_score_xts,anomaly_threshold){
  
  for(i in 1:length(energy_anom_score_xts)){
    if(energy_anom_score_xts[i] >= anomaly_threshold & con_anom_score_xts[i] >= anomaly_threshold) {
      print (paste0("Contextually non-anomalous: ",index(energy_anom_score_xts[i])))
    } else if(energy_anom_score_xts[i] >= anomaly_threshold & con_anom_score_xts[i] <= anomaly_threshold){
      print (paste0("anomaly on:) ",index(energy_anom_score_xts[i])) )
     if(!exists("anom_vec")){
       anom_vec <- energy_anom_score_xts[i]
     } else{
       anom_vec <- rbind(anom_vec,energy_anom_score_xts[i])
     }
    }
  }
  if(exists("anom_vec")){
    return(anom_vec)
  }else{
    return (0)}
}

plot(dat['2014-07-04'])
plot(temp_data['2014-07-12','occupancy'])

###INJECTING  temperature SIGNATURE
df_change <- temp_data
df_change['2014-07-12 01:30:00/2014-07-12 10:00:00','TemperatureC'] <- 33
plot(df_change['2014-07-12']$TemperatureC)
# temp_data = df_change
###########################

###INJECTING  occupancy SIGNATURE
df_change <- temp_data
df_change['2014-07-12 01:30:00/2014-07-12 12:00:00','occupancy'] <- 1
plot(df_change['2014-07-12']$occupancy)
# temp_data = df_change
###########################
