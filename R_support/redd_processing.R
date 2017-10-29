# we proceess Home 6 data of REDD dataset because it contains both AC and fridge data. Aim is select meaningful of days for disaggregation.
library(xts)
library(data.table)
library(ggplot2)
path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Redd_dataset/house6/"

process_home6_data<- function(){
  # read main meters data
  home <- "main_meters.csv"
  df1 <- fread(paste0(path,home),sep="auto")
  df1_xts <- xts(df1[,-1],fasttime::fastPOSIXct(df1$Index)-19800)
  colnames(df1_xts)
  
  # read sub meters data
  df2 <- fread(paste0(path,"sub_meters.csv"),sep="auto")
  df2_xts <- xts(df2[,-1],fasttime::fastPOSIXct(df2$Index)-19800)
  colnames(df2_xts)
  
  # combine main and sub meters data
  comb <- cbind(df1_xts,df2_xts)
  # subtract ac data from mains
  comb$use <- rowSums(comb[,c('mains','mains.1')],na.rm = TRUE) - rowSums(comb[,c('air_conditioning','comb$air_conditioning.1','comb$air_conditioning.2')],na.rm = TRUE)
  keep <- c("kitchen_outlets","washer_dryer","stove","electronics","bathroom_gfi","refrigerator","dishwaser","outlets_unknown","outlets_unknown.1","electric_heat","kitchen_outlets.1","lighting","use","mains")
  # remove AC data from data frame
  comb_new <- comb[,keep]
  # remove bad rows in following two subsequent steps
  bad_rows <- which(is.na(comb_new$mains))
  temp <- comb_new[-bad_rows,]
  bad_rows_neg <-  which(temp$use<0)
  temp2 <- temp[-bad_rows_neg,]
  #temp2 <- temp2[,-mains]
  
  #remove days with lots of missing readings
  set1 <- temp2["/2011-05-30 23:59:59"]
  set1_int <- fill_missing_readings_with_NA(set1,"1 sec")
  set1_int <- na.approx(set1_int)
  colnames(set1_int) <- colnames(set1)
  
  set2 <- temp2["2011-06-07/2011-06-13 23:59:59"]
  set2_int <- fill_missing_readings_with_NA(set2,"1 sec")
  set2_int <- na.approx(set2_int)
  colnames(set2_int) <- colnames(set2)
  
  
  set <- rbind(set1_int,set2_int)
  set <- set["2011-05-22/"]
  # Run create_AC_data function to get AC data
  set$air <- coredata(create_AC_data()[1:dim(set)[1]])
  set$use <- set$use + set$air
  set <- set[,-14] # removing obselete mains column
  write.csv(data.frame(localminute=index(set),coredata(set)),paste0(path,"processed_data.csv"),row.names = FALSE)
  
  visualize_dataframe_one_column_facet_form_day_wise(set$use,7)
  
  visualize_dataframe_all_columns(comb_new["2011-05-31"][,c('use','air')])
  visualize_dataframe_all_columns(comb["2011-05-31"][,c('air_conditioning.2')])
  
}

create_AC_data <- function() {
  # this function reads minutely AC data interpolates to seconds level and returns such data
  dpath <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Redd_dataset/"
  fl <- "ac_data.csv"
  fls <- fread(paste0(dpath,fl),sep="auto")
  fl_xts <- xts(fls[,-1],fasttime::fastPOSIXct(fls$Index)-19800)
  sel <- fl_xts[,3]
  sec_df <- fill_missing_readings_with_NA(sel,"1 sec")
  sec_na <- na.approx(sec_df)
  return(sec_na)
}



visualise_specific_data_portions <- function() {
  path <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Redd_dataset/house6/"
  home <- "processed_data.csv"
  df <- fread(paste0(path,home),sep="auto")
  df_xts <- xts(df[,-1],fasttime::fastPOSIXct(df$localminute)-19800)
  colnames(df_xts)
  
  visualize_dataframe_one_column_facet_form_day_wise(df_xts$refrigerator,7)
  
  visualize_dataframe_all_columns(df_xts["2011-05-26"]$refrigerator)

}
