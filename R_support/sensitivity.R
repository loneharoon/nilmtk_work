

# FOR  SENSITIVITY ANALYSIS OF UPPER ANOMALY SCORES

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
