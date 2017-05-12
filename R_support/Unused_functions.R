# this contains functions which were developed during project but were not used in #the final project. 


summarize_context_without_daynight_division <- function(temp_data){
  # this function suammmarizes context (temperature, humdity and time ) into one varible, BUT it does not
  # divide time into contexts, i.e, day, night etc. For that please refer to the next version of this function.
  #weather_file <- "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/weather/Austin2014/minute_Austinweather.csv"
  #df <- fread(weather_file)
  #df_xts <- xts(df[,2:3],fasttime::fastPOSIXct(df$localminute)-19800)
  #df_sub <- df_xts['2014-06-01/2014-08-30']
  #print(dim(temp_data))
  # browser()
  df_sub <-  temp_data
  if("occupancy" %in% colnames(df_sub)) {
    keep  <- c('occupancy')
  }else {
    keep  <- 'TemperatureC' }
  df_sub <- df_sub[,keep]
  # browser()
  df_sub$time <- lubridate::hour(index(df_sub)) + lubridate::minute(index(df_sub))
  dat_day <- split.xts(df_sub,"days",k=1)
  # browser()
  lower_embedding <- lapply(dat_day, function(x){
    temp <- coredata(x)
    temp <- scale(temp)
    dis_mat <- dist(temp) 
    #browser()
    fit_val <- cmdscale(dis_mat, eig = TRUE, k = 1)
    scale_eigen <- as.vector(scale(fit_val$points))
    score_eigen_xts <- xts(scale_eigen,index(x))
    return(score_eigen_xts)
  })
  res <- do.call(rbind,lower_embedding)
  return(res)
  #outlierfactor(lower_embedding)
}

summarize_context_with_daynight_divison <- function(temp_data) {
  # this function takes context DATAFRAME and then creates a summarized vector 
  temp_data$time <- lubridate::hour(index(temp_data)) + lubridate::minute(index(temp_data))
  hour <- as.vector(lubridate::hour(index(temp_data)))
  cat = ifelse(hour<=5,1,ifelse(hour<=11,2,ifelse(hour<=17,3,4)))
  temp_data$context = cat
  # this splitting is important otherwise dist function computes distance of morning with evening hours also, which is not 
  # required.so create separte slices and work on slices .....
  context_wise <- split(temp_data,f=temp_data$context) # Now every reading is associated with context
  lower_dim <- lapply(context_wise,function(x){ # I have data of only one context
    if("occupancy" %in% colnames(x)){
      keep  <- c('TemperatureC','time','occupancy')
    } else {
      keep  <- c('TemperatureC','time') }
    temp <- x[,keep] # drop remaining columns
    day_dat <- split.xts(temp,"days",k=1) # separate days
    day_lower_embedings <- lapply(day_dat,function(y){
      temp2 <- coredata(y)
      dis_mat <- dist(temp2) 
      #browser()
      fit_val <- cmdscale(dis_mat, eig = TRUE, k = 1)
      scale_eigen <- as.vector(scale(fit_val$points))
      scale_eigen <- xts(scale_eigen,index(y))
      colnames(scale_eigen) <- "power"
      return(scale_eigen)
    })
    res <- do.call(rbind,day_lower_embedings)
    return(res)
  })
  complete_context <- do.call(rbind,lower_dim) # combines data from all the contexts
  #days_data <- split.xts(complete_context,"days",k=1)
  #lower_embed <- sapply(days_data,function(x){
  #                return(coredata(x))
  #                  })
  #outlierfactor(lower_embed)
  return(complete_context)
}


