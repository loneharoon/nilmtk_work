
anomaly_score_threshold <- function() {
# FOR  SENSITIVITY ANALYSIS OF on anomaly threshold score
house="3538.csv"
result <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/",strsplit(house,'[.]')[[1]][1],"/","energy_score.csv")
#gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/ground_truth/"
gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth/"
gt <- fread(paste0(gt_directory,house))
#gt <- fread(paste0(gt_directory,"490.csv"))
gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
res_df <- fread(result)
store <- list()
thresholds <- seq(0.5,1,by=0.1)
for (i in 1:length(thresholds)){
 store[[i]] <- compute_f_score(res_df,gt,threshold = thresholds[i])
}
fin_result <- do.call(rbind,store)
colnames(fin_result) <- c("aggAD","MBM","NNBM")
f_score <- data.frame(fin_result[row.names(fin_result)=='f_score',],row.names = NULL)
precision <- data.frame(fin_result[row.names(fin_result)=='precise',],row.names = NULL)
recall <- data.frame(fin_result[row.names(fin_result)=='recal',],row.names = NULL)
anom_score_threshold_sensitivity(f_score,"F-score",thresholds,house)
anom_score_threshold_sensitivity(precision,"Precision",thresholds,house)
anom_score_threshold_sensitivity(recall,"Recall",thresholds,house)
# precision or recal or fscore results to infinity if both numerator and denominator result to 0

anom_score_threshold_sensitivity <- function(df,label,thresholds,house) {
    setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/sensitivity_plots/")
  df$thresholds = thresholds 
  #ylabel = "value"
  house = strsplit(house,'[.]')[[1]][1]
  df_melt <- reshape2::melt(df,id.vars=c("thresholds")) 
  g <- ggplot(df_melt,aes(thresholds,value,color=variable)) + geom_line()
  g <- g +  labs(x="Threshold",y = label) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 8))
  g
  ggsave(paste0(house,"_",label,"_threshold.pdf"), width = 6, height = 6,units="cm") 
}

}

effect_of_change_in_sigma <- function()
{
  gt <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth_appliance/"
  oracle <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/oracle_sensitivity/"
  
  home = "3538.csv"
  fls <- list.files(oracle,pattern = paste0(strsplit(home,'[.]')[[1]][1],'_*'))
  # FOR AC
  gt_df <- read.csv(paste0(gt,home))
  res <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$ac==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$air1==1,]
    res[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res <- do.call(rbind,res)
  res
  device = "ac"
  thresholds = c(0.5,1.0,1.5,2.0,2.5)
  sigma_sensitivity(res,thresholds,device,home)
  
  # FOR REFRIGERATOR
  gt_df <- read.csv(paste0(gt,home))
  res <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$fridge==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$refrigerator1==1,]
    res[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res <- do.call(rbind,res)
  res
  device = "fridge"
  thresholds = c(0.5,1.0,1.5,2.0,2.5)
  sigma_sensitivity(res,thresholds,device,home)
  
  #  FOR BOTH AC AND FRIDGE
  gt_df <- read.csv(paste0(gt,home))
  res <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$ac==1 | gt_df$fridge==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$air==1 | orac_df$refrigerator1==1,]
    res[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res <- do.call(rbind,res)
  res
  device = "comb"
  thresholds = c(0.5,1.0,1.5,2.0,2.5)
  sigma_sensitivity(res,thresholds,device,home)
  
  
  sigma_sensitivity <- function(df,thresholds,device,house) {
    colnames(df) <- c("Precision","Recall","F-score")
    setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/sigma_sensitivity/")
    df$thresholds = thresholds 
    #ylabel = "value"
    house = strsplit(house,'[.]')[[1]][1]
    df_melt <- reshape2::melt(df,id.vars=c("thresholds")) 
    g <- ggplot(df_melt,aes(thresholds,value,color=variable)) + geom_line()
    g <- g +  labs(x='Standard deviation',y = "Value")  
    g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 8))
    g
    ggsave(paste0(house,"_",device,"_sigma.pdf"), width = 8, height = 7,units="cm") 
  }
  
  compute_accuracy_statistics <- function(gt_ac,fhmm_ac){
    gt = gt_ac
    ob = fhmm_ac
    #oracle = oracle_ac
    a_dates <- as.Date(gt$Index,tz="Asia/Kolkata")
    f_dates <- as.Date(ob$Date,tz="Asia/Kolkata")
    f_score <- vector(mode="numeric")
    precise <- vector(mode="numeric")
    recal <- vector(mode="numeric")
    tp <- f_dates[f_dates %in% a_dates]
    fp <- f_dates[!f_dates %in% a_dates]
    fn <- a_dates[!a_dates %in% f_dates]
    precision = round(length(tp)/(length(tp)+length(fp)),2)
    recall =  round(length(tp)/(length(tp)+length(fn)),2)
    f_score <- round( 2*(precision*recall)/(precision+recall),2)
    return(data.frame(precision,recall,f_score))
  }
  
}

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

