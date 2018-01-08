# In this file, I perform anomaly detection using OMNI and baselines on seconds data i.e, redd and aiwe homes
library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
library(TSdist)
#library(Rlof)
#library(HighDimOut) # to normalize output scores
rm(list=ls())


#path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/R_support/support_functions_offline.R")
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Matrix_division/Samys_support.R") #
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Matrix_division/hp_support.R") #SAMY METHOD
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Data_wrangling/wrangle_data.R")
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/")

Sys.timezone()
Sys.setenv('TZ' ="Asia/Kolkata")
############FOR IAWE METER 2############ READ REDD BELOW
aiwe_meter2 <- function(){
file1 <- "meter_2.csv" # "redd_home_6.csv" # "meter_2.csv"  # 
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)
# with energy data
dat <- df_xts$use
#dat <- dat['2014-06-22/2014-08-30 23:59:59']
colnames(dat) <- "power"
# I am supposed to run seconds data but the comuter RAM throws errors so dowsampling is must. Further downsampling should not effect our experiments
dat_month = resample_data_minutely(dat,1)
dat_day <- split.xts(dat_month,"days",k=1)
# resample_data_function decreases one reading of first day and create extra one day with one reading. so we use following work around
temp_index = index(dat_day[[1]][1]) - 60 # create dummy observation
temp = xts(coredata(dat_day[[1]][1]),temp_index)
colnames(temp) = "power"
dat_day[[1]] =  rbind(temp,dat_day[[1]]) # bind dummy observation with main data
dat_day = dat_day[1:length(dat_day)-1]  # drop single day with one observation

date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
mat_day <- create_feature_matrix(dat_day)
energy_anom_score <- outlierfactor(mat_day) # call Lof
print(paste0("Lof done::"))
energy_anom_score_xts <- xts(energy_anom_score,as.Date(date_index))
#energy_anom_score_xts
res <- anomaly_detection_main_1minute_data_rate(dat_month)# call to samys method
res_samy <- xts(round(res$score,2),res$timestamp)
print(paste0("Muliti-user done::"))
res_hp <- outlier_hp(mat_day)
print(paste0("HP done::"))
hp_score_xts <- xts(res_hp,as.Date(date_index))
agg_score <- cbind(energy_anom_score_xts,res_samy,hp_score_xts)
colnames(agg_score) <- c("lof","multi_user","hp")
file1 = "iawemeter2.csv"
base_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
sub_dir <- strsplit(file1,'[.]')[[1]][1]
dir.create(file.path(base_directory, sub_dir))
write.csv(fortify(agg_score),file=paste0(base_directory,sub_dir,"/","energy_score.csv"),row.names = FALSE)
}

redd_home <- function() {
############REDD DATASET ONLY####################
Sys.timezone()
Sys.setenv('TZ' ="Asia/Kolkata")
file1 <- "redd_home_6.csv" #
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)
dat <- df_xts$use
colnames(dat) <- "power"
# I am supposed to run seconds data but the comuter RAM throws errors so dowsampling is must. Further downsampling should not effect our experiments
dat_month = resample_data_minutely(dat,1)
dat_day <- split.xts(dat_month,"days",k=1)
sapply(dat_day,function(x) length(x))
# resample_data_function decreases one reading of few days and create extra days with one reading. so we use following work around to get consistent 1440 readings in each day
temp_index = index(dat_day[[1]][1]) - 60 # create dummy observation
temp = xts(coredata(dat_day[[1]][1]),temp_index)
colnames(temp) = "power"
dat_day[[1]] =  rbind(temp,dat_day[[1]]) # bind dummy observation with main data
sapply(dat_day,function(x) length(x))

temp_index = index(dat_day[[11]][1]) - 60 # create dummy observation
temp = xts(coredata(dat_day[[11]][1]),temp_index)
colnames(temp) = "power"
dat_day[[11]] =  rbind(temp,dat_day[[11]])
sapply(dat_day,function(x) length(x))
dat_day = dat_day[c(1:9,11:17)] # drop days having nan and single observations

date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
mat_day <- create_feature_matrix(dat_day)
energy_anom_score <- outlierfactor(mat_day) # call Lof
print(paste0("Lof done::"))
energy_anom_score_xts <- xts(energy_anom_score,as.Date(date_index))
#prepare data for SAMY's method
#seems input data has nan values so lets remove these nan days first
dat_month = resample_data_minutely(dat,1)
drop_days <- c(as.Date('2011-05-31',tz="Asia/Kolkata"),as.Date('2011-06-07',tz="Asia/Kolkata"),as.Date('2011-06-08',tz="Asia/Kolkata"),as.Date('2011-06-14',tz="Asia/Kolkata"))
p <- dat_month[!as.Date(index(dat_month),tz="Asia/Kolkata") %in% drop_days]
res <- anomaly_detection_main_1minute_data_rate(p)# call to samys method
res_samy <- xts(round(res$score,2),res$timestamp)
print(paste0("Muliti-user done::"))
res_hp <- outlier_hp(mat_day)
print(paste0("HP done::"))
hp_score_xts <- xts(res_hp,as.Date(date_index))
agg_score <- cbind(energy_anom_score_xts,res_samy,hp_score_xts)
colnames(agg_score) <- c("lof","multi_user","hp")
file1 = "Reddhome6.csv"
base_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"
sub_dir <- strsplit(file1,'[.]')[[1]][1]
dir.create(file.path(base_directory, sub_dir))
write.csv(fortify(agg_score),file=paste0(base_directory,sub_dir,"/","energy_score.csv"),row.names = FALSE)
}


# now compute accuracy metric

#LOGIC TO COMPUTE F-SCORE,PRECISION AND RECALL
house = "Reddhome6.csv"# "iawemeter2.csv"
result <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/",strsplit(house,'[.]')[[1]][1],"/","energy_score.csv")
#gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/ground_truth/"
gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth/"
gt <- fread(paste0(gt_directory,house))
#gt <- fread(paste0(gt_directory,"490.csv"))
gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
res_df <- fread(result)
compute_f_score_REDDandIawe(res_df,gt,threshold = 0.80)
