
library(xts)
library(data.table)
library(ggplot2)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/iawe/"

home <- "iawe_dataset.csv"
df <- fread(paste0(path,home),sep="auto")

df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$timestamp))
colnames(df_xts)

visualize_dataframe_all_columns(df_xts['2013-07-16/2013-07-16 23:59:59'])

visualize_dataframe_all_columns(df_xts[,c("Freezer")]['2015-06-01/2015-06-25'])

dsub <- df_xts['2013-07-13/2013-08-04 23:59:59']



#storepath <- "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
#write.csv(fortify(df_xts),paste0(storepath,"All_Data.csv"),row.names = FALSE)



for (i in 2:NCOL(df)){
  df[,i] <- as.numeric(unlist(df[,i,with=FALSE]))
}
