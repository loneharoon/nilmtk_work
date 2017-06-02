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
