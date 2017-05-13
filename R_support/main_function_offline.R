library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
library(Rlof)
library(HighDimOut) # to normalize output scores
rm(list=ls())

file1 <- "115.csv"
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
#path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
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

# READ CONTEXT DATA:
# occu_data <- create_time_series_occupancydata(dat,baseline_limit = 500)
occup_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/occupancy/"
df_occup <- fread(paste0(occup_path,file1))
df_occup_xts <- xts(df_occup[,2],fasttime::fastPOSIXct(df_occup$Index)-19800)
weather_file <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/minute_Austinweather.csv"
df_con <- fread(weather_file)
df_con_xts <- xts(df_con[,2:3],fasttime::fastPOSIXct(df_con$localminute) - 19800)
df_sub <- df_con_xts['2014-06-01/2014-08-30']
df_sub <- cbind(df_sub,df_occup_xts[index(df_sub)])
dat_con_month <- split.xts(df_sub,"months",k=1)
temp_data <- dat_con_month[[2]]

con_anom_score_xts <- summarize_context_with_individual_features(temp_data)
con_anom_score_xts

anomaly_threshold = 0.90
decide_final_anomaly_status(energy_anom_score_xts,con_anom_score_xts,anomaly_threshold)

visualize_context_data_facet_form(temp_data,'occupancy')
dataframe_visualize_all_columns(df_xts["2014-07-03"])

plot(dat['2014-07-03'])
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