compute_LOF_With_Day_Verticals_Context <- function(inputdata) {
  #fd <- complete_context
  fd <- inputdata
  #colnames(fd) <- "power"
  hour <- as.vector(lubridate::hour(index(fd)))
  fd$cat = ifelse(hour<=5,1,ifelse(hour<=11,2,ifelse(hour<=17,3,4)))
  fd_split <- split(fd,f=fd$cat)
  time_windows <- c('05:59:00','11:59:00','17:59:00','23:59:00')
  temp_res <- mapply(function(x,z) {
    x <- x[,'power'] # dropping extra columns
    stopifnot(length(x)>0)
    daydat <- split.xts(x,"days",k=1)
    daydat_mat <- sapply(daydat,function(y) coredata(y))
    outlier <- outlierfactor(daydat_mat)
    #outlier <- outlierfactor_without_normalization(daydat_mat)
    dates <- unique(as.Date(index(x),tz="Asia/Kolkata"))
    datetime <- paste(dates,z)
    datetime <- fasttime::fastPOSIXct(datetime)-19800
    temp_res <- xts(outlier,datetime)
    return(temp_res)
  },x = fd_split, z = time_windows) # mapply function
  # replace normalization 1 with 0.5
  res = ifelse(temp_res == 1,0.8,temp_res) # used to change 1's introduced by normalization
  context = apply(res, 1, max)
  #browser()
  context_xts <- xts(context, unique(as.Date(index(fd),tz="Asia/Kolkata")))
  return(context_xts)
}

outlierfactor_without_normalization <- function(daymat){
  # all results in the paper have been presented using this function
  daymat <- daymat[complete.cases(daymat),] # removes rows containing NAs
  # daymat1 <- as.xts(t(apply(daymat,1, function(x) abs(fft(x-mean(x)))^2/length(x))) ) # form 1
  # daymat2 <- as.xts(t(apply(daymat,1, function(x) abs(fft(x-mean(x)))/length(x))) )  # form 2
  # daymat1 <- as.xts(t(apply(daymat,1, function(x) Mod(Re(fft(x-mean(x)))))) )   #form 3
  daymat <- daymat
  # browser()
  dis_mat <- dist(t(daymat)) 
  fit <- cmdscale(dis_mat, eig = TRUE, k = 2)
  x <- scale(fit$points[, 1])
  y <- scale(fit$points[, 2]);  # mymdsplot(x,y,"abc.pdf")
  daymat <- data.frame(x,y)
  
  df.lof2 <- lof(daymat,c(4:6),cores = 2)
  #browser()
  #  df.lof2 <- apply(df.lof2,2,normalizedata)
  #df.lof2 <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
  # browser()
  # anom_mean <- apply(df.lof2,1,function(x) round(mean(x,na.rm=TRUE),2) )
  anom_max <-  apply(df.lof2,1,function(x) round(max(x,na.rm = TRUE),2) )#feature bagging for outlier detection
  #df=data.frame(day= c(format(start(daymat),"%d"):format(end(daymat),"%d")), score=anom_max,month=format(index(daymat[5,]),"%Y-%m"))
  # anom_sum1 <-  apply(df.lof2,1,function(x) round(sum(x),2) )
  # return(df)
  return(anom_max)
}

summarize_context_with_clustering <- function(temp_data,clus_centers){
  df_sub <-  temp_data
  keep <- c("TemperatureC","occupancy")
  df_sub <- df_sub[,keep]
  # if("occupancy" %in% colnames(df_sub)) {
  #   keep  <- c('occupancy')
  # }else {
  #   keep  <- 'TemperatureC' }
  # df_sub <- df_sub[,keep]
  # # browser()
  df_sub$time <- lubridate::hour(index(df_sub)) + lubridate::minute(index(df_sub))
  dat_day <- split.xts(df_sub,"days",k=1)
  # browser()
  lower_embedding <- lapply(dat_day, function(x){
    temp <- coredata(x)
    temp <- scale(temp)
    #browser()
    fit_val <- kmeans(temp,centers = clus_centers)$cluster
    score_eigen_xts <- xts(fit_val,index(x))
    return(score_eigen_xts)
  })
  res <- do.call(rbind,lower_embedding)
  return(res)
  #outlierfactor(lower_embedding)
}