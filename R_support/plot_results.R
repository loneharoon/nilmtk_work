setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/plots/")

fscore_df = data.frame("1463"=c(0.81,0.70,0.50),
                       "3538"=c(0.83,0.52,0.28),
                       "490"=c(0.73,0.57,0.38),
                       "115"=c(0.72,0.57,0.53))
row.names(fscore_df) = c("Lof","Muser","hp")
df = as.data.frame(t(fscore_df))
plot_bar_plots(df,"F-score")

prec_df = data.frame("1463"=c(0.92,1,0.54),
                     "3538"=c(1,0.67,0.27),
                     "490"=c(1,0.86,0.45),
                     "115"=c(0.90,1,0.53))
row.names(prec_df) = c("Lof","Muser","hp")
df = as.data.frame(t(prec_df))
plot_bar_plots(df,"Precision")


recall_df = data.frame("1463"=c(0.73,0.53,0.47),
                       "3538"=c(0.71,0.43,0.29),
                       "490"=c(0.57,0.43,0.33),
                       "115"=c(0.60,0.40,0.53))
row.names(recall_df) = c("Lof","Muser","hp")
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
g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position="top",legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9),legend.title=element_blank())
g
#ggsave("accuracy.pdf", width = 8, height = 6,units="cm") 
##############################APPLIANCE LEVEL SCORES#########################

ac_fscore_df = data.frame("1463"=c(0.40,0.67),
                          "3538"=c(0.71,0.70),
                          "490"=c(0.70,0.82),
                          "115"=c(0.44,0.83))
row.names(ac_fscore_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(ac_fscore_df))
plot_bar_plots_appliance(df,"F-score","ac_fscore")


ac_precision_df = data.frame("1463"=c(0.50,0.67),
                             "3538"=c(0.86,0.70),
                             "490"=c(0.70,0.82),
                             "115"=c(0.67,0.83))
row.names(ac_precision_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(ac_precision_df))
plot_bar_plots_appliance(df,"Precision","ac_precision")


ac_recall_df = data.frame("1463"=c(0.33,0.67),
                          "3538"=c(0.60,0.70),
                          "490"=c(0.70,0.82),
                          "115"=c(0.33,0.83))
row.names(ac_recall_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(ac_recall_df))
plot_bar_plots_appliance(df,"Recall","ac_recall")
###########%%%%%%%%%%%%%%%%%%%%%%%%%FRIDGE######################

fridge_fscore_df = data.frame("1463"=c(0.15,0.86),
                              "3538"=c(0.07,0.86),
                              "490"=c(0.27,0.83),
                              "115"=c(0.16,0.86))
row.names(fridge_fscore_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(fridge_fscore_df))
plot_bar_plots_appliance(df,"F-score","fridge_fscore")

fridge_precision_df = data.frame("1463"=c(0.08,1),
                                 "3538"=c(0.04,0.1),
                                 "490"=c(0.16,0.77),
                                 "115"=c(0.09,0.86))
row.names(fridge_precision_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(fridge_precision_df))
plot_bar_plots_appliance(df,"Precision","fridge_precision")

fridge_recall_df = data.frame("1463"=c(0.80,0.75),
                              "3538"=c(0.25,0.75),
                              "490"=c(0.92,0.91),
                              "115"=c(0.88,0.86))
row.names(fridge_recall_df) <- c("FHMM","Oracle")
df <- as.data.frame(t(fridge_recall_df))
plot_bar_plots_appliance(df,"Recall","fridge_recall")





plot_bar_plots_appliance <- function(df,ylabel,savename){
  df$idcol = seq(1,4)
  df_melt <- reshape2::melt(df,id.vars=c("idcol"))
  g <- ggplot(df_melt,aes(idcol,value,fill=variable)) + geom_bar(position="dodge",stat="identity",width = 0.7)
  g <- g +  labs(x="Home #",y = ylabel) + theme_grey(base_size = 10) 
  g <- g + theme(axis.text = element_text(color="Black",size=9),legend.position = "top",legend.title=element_blank(),legend.background = element_rect(fill = alpha('white',0.3)),legend.text = element_text(size = 9))
  g
  ggsave(paste0(savename,".pdf"), width = 6, height = 6,units="cm") 
}