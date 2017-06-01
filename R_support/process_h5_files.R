
library(rhdf5)
dir <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/wiki-energy/"
fname <- paste0(dir,"dataport_minutely.h5")
readhandle = H5Fopen(fname)
writedir <-  '/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default3/'
#homes = paste0(c(101,114,115,410,457,936,1037,1069,1086,1105,1314,2094,2365,2845,2864,3235,4154,4298,4910,6165,7276,9201,9340,9931),".csv")
homes = h5ls(readhandle,all = FALSE)$name

for(i in 1:length(homes)){
dframe <- h5read(readhandle,homes[i])
dframe$V1 <- fasttime::fastPOSIXct(dframe$V1)-19800
colnames(dframe)[1] <- "localminute"
df_sub <- dframe[dframe$localminute >= "2014-06-01 00:00:00" & dframe$localminute <= "2014-08-30 23:59:00",]
#write.csv(df_sub,paste0(writedir,homes[i]),row.names = FALSE)
}


