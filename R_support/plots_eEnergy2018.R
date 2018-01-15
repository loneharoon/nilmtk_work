# in this script I will plots figures for eEnergy 2018 paper [OMNI and UNUM]
# Date: 15 Jan 2018
library(ggplot2)
library(xts)
library(fasttime)
library(reshape2)


dis_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/disagg_outputs/fhmm/490.csv"
orac_path= "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/490.csv"


df_diss = read.csv(dis_path)
df_orac = read.csv(orac_path)
dis_xts =  xts(df_diss[colnames(df_diss) %in% c('air1','clotheswasher1','furnace1')], fastPOSIXct(df_diss$localminute))
dis_orac = xts(df_orac[colnames(df_orac) %in% c('air1','clotheswasher1','furnace1')], fastPOSIXct(df_orac$localminute))

dis_sub = dis_xts["2014-07-25"]
dis_orac = dis_orac["2014-07-25"]
#colnames(dis_orac) = c("furnace_orig","clotheswasher_orig","air1_orig")
#df = cbind(dis_orac,dis_sub)
dis_sub =  fortify(dis_sub)
dis_orac =  fortify(dis_orac)

df1 = melt(df_temp,id=c("Index"),measure.vars = c("furnace_orig","clotheswasher_orig","air1_orig"))
df2 = melt(df_temp,id=c("Index"),measure.vars = c("furnace1","clotheswasher1","air1"),variable.name = "disagg",value.name = "disagg_value")


df1 = melt(dis_sub,id="Index")
df2 =  melt(dis_orac,id="Index",variable.name = "disagg",value.name = "disagg_value")
df_final = merge(df1,df2)

f <- ggplot(df_final,aes(Index,variable=variable)) + facet_grid(variable~.) + geom_line(aes(y=value)) 
f
f <- f + facet_grid(disagg~.)
f

+ geom_line(aes(y=disagg_value),linetype=2)
f

