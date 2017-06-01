library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
library(TSdist)
#library(Rlof)
#library(HighDimOut) # to normalize output scores
rm(list=ls())

file1 <- "1463.csv"
#path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/R_support/support_functions_offline.R")
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Matrix_division/Samys_support.R") #
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Matrix_division/hp_support.R") #SAMY METHOD
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/")
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)
# with energy data
dat <- df_xts$use
dat <- dat['2014-06-01/2014-08-30 23:59:59']
colnames(dat) <- "power"
#dat_month <- split.xts(dat,"months",k=1)
dat_month <- split.xts(dat,"days",k=20)
gp_len <- sapply(dat_month, function(x) length(x)/1440) # checking no. of days in each split
dat_month <- dat_month[gp_len > 5] # dropping splits with less than 5 days.
#hp_score_xts <-  list()
#res_samy <- list()
#energy_anom_score_xts<- list()
agg_score <- list()

for (i in 1:length(dat_month)) {
  dat_day <- split.xts(dat_month[[i]],"days",k=1)
  date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
  mat_day <- create_feature_matrix(dat_day)
  energy_anom_score <- outlierfactor(mat_day)
  print(paste0("Lof done::",i))
  energy_anom_score_xts <- xts(energy_anom_score,as.Date(date_index))
  #energy_anom_score_xts
  res <- anomaly_detection_main_1minute_data_rate(dat_month[[i]])# call to samys method
  res_samy <- xts(round(res$score,2),res$timestamp)
  print(paste0("Muliti-user done::",i))
  res_hp <- outlier_hp(mat_day)
  print(paste0("HP done::",i))
  hp_score_xts <- xts(res_hp,as.Date(date_index))
  
  agg_score[[i]] <- cbind(energy_anom_score_xts,res_samy,hp_score_xts)
  colnames(agg_score[[i]]) <- c("lof","multi_user","hp")
}

base_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
sub_dir <- strsplit(file1,'[.]')[[1]][1]
dir.create(file.path(base_directory, sub_dir))
agg_score <- do.call(rbind,agg_score)
write.csv(fortify(agg_score),file=paste0(base_directory,sub_dir,"/","energy_score.csv"),row.names = FALSE)

house = "115.csv"
result <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/",strsplit(house,'[.]')[[1]][1],"/","energy_score.csv")
#gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/ground_truth/"
gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth/"
gt <- fread(paste0(gt_directory,house))
gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")

res_df <- fread(result)

compute_f_score(res_df,gt,threshold = 0.75)

compute_f_score <- function(res_df,gt,threshold){
  res_df_xts <- xts(res_df[,2:NCOL(res_df)],as.Date(res_df$Index,tz="Asia/Kolkata"))
  res_df_xts <- res_df_xts["2014-07-01/2014-08-30 23:59:59"]
  print("Only retaining july and Aug res")
  #threshold = 0.8
  f_score <- vector(mode="numeric")
  precise <- vector(mode="numeric")
  recal <- vector(mode="numeric")
  for (i in 1:NCOL(res_df_xts)){
    dat <- res_df_xts[,i]
    dat <- dat[dat >= threshold]
    f_dates <- index(dat)
    a_dates <- gt$Index
    tp <- f_dates[f_dates %in% a_dates]
    fp <- f_dates[!f_dates %in% a_dates]
    fn <- a_dates[!a_dates %in% f_dates]
    precision = length(tp)/(length(tp)+length(fp))
    recall =  length(tp)/(length(tp)+length(fn))
    f_score[i] <- round( 2*(precision*recall)/(precision+recall),2)
    precise[i] <- round(precision,2)
    recal[i] <- round(recall,2)
   }
  names(f_score) <- colnames(res_df_xts)
  names(precise) <- colnames(res_df_xts)
  names(recal) <- colnames(res_df_xts)
  print(f_score)
  print(precise)
  print(recal)
 # return(f_score)
}


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
anomaly_threshold = 0.80
f_result <- decide_final_anomaly_status(energy_anom_score_xts,con_anom_score_xts,anomaly_threshold)
savedirec <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
write.csv(fortify(f_result), file = paste0(savedirec,file1),row.names = FALSE )

visualize_context_data_facet_form(temp_data,'occupancy')
dataframe_visualize_all_columns(df_xts["2014-07-03"])

dataframe_visualize_all_columns(temp_data["2014-07-03"])

plot(dat['2014-07-11'])
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