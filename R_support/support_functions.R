
create_weather_power_object_fromAggDataport <- function(path1,file1,file2) {
  
  powerdata<- fread(paste0(path1,file1),header=TRUE,sep=",")
  #xx<- read.csv(paste0(path,file1),header=TRUE,sep=",")
  weatherdata <- fread(file2,header=TRUE,sep=",")
  browser()
  power_data <- xts(powerdata$use,as.POSIXct(strptime(powerdata$localminute,format="%Y-%m-%d %H:%M:%S"),origin="1970-01-01")) 
  names(power_data)="power"
 # power_data <- power_data['2014-06-01/2014-08-30/']
  #print ("clipped power data between june and aug")
  weather_data<- xts(data.frame(temperature=weatherdata$TemperatureC,humidity=as.numeric(weatherdata$Humidity)),order.by = as.POSIXct(weatherdata$localminute,origin="1970-01-01"))
  
  return(list(power_data=power_data,weather_data=weather_data)) 
}