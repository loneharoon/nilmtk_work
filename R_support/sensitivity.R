
anomaly_score_threshold <- function() {
# FOR  SENSITIVITY ANALYSIS OF on anomaly threshold score
house="115.csv"
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
colnames(fin_result) <- c("OMNI","MBM","NNBM")
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
  g <- ggplot(df_melt,aes(thresholds,value,color=variable)) + geom_line(size=0.6) + geom_point(aes(shape=variable))
  g <- g +  labs(x="Threshold",y = label) + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9))
  g
  ggsave(paste0(house,"_",label,"_threshold.pdf"), width = 6, height = 6,units="cm") 
}

}

anomaly_score_threshold_VERSION_eEnergy2018 <- function() {
  library(data.table)
  library(xts)
  library(ggplot2)
  
  # FOR  SENSITIVITY ANALYSIS OF on anomaly threshold score
  house="115.csv"
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
  #colnames(fin_result) <- c("OMNI","MBM","NNBM")
  colnames(fin_result) <- c("AGGR","MBM","NNBM")
  f_score <- data.frame(fin_result[row.names(fin_result)=='f_score',],row.names = NULL)
  precision <- data.frame(fin_result[row.names(fin_result)=='precise',],row.names = NULL)
  recall <- data.frame(fin_result[row.names(fin_result)=='recal',],row.names = NULL)
 
  f_score["Metric"] <- "Fscore"
  f_score["Threshold"] <- thresholds

  precision["Metric"] <- "Precision"
  precision["Threshold"] <- thresholds

  recall["Metric"] <- "Recall"
  recall["Threshold"] <- thresholds
  
  df_comb <- rbind(f_score,precision,recall)
  df_melt <- reshape2::melt(df_comb,id.vars=c("Metric","Threshold"),variable.name="Method")
  
  g <- ggplot(df_melt,aes(Threshold,value,color=Method)) + facet_grid(.~ Metric) + geom_line(size= 0.6) + geom_point(aes(shape=Method))
  g <- g +  labs(x="Threshold on Anomaly score",y = "Value") + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.text = element_text(size = 8))
  #g <- g + scale_x_continuous(breaks=c(1:6),labels = c(1:6))
  g
  ggsave("sensitivity_anomaly_score.pdf", width = 9, height = 2.0,units="in")
  
  
  
  compute_f_score <- function(res_df,gt,threshold){
    if(is.xts(res_df)) {
      res_df_xts =  res_df
    }else{
      res_df_xts <- xts(res_df[,2:NCOL(res_df)],as.Date(res_df$Index,tz="Asia/Kolkata"))
    }
    res_df_xts <- res_df_xts["2014-07-01/2014-08-30 23:59:59"]
    print("Only retaining july and Aug res")
    #threshold = 0.8
    f_score <- vector(mode="numeric")
    precise <- vector(mode="numeric")
    recal <- vector(mode="numeric")
    for (i in 1:NCOL(res_df_xts)){
      dat <- res_df_xts[,i]
      dat <- dat[dat >= threshold]
      f_dates <- index(dat)
      a_dates <- gt$Index
      tp <- f_dates[f_dates %in% a_dates]
      fp <- f_dates[!f_dates %in% a_dates]
      fn <- a_dates[!a_dates %in% f_dates]
      precision = length(tp)/(length(tp)+length(fp))
      recall =  length(tp)/(length(tp)+length(fn))
      f_score[i] <- round( 2*(precision*recall)/(precision+recall),2)
      precise[i] <- round(precision,2)
      recal[i] <- round(recall,2)
      #browser()
    }
    l <- rbind(f_score,precise,recal)
    #colnames(l) <- colnames(res_df[,2:NCOL(res_df)])
    #print(l)
    return(l)
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
    g <- ggplot(df_melt,aes(thresholds,value,color=variable)) + geom_line(size=0.6) + geom_point(aes(shape=variable))
    g <- g +  labs(x='Standard deviation',y = "Accuracy Score")  + theme_grey(base_size = 11) 
    g <- g + theme(axis.text = element_text(color="Black",size=11),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 10))
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



