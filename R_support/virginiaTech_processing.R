library(xts)
library(data.table)
library(ggplot2)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/VirginiaTech_data/"
# dryer, refrig,washer, AC
home <- "TotalHouse_big_1sec.txt"
df1 <- fread(paste0(path,home),sep="auto",skip = 4)

df1_xts <- xts(df1[,-1],fasttime::fastPOSIXct(df1$Index)-19800)
colnames(df1_xts)