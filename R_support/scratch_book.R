
library(xts)
library(data.table)
library(ggplot2)
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"

home2 <- "115.csv"
df3 <- fread(paste0(path2,home2),sep="auto")
xtdf <- xts(df3[,-1],fasttime::fastPOSIXct(df3$localminute))

colnames(df_xts)

visualize_dataframe_all_columns(df_xts['2013-07-16/2013-07-16 23:59:59'])

visualize_dataframe_all_columns(df_xts[,c("Freezer")]['2015-06-01/2015-06-25'])

dsub <- df_xts['2013-07-13/2013-08-04 23:59:59']


ac1 <- xtdf["2014-07"]$air
ac2 <- xtdf["2014-07"]$air
ac3 <- xtdf["2014-07"]$air
ac_comb <- cbind(ac1,ac2,ac3)
write.csv(fortify(ac_comb),paste0(path,"ac_data.csv"),row.names = FALSE)

#storepath <- "/Volumes/MacintoshHD2/Users/haroonr/Downloads/"
#write.csv(fortify(df_xts),paste0(storepath,"All_Data.csv"),row.names = FALSE)


