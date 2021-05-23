rm(list=ls())
library(CausalImpact)
library(tidyverse)
library(lubridate)
library(data.table)
library(reshape2)
library(optparse)

####################### REPLACE NA VALUES FUNCTIONS ##################################

replacena1 <- function(l) {
  stopifnot(is.numeric(l))
  indx <- is.na(l)
  l[indx] <- vapply(which(indx), function(x) {mean(c(l[x - 1], l[x + 1])) }, FUN.VALUE = double(1))
  l
}

replacena2 <- function(l) {
  stopifnot(is.numeric(l))
  indx <- is.na(l)
  l[indx] <- vapply(which(indx), function(x) {if( is.na(l[x-1]) ){ l[x+1] } else if( is.na(l[x+1])) { l[x-1] } else mean(c(l[x - 1], l[x + 1])) }, FUN.VALUE = double(1))
  l
}

replacena.while <- function(x) {
  x <- replacena1(x)
  success <- FALSE
  while (!success) {
    x <- replacena2(x)
    success <- sum(is.na(x))==0
  }
  return(x)
}

####################### ALIGN DATA FUNCTION ##################################

align_data_function <- function(combined.data, date1, date2, interval, vars){
  total.period <- format(seq.POSIXt(date1, date2, by = paste(interval, "min")),
                         "%Y-%m-%d %H:%M:%S")
  aligned.data <- data.frame(Time=total.period)
  
  print("ALIGNING AND CLEANING DATA...")
  for (i in 1:length(vars))
  {
    tmp <- combined.data[which(combined.data$Variable == vars[i]), ]
    tmp$AlignTime <- align.time(as.POSIXct(paste(tmp$Date,tmp$Time, sep=" ")), interval*60)
    tmp.new <- tmp[tmp$AlignTime %within% int,]
    if (nrow(tmp.new) > 0) {
      aligned.data[, vars[i]] <- NA
      aligned.data[match(as.character(tmp.new$AlignTime), as.character(aligned.data$Time)), vars[i]] <- as.numeric(as.character(tmp.new$Value))
      if (is.na(aligned.data[1, vars[i]])){
        aligned.data[1, vars[i]] <- na.omit(aligned.data[, vars[i]])[1]
      }
      if(is.na(aligned.data[nrow(aligned.data), vars[i]])){
        aligned.data[nrow(aligned.data), vars[i]] <- na.omit(aligned.data[, vars[i]])[length(na.omit(aligned.data[, vars[i]]))]
      }
      aligned.data[, vars[i]] <- replacena.while(aligned.data[, vars[i]])
    }
  }
  return(aligned.data)
}


####################### CASUAL IMPACT ANAYLSIS FUNCTION ##################################

anaylzing_causalimpact_function <- function(aligned.data, intervention.date, flag){
  print("ANALYZING CAUSAL IMPACT...")
  ## CAUSAL IMPACT ANALYSIS
  if(flag == TRUE){
    intervention.row <- which(as.character(aligned.data$Time) == as.character(as.Date(intervention.date)))
  }else{
    intervention.row <- which(as.character(aligned.data$Time) == as.character(intervention.date))
  }
  
  y <- aligned.data[, dependent_variable] # dependent variable
  ## check what happens when x1 is not just a 1col after removing time + dep.
  x1 <- aligned.data[, -which(names(aligned.data) %in% c(dependent_variable, "Time"))] # covariates
  post.period <- c(intervention.row, dim(aligned.data)[1])
  post.period.response <- y[post.period[1] : post.period[2]]
  y[post.period[1] : post.period[2]] <- NA
  y <- as.numeric(y)
  x1 <- as.data.frame(x1)
  df.tmp <- cbind(y,x1)
  ss <- AddLocalLinearTrend(list(), y)
  ss <- AddLocalLevel(list(), y)
  bsts.model <- bsts(y~., state.specification=ss, data=df.tmp, niter = 1000)
  
  impact <- CausalImpact(bsts.model = bsts.model,
                         post.period.response = as.numeric(post.period.response),
                         model.args = list(nseasons = 7, season.duration = 1,dynamic.regression=T))
  
  print("SAVING ANALYSIS RESULTS TO DIRECTORY")
  title <- paste("Causal Impact of Intervention On", dependent_variable)
  p <- plot(impact) + ggtitle(title)
  ggsave(filename = "CausalImpact.pdf", plot = p, device = "pdf", width = 10, height = 7)
  
  title <- "CausalImpactSummary.txt"
  fileConn <- file(title)
  writeLines(capture.output(summary(impact, "report")), fileConn)
  close(fileConn)
  print(paste("p-value:",impact$summary["Average","p"]))
}

####################### AGGREGATE DAILY MEANS FUNCTIONS ##################################

##make three functions for different cases 
diabetes_in_target_aggregate <- function(aligned.data, lower_bound, upper_bound, dependent_variable){
  temp_dependent <- aggregate(aligned.data[, as.character(dependent_variable)], list(as.Date(aligned.data$Time)), FUN=function(x){y <- sum(x > lower_bound & x < upper_bound)/length(x); return(y)})
  temp_covariates <- ag_daily_mean <- aggregate(aligned.data[, -which(names(aligned.data) %in% c(dependent_variable, "Time"))], list(as.Date(aligned.data$Time)), FUN=mean)
  aligned.data.return <- cbind(temp_dependent, temp_covariates)
  names(aligned.data.return)[names(aligned.data.return) == "Group.1"] <- "Time"
  names(aligned.data.return)[names(aligned.data.return) == "x"] <- as.character(dependent_variable)
  return(aligned.data.return)
}

