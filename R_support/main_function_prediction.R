library(xts)
library(data.table)
library(ggplot2)
library(gtools)


file1 <- "115.csv"
#house_no <- "house1_10min.csv"
#path1 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
path1 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
file2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/minute_Austinweather.csv"
#eco_dataset_path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/ECO_dataset/"
source("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/R_support/support_functions.R")
#data_ob <- create_weather_power_object(path1,file1,file2)
data_ob <- create_weather_power_object_fromAggDataport(path1,file1,file2)

print("DATA RANGES ARE:")
print(paste0("Power data,","start: ",index(first(data_ob$power_data))," end: ",index(last(data_ob$power_data))))
print(paste0("Weather data,","start: ",index(first(data_ob$weather_data))," end: ",index(last(data_ob$weather_data))))
merge_start_date <- as.POSIXct(strptime('2014-06-01',format = "%Y-%m-%d"))
merge_end_date   <- as.POSIXct(strptime('2014-08-30',format = "%Y-%m-%d"))
#confirm_validity(data_ob,merge_start_date,merge_end_date)
my_range<- paste0(merge_start_date,'/',merge_end_date)
sampled_ob <- combine_energy_weather(data_ob,my_range)
train_data <- sampled_ob['2014-06-05/2014-06-25']
test_data <- sampled_ob['2014-06-26/2014-07-30']

neural_result <- neuralnetwork_procedure(train_data,test_data,hourwindow = 6, daywindow = 15)
res_reg <- find_anomalous_status(test_data,result=neural_result,anomaly_window = 1,anomalythreshold_len = 60)
res_reg[res_reg==TRUE]
