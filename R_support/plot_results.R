# I use this scipt to plot all bar charts of Buildsys 2017 paper.
# The data is computed mostly from python and then noted on note book and finally inserted here

AGGREGATE_LEVLE <- function(){
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")
fscore_df = data.frame("1463"=c(0.81,0.70,0.50),
                       "3538"=c(0.83,0.52,0.28),
                       "490"=c(0.73,0.57,0.38),
                       "115"=c(0.72,0.57,0.53))
#row.names(fscore_df) = c("Lof","Muser","hp")
row.names(fscore_df) = c("OMNI","MBM","NNBM")
df = as.data.frame(t(fscore_df))
plot_bar_plots(df,"F-score")

prec_df = data.frame("1463"=c(0.92,1,0.54),
                     "3538"=c(1,0.67,0.27),
                     "490"=c(1,0.86,0.45),
                     "115"=c(0.90,1,0.53))
#row.names(prec_df) = c("Lof","Muser","hp")
row.names(prec_df) = c("OMNI","MBM","NNBM")
df = as.data.frame(t(prec_df))
plot_bar_plots(df,"Precision")


recall_df = data.frame("1463"=c(0.73,0.53,0.47),
                       "3538"=c(0.71,0.43,0.29),
                       "490"=c(0.57,0.43,0.33),
                       "115"=c(0.60,0.40,0.53))
#row.names(recall_df) = c("Lof","Muser","hp")
row.names(recall_df) = c("OMNI","MBM","NNBM")
df = as.data.frame(t(recall_df))
plot_bar_plots(df,"Recall")

plot_bar_plots <- function(df,ylabel){
  df$idcol = seq(1,4)
  df_melt <- reshape2::melt(df,id.vars=c("idcol"))
  g <- ggplot(df_melt,aes(idcol,value,fill=variable)) + geom_bar(position="dodge",stat="identity",width = 0.7)
  g <- g +  labs(x="Home #",y = ylabel) + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9))
  g
  ggsave(paste0(ylabel,".pdf"), width = 6, height = 6,units="cm") 
}

}

dissagregation_accu <-function(){
######################################################Dissagregation accuracy score#####

accu_df = data.frame("1463"=c(0.71,0.62),
                     "3538"=c(0.55,0.51),
                     "490"=c(0.53,0.47),
                     "115"=c(0.50,0.44))
row.names(accu_df) <- c("FHMM","CO")
df <- as.data.frame(t(accu_df))
df <- df*100
df$idcol = seq(1,4)
df_melt <- reshape2::melt(df,id.vars=c("idcol"))

g <- ggplot(df_melt,aes(idcol,value,fill=variable)) + geom_bar(position="dodge",stat="identity",width = 0.7)
g <- g +  labs(x="Home #",y = "Accuracy (%)") + theme_grey(base_size = 10) 
g <- g + theme(axis.text = element_text(color="Black",size=9,family = "Arial"),legend.position="right",legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9),legend.title=element_blank()) + scale_fill_manual(values=c('#800000','#9ebcda'))
g

scale_fill_manual(values=c('#8856a7','#9ebcda'))
#ggsave("accuracy.pdf", width = 8, height = 6,units="cm") 
}

