
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
dat <- dat['2014-06-22/2014-08-30 23:59:59']
colnames(dat) <- "power"
#dat_month <- split.xts(dat,"months",k=1)
#dat_month <- split.xts(dat,"days",k=1)

temp = dat
temp$day = rep(c(1:5),each=1440*14)#creating factors for grouping days, split.xts does not work perfectly
dat_month <- split(temp,f=temp$day)


#gp_len <- sapply(dat_month, function(x) length(x)/1440) # checking no. of days in each split
#print(gp_len)
#dat_month <- dat_month[gp_len > 5] # dropping splits with less than 5 days.
#hp_score_xts <-  list()
#res_samy <- list()
#energy_anom_score_xts<- list()

distances <- list()
for (i in 1:length(dat_month)) {
  dat_day <- split.xts(dat_month[[i]],"days",k=1)
  date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
  mat_day <- create_feature_matrix(dat_day)
  distances[[i]] <- compute_distance(mat_day)
}

agg_score <- list()
for (i in 1:length(dat_month)) {
  dat_day <- split.xts(dat_month[[i]],"days",k=1)
  date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
  #mat_day <- create_feature_matrix(dat_day)
  #distances[[i]] <- compute_distance(mat_day)
  energy_anom_score <- outlierfactor_mod(distances[[i]])
  print(paste0("Lof done::",i))
  energy_anom_score_xts <- xts(energy_anom_score,as.Date(date_index))
  agg_score[[i]] <- energy_anom_score_xts
#  agg_score[[i]]
}
agg_score <- do.call(rbind,agg_score)
gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth/"
gt <- fread(paste0(gt_directory,file1))
#gt <- fread(paste0(gt_directory,"1463.csv"))
gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
res_df <- agg_score
compute_f_score(res_df,gt,threshold = 0.80)


compute_distance <-function(daymat){
  daymat <- daymat[complete.cases(daymat),] # removes rows containing NAs
  #dis_mat <- dist(t(daymat))
  dis_mat <- compute_dtw_distance_matrix(daymat)
  return(dis_mat)
  # fit <- cmdscale(dis_mat, eig = TRUE, k = 2)
}

outlierfactor_mod <- function(dis_mat){
  library(Rlof)
  library(HighDimOut)
  df.lof2 <- lof(dis_mat,c(5:10),cores = parallel::detectCores()-1)
  #df.lof2 <- apply(df.lof2,2,normalizedata)
  df.lof2 <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
  #df.lof2 <- Func.trans(df.lof2,method = "FBOD")
  anom_max <-  apply(df.lof2,1,function(x) round(max(x,na.rm = TRUE),2) )#feature bagging for outlier detection
  #return(df.lof2)
  return(anom_max)
}




