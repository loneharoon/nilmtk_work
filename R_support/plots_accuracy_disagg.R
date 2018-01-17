# in this script I plot precis, recall and f-score of disag tech
# 
setwd("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/Writings/Localize/eEnergy_2018/plots/")
ac_data = data.frame( "Home"=c(rep_len(1,9),rep_len(2,9),rep_len(3,9),rep_len(4,9),rep_len(5,9),rep_len(6,9)),
                       "Approach"= rep(c("FHMM","CO","LBM"),3*6),
                       "value"=c(0.98,1,0.78,0.98,0.96,0.94,0.98,0.98,0.85,
                                 0.99,0.99,0.39,0.96,0.94,1,0.97,0.96,0.54,
                                 1,1,0.47,0.99,0.98,0.99,0.99,0.99,0.64,
                                 0.97,0.99,0.22,0.72,0.93,0.45,0.83,0.96,0.30,
                                 0.97,0.99,0.23,0.88,0.81,0.99,0.92,0.89,0.38,
                                 0.98,0.99,0.32,0.63,0.91,1,0.77,0.95,0.48),
                       "value_type"= rep(c(rep_len("Precision",3),rep_len("Recall",3),rep_len("Fscore",3)),6))

fridge_data = data.frame( "Home"=c(rep_len(1,9),rep_len(2,9),rep_len(3,9),rep_len(4,9),rep_len(5,9),rep_len(6,9)),
                      "Approach"= rep(c("FHMM","CO","LBM"),3*6),
                      "value"=c(0.85,0.82,0.71,0.87,0.90,0.86,0.86,0.86,0.78,
                                0.71,0.71,0.57,0.64,0.90,0.99,0.67,0.79,0.72,
                                0.73,0.73,0.48,0.73,0.79,1,0.73,0.76,0.64,
                                0.69,0.72,0.28,0.85,0.87,0.49,0.76,0.79,0.36,
                                0.89,0.81,0.84,0.65,0.43,0.84,0.75,0.57,0.84,
                                0.71,0.71,0.57,0.64,0.90,0.99,0.67,0.79,0.72),
                      "value_type"= rep(c(rep_len("Precision",3),rep_len("Recall",3),rep_len("Fscore",3)),6))



#ggplot(ac_data,aes(Home,value,fill=technique)) + facet_grid(.~value_type) + geom_bar(position="dodge",stat="identity",width = 0.4)


ac_data$appliance="AC"
fridge_data$appliance="Refrigerator"

temp = rbind(ac_data,fridge_data)

g <- ggplot(temp,aes(Home,value,fill=Approach)) + facet_grid(appliance~value_type) + geom_bar(position="dodge",stat="identity",width = 0.4)
g <- g +  labs(x="Home",y = "Value") + theme_grey(base_size = 10) 
g <- g + theme(axis.text = element_text(color="Black",size=9),legend.text = element_text(size = 8))
g <- g + scale_x_continuous(breaks=c(1:6),labels = c(1:6))
g
ggsave("disagg_scores.pdf", width = 9, height = 3,units="in")

g