# In this script, I plot all inserted anomalies.
# 
library(reshape2)
library(ggplot2)
library(data.table)
library(fasttime)
library(xts)

Sys.setenv('TZ'='UTC')

setwd('/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/anomaly_signatures/')
rootdir <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
home <- "meter_2.csv" # redd_home_6.csv, meter_2.csv, 115.csv, 434, 1463, 490, 3538, 
df <- fread(paste0(rootdir, home))
df_xts <- xts(df$'refrigerator1', fastPOSIXct(df$localminute))

date1 <- '2013-08-02' # normal
date2 <- '2013-08-03'  # anomalous
day1 <- df_xts[date1]
day2 <- df_xts[date2]
temp <- data.frame(coredata(day1), coredata(day2))
colnames(temp) <-  c('day1','day2')
temp$timestamp = index(day1)
df_long <- reshape2::melt(temp,id.vars = "timestamp")

g <- ggplot(df_long,aes(timestamp,value ,group = variable,color = variable, size = variable)) + geom_line(aes(linetype=variable)) 
g <- g + scale_color_manual(values=c('blue','black')) + scale_size_manual(values=c(0.2, 0.5)) + scale_linetype_manual(values=c("longdash", "solid"))
g <- g + theme(legend.position="none",axis.text=element_text(color="black")) + scale_x_datetime(labels=scales::date_format("%H:%M")) + labs(x= "Day hour", y = "Power (W)")
g

savename <- paste0(strsplit(home,'[.]')[[1]][1],'_',date1,'_',date2,".pdf")
ggsave(savename, width = 2.5 ,height = 2 ,units=c('in'))
