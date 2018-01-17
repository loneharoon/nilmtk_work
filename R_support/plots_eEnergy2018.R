# in this script I plot insights figures for eEnergy 2018 paper [OMNI and UNUM]
# Date: 15 Jan 2018
library(ggplot2)
library(xts)
library(fasttime)
library(reshape2)

insights_figure_home3 <- function(){
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/eEnergy_2018/plots/")
  
dis_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/490.csv"
orac_path= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/490.csv"

df_diss = read.csv(dis_path)
df_orac = read.csv(orac_path)
dis_xts =  xts(df_diss[colnames(df_diss) %in% c('air1','clotheswasher1','furnace1')], fastPOSIXct(df_diss$localminute))
colnames(dis_xts) <- c("AC","ClothesWasher","Furnace")
dis_orac = xts(df_orac[colnames(df_orac) %in% c('air1','clotheswasher1','furnace1')], fastPOSIXct(df_orac$localminute))
colnames(dis_orac) <- c("Furnace","ClothesWasher","AC")

dis_sub = dis_xts["2014-07-25"]
dis_orac = dis_orac["2014-07-25"]

dis_sub =  fortify(dis_sub)
dis_orac =  fortify(dis_orac)

df1 = melt(dis_sub,id="Index")
df2 =  melt(dis_orac,id="Index")

f <- ggplot(df1,aes(Index,variable=variable)) + facet_grid(variable~.,scales = "free") + geom_line(aes(y=value/1000,color="blue")) 
f <- f +  labs(x="Timestamp",y = "Power (kW)") + theme_grey(base_size = 10) 
f <- f + geom_line(data=df2,aes(x=Index,y=value/1000,color="black"))
f <- f +  scale_fill_identity(guide='legend')+ scale_colour_manual(name="",values= c('black'="black",'blue'='blue'),labels=c("Sub-metered","Disaggregated"))
f <- f + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 8)) 
f
ggsave("insights_home3.pdf", width = 6, height = 3,units="in") 
}

insights_figure_home3_version2 <- function(){
  # In this version, I only plot AC data and show it in facet_grid format
  setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/eEnergy_2018/plots/")
  
  dis_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/490.csv"
  orac_path= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/490.csv"
  
  df_diss = read.csv(dis_path)
  df_orac = read.csv(orac_path)
  dis_xts =  xts(df_diss$air1, fastPOSIXct(df_diss$localminute))
  colnames(dis_xts) <- c("AC")
  dis_orac = xts(df_orac$air1, fastPOSIXct(df_orac$localminute))
  colnames(dis_orac) <- c("AC")
  
  dis_disagg = dis_xts["2014-07-25"]
  dis_orac = dis_orac["2014-07-25"]

  df <- fortify(cbind(dis_orac,dis_disagg))
  colnames(df) <- c("Index","Submetered","Disaggregated")
  df_melt <- melt(df,id="Index") 
 # df_melt$variable_order <- as.factor(df_melt$variable,levels = c("Disaggregated","Submetered"))
 # levels(df_melt$variable) <- c("Disaggregated","Submetered")
  
  anomaly = dis_orac["T05:58/T17:30"]
  disagg_same_duration = dis_disagg["T05:58/T17:30"]
  disagg_same_duration$AC <- NA # forcing them to be NULL for intended purpose
  df2 <- fortify(cbind(anomaly,disagg_same_duration))
  colnames(df2) <- c("Index","Submetered","Disaggregated")
  
  df2_melt <- melt(df2,id="Index") 
 # levels(df2_melt$variable) <- c("Disaggregated","Submetered")
  
  anomaly_fort <- fortify(anomaly)
  anomaly_fort['variable'] = "Submetered"
  colnames(anomaly_fort) <- c("Index","value","variable")
  
  f <- ggplot(df_melt,aes(Index,variable=variable)) + facet_grid(variable~.,scales = "free") + geom_line(aes(y=value/1000)) 
  f <- f +  labs(x="Timestamp",y = "Power (kW)") + theme_grey(base_size = 10) 
  f
  f <- f + geom_line(data=df2_melt,aes(x=Index,y=value/1000),color="red")
  f
  f <- f + theme(axis.text = element_text(color="Black",size=9)) 
  f
  ggsave("insights_home3_ver2.pdf", width = 5, height = 2,units="in") 
}

insights_figure_home5 <-function() {
  
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/eEnergy_2018/plots/")
dis_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/meter_2.csv"
orac_path= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/meter_2.csv"

df_diss = read.csv(dis_path)
df_orac = read.csv(orac_path)

dissag_df =  xts(df_diss$air1, fastPOSIXct(df_diss$localminute))
colnames(dissag_df) <- c("Disaggregated")
orac_df = xts(df_orac$air1, fastPOSIXct(df_orac$localminute))
colnames(orac_df) <- c("Submetered")


dis_orac_sub = orac_df["2013-07-21/"]

df = cbind(dis_orac_sub,dissag_df)
#df_samp = resample_data_minutely(df,1)

df_fort = fortify(df)
df_melt = melt(df_fort,id="Index")

f <- ggplot(df_melt,aes(Index,variable=variable)) + facet_grid(variable~.,scales = "free") + geom_line(aes(y=value/1000)) 
f <- f +  labs(x="Timestamp",y = "Power (kW)") + theme_grey(base_size = 10) 
f <- f + theme(axis.text = element_text(color="Black",size=9))
f
ggsave("insights_home5.png", width = 6, height = 3,units="in") 
}