APPLIANCE_LEVEL <- function() {
##############################APPLIANCE LEVEL SCORES#########################
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")

ac_fscore_df = data.frame("1463"=c(0.40,0.67),
                          "3538"=c(0.64,0.72),#"3538"=c(0.71,0.70),
                          "490"=c(0.70,0.82),
                          "115"=c(0.44,0.83))
#row.names(ac_fscore_df) <- c("FHMM_P","Oracle_Q")
row.names(ac_fscore_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(ac_fscore_df))
plot_bar_plots_appliance(df,"F-score","ac_fscore")


ac_precision_df = data.frame("1463"=c(0.50,0.67),
                             "3538"=c(0.70,0.75), #"3538"=c(0.86,0.70),
                             "490"=c(0.70,0.82),
                             "115"=c(0.67,0.83))
#row.names(ac_precision_df) <- c("FHMM","Oracle")
row.names(ac_precision_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(ac_precision_df))
plot_bar_plots_appliance(df,"Precision","ac_precision")


ac_recall_df = data.frame("1463"=c(0.33,0.67),
                          "3538"=c(0.60,0.70),
                          "490"=c(0.70,0.82),
                          "115"=c(0.33,0.83))
#row.names(ac_recall_df) <- c("FHMM","Oracle")
row.names(ac_recall_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(ac_recall_df))
plot_bar_plots_appliance(df,"Recall","ac_recall")
###########%%%%%%%%%%%%%%%%%%%%%%%%%FRIDGE######################

fridge_fscore_df = data.frame("1463"=c(0.15,0.86),
                              "3538"=c(0.07,0.86),
                              "490"=c(0.27,0.83),
                              "115"=c(0.16,0.86))
#row.names(fridge_fscore_df) <- c("FHMM","Oracle")
row.names(fridge_fscore_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(fridge_fscore_df))
plot_bar_plots_appliance(df,"F-score","fridge_fscore")

fridge_precision_df = data.frame("1463"=c(0.08,1),
                                 "3538"=c(0.04,1),
                                 "490"=c(0.16,0.77),
                                 "115"=c(0.09,0.86))
#row.names(fridge_precision_df) <- c("FHMM","Oracle")
row.names(fridge_precision_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(fridge_precision_df))
plot_bar_plots_appliance(df,"Precision","fridge_precision")

fridge_recall_df = data.frame("1463"=c(0.80,0.75),
                              "3538"=c(0.25,0.75),
                              "490"=c(0.92,0.91),
                              "115"=c(0.88,0.86))
#row.names(fridge_recall_df) <- c("FHMM","Oracle")
row.names(fridge_recall_df) <- c("UNUM_D","UNUM_S")
df <- as.data.frame(t(fridge_recall_df))
plot_bar_plots_appliance(df,"Recall","fridge_recall")


plot_bar_plots_appliance <- function(df,ylabel,savename){
  library(ggplot2)
  df$idcol = seq(1,4)
  df_melt <- reshape2::melt(df,id.vars=c("idcol"))
  g <- ggplot(df_melt,aes(idcol,value,fill=variable)) + geom_bar(position="dodge",stat="identity",width = 0.7)
  g <- g +  labs(x="Home #",y = ylabel) + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9))
  g
  ggsave(paste0(savename,".pdf"), width = 6, height = 6,units="cm") 
}

}

methodology_figures <- function(){
##### methodology figure ########
path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/methodolgy_figdata/three_ac_scenario.csv"
df= read.csv(path)
#df_xts <- xts(df[,2:4],fasttime::fastPOSIXct(df[,1])-19800)
colnames(df) <- c("timestamp","Normal","Abnormal 1","Abnormal 2")
df_melt <- reshape2::melt(df,id.vars=c("timestamp"))
df_melt$timestamp <- fasttime::fastPOSIXct(df[,1])-19800

f <- ggplot(df_melt,aes(timestamp,value/1000,ymin = 0,ymax=value/1000)) + facet_grid(variable~.,scales="free") 
f <- f + geom_line(data=subset(df_melt,variable=="Normal"),colour="blue")  # require(plyr) for dot function
f <- f + geom_line(data=subset(df_melt,variable=="Abnormal 1"),colour="red")  
f <- f + geom_line(data=subset(df_melt,variable=="Abnormal 2"),colour="red") 
f <- f + labs(x= "Timestamp(HH:MM)",y="Power (kW)") + theme(strip.text.y = element_text(size = 8,face="bold"))
f <- f+ theme(axis.text = element_text(color="black",size=8)) + scale_y_continuous(breaks=scales::pretty_breaks(n=4))
f
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")
#ggsave(filename="ac_consump_scenario.pdf",height = 7, width = 12, units="cm") #  FIGURE 1

df2 <- subset(df_melt,variable=="Normal")
df2$value <- df2$value+ 70
g <- ggplot(df2,aes(timestamp,value/1000,ymin=-0.3,ymax=1.5)) + geom_line(color="blue")
g <- g + labs(x= "Timestamp(HH:MM)",y="Power (kW)")+ theme(axis.text = element_text(color="black",size=8),axis.title  = element_text(size=9))
g
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")
# ggsave(filename="clustering_ver2.pdf",height = 4, width = 12, units="cm") #  FIGURE 1
######################
library(data.table)
library(scales)
file1 <- "1086.csv"
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default3/" 
df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
df_ref <- df_xts["2014-07-25","refrigerator1"]
g <- ggplot(fortify(df_ref),aes(Index,refrigerator1)) + geom_line(color="blue")
g <- g + labs(x= "Timestamp(HH:MM)",y="Power (W)")+ theme(axis.text = element_text(color="black",size=8),axis.title  = element_text(size=9)) + scale_x_datetime(labels=date_format("%H:%M",tz="Asia/Kolkata"))
g
ggsave(filename="refrigerator.pdf",height = 4, width = 6, units="cm") #
df_ref <- df_xts["2014-06-17","air1"]
g <- ggplot(fortify(df_ref),aes(Index,air1/1000)) + geom_line(color="blue")
g <- g + labs(x= "Timestamp(HH:MM)",y="Power (kW)")+ theme(axis.text = element_text(color="black",size=8),axis.title  = element_text(size=9)) + scale_x_datetime(labels=date_format("%H:%M",tz="Asia/Kolkata"))
g
ggsave(filename="ac.pdf",height = 4, width = 6, units="cm") #

}
