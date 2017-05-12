normalizedata <- function(x){
  xx<- vector(mode="numeric",length=length(x))
  minval= min(x)
  maxval= max(x)
  for (i in 1:length(x)){
    xx[i] <- (x[i]-minval)/(maxval-minval)
  }
  return (xx)
}

create_feature_matrix <- function(tdata) {
  #daydata <- split.xts(tdata,f="days",k=1)
  #sapply(daydata)
  matdata <- as.data.frame(sapply(tdata,function(x) coredata(x$power)))
  mat_xts <- xts(matdata,index(tdata[[1]]))
  return(mat_xts)
}

summarize_context_with_individual_features <- function(temp_data){
  # in this we take each of the features and run anomaly detection algorithm
  data <- temp_data
  keep = c("TemperatureC","occupancy")
  data <-  data[,keep]
  features <- colnames(data)
  scores <- sapply(features, function(x){
    df  <- data[,x]
    # browser()
    colnames(df) <- "power" # acco. to create_feature_matrix function
    dat_day <- split.xts(df,"days",k=1)
    mat_day <- create_feature_matrix(dat_day)
    res <- outlierfactor(mat_day)
    return(res) 
  })
  # browser()
  f_scores<- apply(scores,1,max)
  date_index <- sapply(temp_data[,1],function(x) unique(as.Date(index(x),tz="Asia/Kolkata")))
  f_scores_xts <- xts(f_scores,as.Date(date_index))
  return (f_scores_xts)
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
outlierfactor <- function(daymat){
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
  #df.lof2 <- apply(df.lof2,2,normalizedata)
  df.lof2 <- apply(df.lof2,2,function(x) Func.trans(x,method = "FBOD"))
  # browser()
  # anom_mean <- apply(df.lof2,1,function(x) round(mean(x,na.rm=TRUE),2) )
  anom_max <-  apply(df.lof2,1,function(x) round(max(x,na.rm = TRUE),2) )#feature bagging for outlier detection
  #df=data.frame(day= c(format(start(daymat),"%d"):format(end(daymat),"%d")), score=anom_max,month=format(index(daymat[5,]),"%Y-%m"))
  # anom_sum1 <-  apply(df.lof2,1,function(x) round(sum(x),2) )
  # return(df)
  return(anom_max)
}

