# I have done various things in this script: Some of them which I recall are
# 1. Compute F-score,precison and recall of UNUM  on both disaggregated and normal appliance data.  


# dissagregation
# RMSE _NORMALISATION ERROR
house_no = c(115,434,490,1463,3538)
homes <- paste0("norm_rmse_",house_no,".csv")
dir = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/disagg_results/" 
h_list = list()
for (i in 1:length(homes)){
  temp = read.csv(paste0(dir,homes[i]))
  row.names(temp) =  temp$X
  keep = c("fhmm_norm","co_norm")
  temp =  temp[keep]
  colnames(temp) <- paste0(house_no[i],"_",c("fhmm","co"))
  h_list[[i]] <- temp
}

h_list

# KOLTER ACCURACY
accu = list()
homes <- paste0("accuracy_kolter_",house_no,".csv")
for (j in 1:length(homes)){
  temp = read.csv(paste0(dir,homes[j]))
  df = data.frame(abs(t(temp$accuracy)))
  colnames(df) = c("FHMM","CO")
  row.names(df) = house_no[j]
 # row.names(temp) =  t
  #keep = c("fhmm_norm","co_norm")
  #temp =  temp[keep]
  #colnames(temp) <- paste0(house_no[i],"_",c("fhmm","co"))
accu[[j]] <- df
}
do.call(rbind,accu)

# COMPUTE APPLIANCE WISE ANOMALY DETECTION ACCURACY METRICS AFTER APPLYING DISSAGREGATION
# stage 3: For appAD and Oracle
rm(list=ls())
home= "redd_home_6.csv" #"3538.csv" # "meter_2.csv" #"redd_home_6.csv"
gt <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/ground_truth_appliance/"
oracle <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/oracle/"
fhmm <- "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/fhmm/"

gt_df <- read.csv(paste0(gt,home))
orac_df <- read.csv(paste0(oracle,home))
fhmm_df <- read.csv(paste0(fhmm,home))

gt_ac <- gt_df[gt_df$ac==1,] 
fhmm_ac <- fhmm_df[fhmm_df$air1==1,]
oracle_ac <- orac_df[orac_df$air1==1,]

gt_fridge <- gt_df[gt_df$fridge==1,] 
fhmm_fridge <- fhmm_df[fhmm_df$refrigerator1==1,]
oracle_fridge <- orac_df[orac_df$refrigerator1==1,]

res <- list()
res[["AC_FHMMM"]] <- compute_accuracy_statistics(gt_ac,fhmm_ac)
res[["AC_Oracle"]] <- compute_accuracy_statistics(gt_ac,oracle_ac)
res[["Fridge_FHMMM"]] <- compute_accuracy_statistics(gt_fridge,fhmm_fridge)
res[["Fridge_Oracle"]] <- compute_accuracy_statistics(gt_fridge,oracle_fridge)
res <- do.call(rbind,res)
res


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