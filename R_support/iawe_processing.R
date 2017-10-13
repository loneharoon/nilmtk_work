# this script process the iawe dataset and creates different versions of the dataset according to conditions
# meter_1.csv contains data corresponding to meter 1 only

library(xts)
library(data.table)
library(ggplot2)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/iawe/"

 create_two_subsets_wrt_meters <- function(){
   # here we create two datasets corresponding the devices connected to which of the meters
home <- "iawe_processed_dataset.csv"
df <- fread(paste0(path,home),sep="auto")
df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp))
colnames(df_xts)
# step 1: drop  water motar since it contains only NA values

df_sub <- df_xts[,-12]

df_1 <- subset(df_sub,select=c("main1","ac1","washing_mc"))
cols <- colnames(df_1)
sel_cols <- colnames(df_sub)[!colnames(df_sub) %in% c("main1","ac1","washing_mc")]
df_2 <- subset(df_sub,select=sel_cols)

dframe1 <- data.frame(index(df_1),coredata(df_1))
dframe2 <- data.frame(index(df_2),coredata(df_2))
#write.csv(dframe1,paste0(path,"meter_1.csv"),row.names = FALSE)
#write.csv(dframe2,paste0(path,"meter_2.csv"),row.names = FALSE)
 }
 create_data_subset <- function(){
   # using this function I select a slice of datasetset and then clean the same with steps shown below
   home <- "iawe_dataset.csv"
   df <- fread(paste0(path,home),sep="auto")
   df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp))
   df_sub <- df_xts["2013-07-13/2013-08-04 23:59:59"]
   which(duplicated(index(df_sub)))
   temp <- df_sub
   # fill NAs with zero because na.approx() gives vague results
   temp[is.na(temp)] <-  0
   # fill missing readings first with NA and then interopolate in subsequent steps
   temp_filled <- fill_missing_readings_with_NA(temp,"1 sec")
   colnames(temp_filled) <- colnames(temp)
   temp_filled_new <- na.approx(temp_filled)
   dframe <- data.frame(localminute = index(temp_filled_new),coredata(temp_filled_new))
  # write.csv(dframe,paste0(path,"iawe_sub_dataset.csv"),row.names = FALSE)
 }
 
 visualize_dataframe_one_column_facet_form_day_wise(temp$main2,7)
 visualize_dataframe_all_columns(temp_filled_new["2013-07-17"])
# colnames(df) <- c("localminute","use",colnames(df)[3:length(colnames(df))])
# write.csv(df,paste0(path,"meter_2.csv"),row.names = FALSE)