diabetes_above_target_aggregate <- function(aligned.data, upper_bound, dependent_variable){
  temp_dependent <- aggregate(aligned.data[, as.character(dependent_variable)], list(as.Date(aligned.data$Time)), FUN=function(x){y <- sum(x > upper_bound)/length(x); return(y)})
  temp_covariates <- ag_daily_mean <- aggregate(aligned.data[, -which(names(aligned.data) %in% c(dependent_variable, "Time"))], list(as.Date(aligned.data$Time)), FUN=mean)
  aligned.data.return <- cbind(temp_dependent, temp_covariates$x)
  names(aligned.data.return)[names(aligned.data.return) == "Group.1"] <- "Time"
  names(aligned.data.return)[names(aligned.data.return) == "x"] <- as.character(dependent_variable)
  return(aligned.data.return)
}

diabetes_below_target_aggregate <- function(aligned.data, lower_bound, dependent_variable){
  temp_dependent <- aggregate(aligned.data[, as.character(dependent_variable)], list(as.Date(aligned.data$Time)), FUN=function(x){y <- sum(x > lower_bound)/length(x); return(y)})
  temp_covariates <- ag_daily_mean <- aggregate(aligned.data[, -which(names(aligned.data) %in% c(dependent_variable, "Time"))], list(as.Date(aligned.data$Time)), FUN=mean)
  aligned.data.return <- cbind(temp_dependent, temp_covariates$x)
  names(aligned.data.return)[names(aligned.data.return) == "Group.1"] <- "Time"
  names(aligned.data.return)[names(aligned.data.return) == "x"] <- as.character(dependent_variable)
  return(aligned.data.return)
}




####################### OPTION PARSER ##################################
list_options = list(
  make_option( c("-f","--file"), type="character", default=NULL, help= "dataset filename", metavar = "character"), 
  make_option( c("-i","--interval"), type="character", default=NULL, help= "interval time, e.g. 5 (minutes)", metavar = "character"),
  make_option( c("-s","--startexpr"), type="character", default=NULL, help= "start date:time of experiment", metavar = "character"),
  make_option( c("-e","--endexpr"), type="character", default=NULL, help= "end date:time of experiment", metavar = "character"),
  make_option( c("-n","--interventiondate"), type="character", default=NULL, help= "intervention date:time", metavar = "character"),
  make_option( c("-v","--dependentvar"), type="character", default=NULL, help= "dependent variabe (eg. glucose)", metavar = "character"),
  make_option( c("-d","--diabetes"), type="character", default=NULL, help= "diabetes flag options: lower | target | upper]", metavar = "character")
);


####################### MAIN CODE ##################################

opt <- parse_args(OptionParser(option_list=list_options))


if (file.exists(opt$file))
{
  combined.data <- as.data.frame((fread(opt$file)))
  if (ncol(combined.data) == 4)
  {
    colnames(combined.data) <- c("Date", "Time", "Variable", "Value")
  } else {
    print("Incorrect number of columns detected in file. Make sure the file has Date, Time, Variable, and Value columns.")
    quit()
  }
} else {
  print("File not found. Did you forget to include the path with the file?")
  quit()
}

interval <- as.integer(opt$interval)
if(!is.null(interval)){
  if (is.na(interval) | interval < 1)
  {
    print("Invalid interval found. Please enter a positive integer value for interval.")
    quit()
  }
}else{
  print("No interval argument entered")
  quit()
}

if(!is.null(opt$startexpr)){
  date1 <- as.POSIXct(paste(opt$startexpr))
}else{
  print("no start expirment value provided")
  quit()
}
if(!is.null(opt$endexpr)){
  date2 <- as.POSIXct(paste(opt$endexpr))
}else{
  print("no end expirment value provided")
  quit()
}
if(!is.null(opt$interventiondate)){
  intervention.date <- as.POSIXct(paste(opt$interventiondate))
}else{
  print("no intervention date value provided")
  quit()
}
int <- interval(date1, date2) 

if (!identical(which(duplicated(combined.data)), integer(0))) {
  combined.data <- combined.data[-which(duplicated(combined.data)), ] 
}

if(!is.null(opt$dependentvar)){
  dependent_variable = as.character(opt$dependentvar);
}else{
  print("no dependent varible value provided")
  quit()
}
vars <- unique(combined.data$Variable)
if (!(dependent_variable %in% vars)) {
  print("Invalid dependent variable entered. Please enter a variable included in the data set.")
  quit()
}

if(!is.null(opt$diabetes)){
  diabetes_flag = TRUE;
}else{
  diabetes_flag = FALSE;
}


#Align data to 5 minute intervals
aligned.data <- align_data_function(combined.data, date1, date2, interval, vars)


#Run casual impact with proper flags
if(diabetes_flag == TRUE){
  if(opt$diabetes == "upper"){
    aligned.data <- diabetes_above_target_aggregate(aligned.data, 180, dependent_variable)
  }else if(opt$diabetes == "target"){
    aligned.data <- diabetes_in_target_aggregate(aligned.data, 70, 180, dependent_variable)
  }else if(opt$diabetes == "lower"){
    aligned.data <- diabetes_below_target_aggregate(aligned.data, 70, dependent_variable)
  }else{
    print("invalid argument given to diabetes flag")
    quit();
  }
  anaylzing_causalimpact_function(aligned.data, intervention.date, diabetes_flag)
}else{
  anaylzing_causalimpact_function(aligned.data, intervention.date, diabetes_flag)
}







