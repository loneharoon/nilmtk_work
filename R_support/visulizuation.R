library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
#library(changepoint)
library(ecp)
rm(list=ls())

file1 <- "115.csv"
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
#path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/")
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)[,2]

df_sub <- df_xts["2014-06-1/2014-08-30"]
appliances <-colnames(df_sub)
folder= strsplit(file1,"[.]")[[1]][1]
dir.create(file.path("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/",folder))
setwd(file.path("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/",folder))
lapply(appliances,function(x){
  dat = df_sub[,x]  
  appliance = x
  colnames(dat) <- "power"
  df_months <- split.xts(dat,"months",k=1)
  filename = paste0(strsplit(file1,"[.]")[[1]][1],"_",appliance,".pdf")
  pdf(filename,width=12,height=10)
  for(i in 1:length(df_months)){
    month_data <- df_months[[i]]
    month_data$day <- lubridate::day(index(month_data))
    month_data$time <- lubridate::hour(index(month_data)) * 60 + lubridate::minute(index(month_data))
    # df_long <- reshape2::melt(coredata(month_data),id.vars=c("time","day"))
    g <- ggplot(as.data.frame(coredata(month_data)),aes(time,power)) + geom_line() + facet_wrap(~day,ncol=7) + ggtitle (appliance)
    print(g)
  }
  dev.off()
})

dat = df_xts$waterheater1
dat <-dat["2014-08-28/2014-08-28"]
dat2 <- fortify(dat)
colnames(dat2) <- c("Index","power")
g <- ggplot(dat2,aes(Index,power)) + geom_line()
ggplotly(g)