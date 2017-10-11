# this script process the iawe dataset and creates different versions of the dataset according to conditions
# meter_1.csv contains data corresponding to meter 1 only

library(xts)
library(data.table)
library(ggplot2)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/iawe/"

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
write.csv(dframe1,paste0(path,"meter_1.csv"),row.names = FALSE)
write.csv(dframe2,paste0(path,"meter_2.csv"),row.names = FALSE)