effect_of_change_in_sigma_eEnergy2018 <- function()
{
  gt <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth_appliance/"
  oracle <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/oracle_sensitivity/"
  
  home = "3538.csv"
  fls <- list.files(oracle,pattern = paste0(strsplit(home,'[.]')[[1]][1],'_*'))
  # FOR AC
  gt_df <- read.csv(paste0(gt,home))
  res1 <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$ac==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$air1==1,]
    res1[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res1 <- do.call(rbind,res1)
  colnames(res1) <- c("Precision","Recall","Fscore")
  res1['thresholds'] <-  c(0.5,1.0,1.5,2.0,2.5)
  res1['Appliance'] = "AC"

  #sigma_sensitivity(res,thresholds,device,home)
  
  # FOR REFRIGERATOR
  gt_df <- read.csv(paste0(gt,home))
  res2 <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$fridge==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$refrigerator1==1,]
    res2[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res2 <- do.call(rbind,res2)
  colnames(res2) <- c("Precision","Recall","Fscore")
  res2['thresholds'] <-  c(0.5,1.0,1.5,2.0,2.5)
  res2['Appliance'] = "Refrigerator"

  
  #  FOR BOTH AC AND FRIDGE
  gt_df <- read.csv(paste0(gt,home))
  res3 <- list()
  for (i in 1:length(fls)){
    orac_df <- read.csv(paste0(oracle,fls[i]))
    gt_ac <- gt_df[gt_df$ac==1 | gt_df$fridge==1,] 
    #fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
    oracle_ac <- orac_df[orac_df$air==1 | orac_df$refrigerator1==1,]
    res3[[i]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
  }
  res3 <- do.call(rbind,res3)
  colnames(res3) <- c("Precision","Recall","Fscore")
  res3['thresholds'] <-  c(0.5,1.0,1.5,2.0,2.5)
  res3['Appliance'] = "Refrigerator + AC"
  
  
  df_comb <- rbind(res1,res2,res3)
  df_melt <- reshape2::melt(df_comb,id.vars=c("Appliance","thresholds"),variable.name="Metric")
  
  g <- ggplot(df_melt,aes(thresholds,value,color=Metric)) + facet_grid(.~ Appliance) + geom_line(size= 0.6) + geom_point(aes(shape=Metric))
  g <- g +  labs(x="Number of Standard deviations",y = "Anomay Score") + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.text = element_text(size = 8))
  #g <- g + scale_x_continuous(breaks=c(1:6),labels = c(1:6))
  g
  ggsave("sensitivity_sigma.pdf", width = 9, height = 2.0,units="in")
  
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
      geom_point(size=2) + theme_grey(base_size = 8) +
      geom_vline(aes(xintercept=day),linetype = 3, show.legend=TRUE) +
      labs(x= "Day #", y="Anomaly Score")+
      scale_x_continuous(breaks=seq(1,15,4)) +
      scale_shape_manual(name="k", labels=c(3,4,5,6,7),values=c(15,16,17,18,25))+
      scale_color_manual(name="k", labels=c(3,4,5,6,7),values=c("brown","black","blue","green", "red"))+
      theme(axis.text = element_text(color="Black",size=8),legend.position="top",
            legend.title=element_text(size=8),axis.title = element_text(color="Black",size=8))
    ggsave(file="k_sensitivity2.pdf", width=8, height=7, units="cm")
  }
  
  normalise_my_score <- function(df.lof2){
    res <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
    return(res)
  }
  
}


paper_discussion_section <- function(){
  # AT AGGREGATE LEVEL:
  # FIND STATSTISTS WHICH OF THE ANOMALIES ARE GETTING MISSED.
  library(xts)
  library(data.table)
  library(ggplot2)
  library(gtools)
  library(plotly)
  
  house = "115.csv"
  result <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/",strsplit(house,'[.]')[[1]][1],"/","energy_score.csv")
  gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth/"
  
  gt <- fread(paste0(gt_directory,house))
  gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
  res_df <- fread(result)
  res_df$Index <- as.Date(res_df$Index,tz="Asia/Kolkata") 
  
  res_above_th  <- res_df[res_df$lof>=0.8,]
  missed <- gt[!gt$Index %in% res_above_th$Index,]
  print(missed)
  res_df[res_df$Index %in% missed$Index,] 
  
  
  # AT APPLIANCE LEVEL
  # ANOMALY DETECTION NUMBERS
  house = "115.csv"
  result <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/fhmm/")
  gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth_appliance/"
  gt <- fread(paste0(gt_directory,house))
  gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
  res_df <- fread(paste0(result,house))
  res_df$Date <- as.Date(res_df$Date,tz="Asia/Kolkata") 
  missed <- gt[!gt$Index %in% res_df$Date,]
  print(missed[missed$mis==0,])
  
  result_or <- paste0("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/oracle/")
  gt_directory <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth_appliance/"
  gt <- fread(paste0(gt_directory,house))
  gt$Index <- as.Date(gt$Index,tz="Asia/Kolkata")
  res_df2 <- fread(paste0(result_or,house))
  res_df2$Date <- as.Date(res_df2$Date,tz="Asia/Kolkata") 
  missed <- gt[!gt$Index %in% res_df2$Date,]
  print(missed[missed$mis==0,])
  
}


compute_score_sigma_constant  <- function(dat,obs_per_day) {
  #browser()
  daydat <- split.xts(dat,f="days",k=1)
  daylen <- sapply(daydat,length)
  keep <- daylen >= obs_per_day
  daydat <-  daydat[keep]
  daymat <- sapply(daydat,function(x) coredata(x))
  # print(dim(daymat))
  colnames(daymat) <- paste0('D',1:dim(daymat)[2])
  flag <- apply(daymat,2,function(x) any(is.na(x)))
  daymat <- daymat[,!flag]
  daymat_xts <- xts(daymat, index(daydat[[1]]))
  
  rowMedian <- function(x, na.rm = FALSE)
  {
    apply(x, 1, median, na.rm = na.rm) 
  }
  # stat dataframe with mean and standard devation
  stat <- xts(data.frame(rowmean = rowMeans(daymat_xts,na.rm = TRUE)),index(daydat[[1]]))
  # stat <- xts(data.frame(rowmean = rowMedian(daymat_xts,na.rm = TRUE)),index(daydat[[1]]))
  stat <- cbind(stat,xts(data.frame(rowsd=apply(as.matrix(coredata(daymat_xts)),1,sd,na.rm=TRUE)),index(daydat[[1]])))
  status <- vector()
  for( i in 1:dim(daymat_xts)[2]) {
    status[i] <- all((daymat_xts[,i] <= (stat$rowmean + 2*stat$rowsd)) & ( daymat_xts[,i] >= (stat$rowmean - 2*stat$rowsd) ))
  }
  score <- round(sum(status,na.rm = TRUE)/length(status),2)
  
  return(score)
}
