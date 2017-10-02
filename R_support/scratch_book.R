
compute_score_sigma_constant  <- function(dat,obs_per_day) {
   #browser()
   daydat <- split.xts(dat,f="days",k=1)
   daylen <- sapply(daydat,length)
   keep <- daylen >= obs_per_day
   daydat <-  daydat[keep]
  daymat <- sapply(daydat,function(x) coredata(x))
 # print(dim(daymat))
  colnames(daymat) <- paste0('D',1:dim(daymat)[2])
  flag <- apply(daymat,2,function(x) any(is.na(x)))
  daymat <- daymat[,!flag]
  daymat_xts <- xts(daymat, index(daydat[[1]]))

  rowMedian <- function(x, na.rm = FALSE)
  {
    apply(x, 1, median, na.rm = na.rm) 
  }
  # stat dataframe with mean and standard devation
  stat <- xts(data.frame(rowmean = rowMeans(daymat_xts,na.rm = TRUE)),index(daydat[[1]]))
  # stat <- xts(data.frame(rowmean = rowMedian(daymat_xts,na.rm = TRUE)),index(daydat[[1]]))
  stat <- cbind(stat,xts(data.frame(rowsd=apply(as.matrix(coredata(daymat_xts)),1,sd,na.rm=TRUE)),index(daydat[[1]])))
  status <- vector()
   for( i in 1:dim(daymat_xts)[2]) {
     status[i] <- all((daymat_xts[,i] <= (stat$rowmean + 2*stat$rowsd)) & ( daymat_xts[,i] >= (stat$rowmean - 2*stat$rowsd) ))
   }
  score <- round(sum(status,na.rm = TRUE)/length(status),2)

  return(score)
}
