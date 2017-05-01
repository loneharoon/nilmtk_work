# resample weather datas
library(xts)
library(data.table)
library(ggplot2)
library(gtools)

filepath <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/hourly_AustinWeather.csv"
df = read.csv(filepath)
dfs <- xts(df[,2:3],fasttime::fastPOSIXct(df$timestamp)-19800)

minute_data <- create_minute_data(dfs)
write.csv(minute_data,file= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/minute_AustinWeather.csv",row.names = FALSE)



create_minute_data <- function(dfs) {
  #downsampled data
  #
 start = first(index(dfs))
 end = last(index(dfs))
 timeseq = seq(start,end,"min")
 new_df <- xts(rep(NA,length(timeseq)),timeseq) 
 new_df <-cbind(new_df,dfs)
 new_df <- new_df[,2:3]
 new_df <- round(na.approx(new_df),2)
 df  <- data.frame(localminute=index(new_df),coredata(new_df))
  return(df)
}
