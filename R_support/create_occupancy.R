
# this scipt is used to create occupancy data corresponding to power consumption of a home


path2 <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/" 
savepath <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/occupancy/"
fls <- list.files(path2,pattern = "*.csv")
for(i in 1:length(fls)){
  df <- fread(paste0(path2,fls[i]))
  df_xts <- xts(df[,'use'],fasttime::fastPOSIXct(df$localminute)-19800)
  df_xts <- df_xts['2014-06-01/2014-08-30 23:59:59']
  occu_data <- create_time_series_occupancydata(df_xts,400)
  write.csv(fortify(occu_data),file = paste0(savepath,fls[i]),row.names = FALSE)
}






create_time_series_occupancydata <- function(power_data,baseline_limit){
  if(dim(power_data)[2] == 1){
    occupancy = ifelse(power_data > baseline_limit,1,0)
  } else if("power" %in% colnames(power_data)) {
    occupancy = ifelse(power_data > baseline_limit,1,0)
  } else if("use" %in% colnames(power_data)){
    occupancy = ifelse(power_data$use > baseline_limit,1,0)
  } else {
    stop("No related column found")
  }
  occupancy_xts <- xts(occupancy,index(power_data))
  colnames(occupancy_xts) <- "occupancy"
  return(occupancy_xts)
}