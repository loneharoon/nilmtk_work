# main part of this script is used to plot the usage of each indiviual appliance of a home.
library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
rm(list=ls())

file1 <- "490.csv"
#path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default3/" 
path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
#path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
#setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/injected_homes/")
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)[,2]

df_sub <- df_xts["2014-06-1/2014-08-30 23:59:59"]
appliances <-colnames(df_sub)
folder= strsplit(file1,"[.]")[[1]][1]
dir.create(file.path("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/injected_homes/",folder))
setwd(file.path("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plots/injected_homes/",folder))

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



dframe = df_sub["2014-07-27",'air1']
dataframe_visualize_all_columns(dframe)

dat = df_sub$refrigerator1
dat <-dat["2014-06-03/2014-06-03 23:59:59"]
dat2 <- fortify(dat)
colnames(dat2) <- c("Index","power")
g <- ggplot(dat2,aes(Index,power)) + geom_line()
ggplotly(g)

#
#VISUAULIZE  context data
visualize_context_data_facet_form <- function(df,column_name){
  month_data <- df
  month_data <- month_data[,column_name]
  colnames(month_data) <- "power"
  #browser()
  month_data$day <- lubridate::day(index(month_data))
  month_data$time <- lubridate::hour(index(month_data)) * 60 + lubridate::minute(index(month_data))
  # df_long <- reshape2::melt(coredata(month_data),id.vars=c("time","day"))
  g <- ggplot(as.data.frame(coredata(month_data)),aes(time,power)) + geom_line() + facet_wrap(~day,ncol=7) 
  print(g)
}

dataframe_visualize_all_columns <- function(dframe) {
  library(RColorBrewer)# to increase no. of colors
  library(plotly)
  # VISUALIZE SPECiFIC PORTION OF DATA
  #http://novyden.blogspot.in/2013/09/how-to-expand-color-palette-with-ggplot.html
  #dframe <- data_10min["2014-08-9"]
  dframe <- data.frame(timeindex=index(dframe),coredata(dframe))
  # dframe$dataid <- NULL ; dframe$air1 <-NULL ; dframe$use<- NULL ; dframe$drye1 <- NULL
  df_long <- reshape2::melt(dframe,id.vars = "timeindex")
  colourCount = length(unique(df_long$variable))
  getPalette = colorRampPalette(brewer.pal(8, "Dark2"))(colourCount) # brewer.pal(8, "Dark2") or brewer.pal(9, "Set1")
  g <- ggplot(df_long,aes(timeindex,value,col=variable,group=variable))
  g <- g + geom_line() + scale_colour_manual(values=getPalette)
  ggplotly(g)
}