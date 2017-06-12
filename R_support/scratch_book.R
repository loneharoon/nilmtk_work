
k_sensitivity <- function() {
  # this function is used to show sensitivity of k value on LOF
library(xts)
library(data.table)
library(ggplot2)
library(gtools)
library(plotly)
library(TSdist)
#library(Rlof)
#library(HighDimOut) # to normalize output scores
rm(list=ls())

file1 <- "1463.csv"
path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/R_support/support_functions_offline.R")

df <- fread(paste0(path2,file1))
df_xts <- xts(df[,2:dim(df)[2]],fasttime::fastPOSIXct(df$localminute)-19800)
head(df,2)[,1]
head(df_xts,2)
# with energy data
dat <- df_xts$use
dat <- dat['2014-06-22/2014-08-30 23:59:59']
colnames(dat) <- "power"
temp = dat
temp$day = rep(c(1:5),each=1440*14)#creating factors for grouping days, split.xts does not work perfectly
dat_month <- split(temp,f=temp$day)
dat_month <- lapply(dat_month, function(x){
  p = as.xts(x) #x is a zoo object
  q = p$power # droping day column
  return(q)
})

agg_score <- list()

for (i in 1:length(dat_month)) {
  #dat_month[[i]] = subset(dat_month[[i]],select=c("power"))
  dat_day <- split.xts(dat_month[[i]],"days",k=1)
  date_index <- sapply(dat_day,function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
  mat_day <- create_feature_matrix(dat_day)
  energy_anom_score <- outlierfactor_sensitivity(mat_day)
  print(paste0("Lof done::",i))
  agg_score[[i]] <- energy_anom_score
}

norm_score <- list()
for (i in 1:length(agg_score)) {
  norm_score[[i]] <- normalise_my_score(agg_score[[i]])
}
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")
plot_k_sensitivity(norm_score[[3]])

outlierfactor_sensitivity <- function(daymat){
  library(Rlof)
  library(HighDimOut)
  daymat <- daymat[complete.cases(daymat),] # removes rows containing NAs
  dis_mat <- compute_dtw_distance_matrix(daymat)
  df.lof2 <- lof(dis_mat,c(3:7),cores = parallel::detectCores()-1)
  #df.lof2 <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
  #anom_max <-  apply(df.lof2,1,function(x) round(max(x,na.rm = TRUE),2) )#feature bagging for outlier detection
return(df.lof2)
  return(anom_max)
}

plot_k_sensitivity <- function(score_mat){
  df.lof2 <- score_mat
  k_val = 1:dim(df.lof2)[2]
  df_melt <-melt(df.lof2)
  names(df_melt) <- c("day","k","value")
  ggplot(df_melt,aes(day,value,shape=factor(k),color=factor(k)))+
    geom_point(size=5)+
    geom_vline(aes(xintercept=day),linetype = 3, show.legend=TRUE) +
    labs(x= "Day #", y="Anomaly Score")+
    scale_x_continuous(breaks=seq(1,15,4)) +
    scale_shape_manual(name="k", labels=c(3,4,5,6,7),values=c(15,16,17,18,25))+
    scale_color_manual(name="k", labels=c(3,4,5,6,7),values=c("brown","black","blue","green", "red"))+
    theme(axis.text = element_text(color="Black",size=9),legend.position="top",
          legend.title=element_text(size=9),axis.title = element_text(color="Black",size=9))
  ggsave(file="k_sensitivity.pdf", width=10, height=8, units="cm")
}

normalise_my_score <- function(df.lof2){
  res <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
  return(res)
}

}


