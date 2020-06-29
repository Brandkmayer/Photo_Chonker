# Script for organizing sorted photos and preparing them for chunking 
# by Brandon Mayer
Sys.Date()
# last updated : 2020-06-29

# This script aims to consolidate photos by collection period limiting photo overlap resulting from date malfunctions.
# The final product is a folder tagged with "_sorted". Sorted folders will have a CSV including extracted 
# paths and metadata similar to if "extractimagepaths" script was used. 
library(lubridate)
library(tidyverse)

csv <- "ACH"
prime_photo_folders <- "D:/CameraProject/aguachiquita/homestead"
photo_folders <- list.files(prime_photo_folders, pattern = "2019",all.files = FALSE,
                            full.names = T, recursive = FALSE, include.dirs = TRUE)
log_dir <-"D:/CameraProject/sorting_log"
photofilepath <- paste(log_dir, "/Sorting Log - ",  csv, ".csv", collapse = "", sep = "")

RAW <- read.csv(photofilepath, header=TRUE, na.strings=c(""," ","NA"))
csvfilled <- zoo::na.locf(RAW, na.rm = FALSE)

# check for errors in parsing
which(is.na(ymd_hms(csvfilled[,4])))
which(is.na(ymd_hms(csvfilled[,5])))

# If errors appear, you can use the script commented out below to examine the rows with errors and make corrections as needed.
#blah <- which(is.na(ymd_hms(csvfilled[,5])))
#csvfilled[c(blah),]


#                     need to figure out parse checking for the total photo list 



i = "D:/CameraProject/aguachiquita/homestead/ACH_09072019_09212019" 

# for (i in photo_folders) {
  photo_csv <- list.files(i, pattern = "2019.csv",all.files = FALSE,
                          full.names = T, recursive = TRUE, include.dirs = TRUE)
  photolist <- read_csv(photo_csv)
  photolist$SubFolder <- dirname(photolist$ImageRelative)
  csvfilled<- csvfilled %>% filter(Primary.Folder == basename(i))
  photo_dir<-paste(i,"_sorted", sep = "")
  dir.create(photo_dir)
  photosubfolders <- list.files(i, pattern = ".JPG",all.files = FALSE,
                                full.names = T, recursive = TRUE, include.dirs = TRUE)
  to.dir   <- photo_dir
  df <- photosubfolders
  
  for (j in unique(csvfilled$SubFolder)) {
    chunkedlist <- photolist %>% filter(SubFolder == j) 
    chunkedcsv <- csvfilled %>% filter(SubFolder == j)
    
    fn <- ymd_hms(chunkedlist$ImageFilename)
    t1 <- ymd_hms(chunkedcsv[,4])
    t2 <- ymd_hms(chunkedcsv[,5])
    
    finalsortedphotolist <- map2(t1, t2, ~fn[between(fn, .x, .y)])
    
    finalsortedphotolist <- do.call("c", finalsortedphotolist)
    finalsortedphotolist <- finalsortedphotolist[!is.na(finalsortedphotolist)]
    
    finalsortedphotolist <- finalsortedphotolist %>% str_replace_all(c('\\:'= '-', ' ' = '-'))
    list_of_photofiles <- c(paste(finalsortedphotolist, ".JPG", sep=""))
    it  <- 0
    res <- c()
    for(l in list_of_photofiles){
      it  <- it + 1
      res <- append(res, df[grepl(pattern = l, x = df)])
    }
    for (f in res) file.copy(from = f, to = to.dir)
  }
# }

sorted_folders <- list.files(prime_photo_folders, pattern = "sorted",all.files = FALSE,
                            full.names = T, recursive = FALSE, include.dirs = TRUE)
for (i in sorted_folders) {
  ## R SCRIPT
  ## get the current directory, if this script was copied into the image storage folder, then
  ## the working directory is that folder.

  
  ## make a list of all the JPEGs in the file, if images are stored in some other format, update the code below
  imagefiles<-list.files(path=i,full.names=T,pattern=c(".JPG|.jpg"),include.dirs = T,recursive=T)
  
  ## create a data.frame from the list of all image files and extract metadata associated with each image	
  imagefilesinfo<-as.data.frame(do.call("rbind",lapply(imagefiles,file.info)))
  imagefilesinfo<-imagefilesinfo[,c("size","mtime")]
  imagefilesinfo$ImagePath<-imagefiles
  imagefilesinfo$ImageRelative<-do.call("rbind",lapply(strsplit(imagefiles,split=paste(i,"/",sep="")),rev))[,1]
  imagefilesinfo$ImageFilename<-do.call("rbind",lapply(strsplit(imagefiles,split="/"),rev))[,1]
  imagefilesinfo$ImageTime<-gsub("[[:space:]]", "",substr(as.character(imagefilesinfo$mtime),regexpr(":",imagefilesinfo$mtime)-2,regexpr(":",imagefilesinfo$mtime)+5))
  imagefilesinfo$ImageDate<-gsub("[[:space:]]", "",substr(as.character(imagefilesinfo$mtime),1,10))
  imagefilesinfo$RecordNumber<-seq(1:length(imagefilesinfo$ImagePath))
  imagefilesinfo$ImageSize<-as.numeric(imagefilesinfo$size)
  imagefilesinfo<-imagefilesinfo[,c(8,5,3,4,9,6,7)]
  
  #remove images of size 0 - some cameras have image write-errors that cannot be processed
  imagefilesinfo<-imagefilesinfo[imagefilesinfo$ImageSize!=0,]
  
  # ## OPTIONAL - DEFINE A SUBSET OF IMAGES TO PROCESS BASED ON A REGULAR TIME SCHEDULE
  # #Make list of images to include by listing all years wanted (must be four-digit years: 2015,2016,...)
  # useyears = c("2012","2013","2014","2015","2016","2017")
  # #Make list of images to include by listing all months wanted (quotes are necessary as it must be two-digit months: c("01","02",...))
  # usemonths = c("01","02","03","04","05","06","07","08","09","10","11","12")
  # #Make list of images to include by listing all days of the month wanted (must be two-digit days: 01,02,...)
  # usedays = c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31")
  # #Make list of images to include by listing all hous of the day wanted (must be two-digit hours: 01,02,...)
  # usehours = c("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
  # #Now subset the list of all images to just those matching the time criteria above
  # imagefilesinfo<-imagefilesinfo[which(substr(imagefilesinfo$ImageDate,1,4) %in% useyears &
  #                                        substr(imagefilesinfo$ImageDate,6,7) %in% usemonths &
  #                                        substr(imagefilesinfo$ImageDate,9,10) %in% usedays &
  #                                        substr(imagefilesinfo$ImageTime,1,2) %in% usehours),]
  
  ## OPTIONAL - SET A TIME FOR A CUSTOM ALERT MESSAGE TO DISPLAY ON THE EXCEL FORM
  # set an alert based on time or date, These images will all be included but the 'ImageAlert' will be set to True. If no Alert is Desired, set Alert=F.
  # when an alert is set, a custom message can be defined to 'pop-up' on the excel form for every image with Altert set to TRUE.
  # this feature is nice for reminding the user to record certain data types that are not necessarily recorded for every image (e.g. temperature)
  # by default all years, months, days of the month, hours of the day, and minutes of the hour are listed for alerts which would slow down data entry
  # as it would post the alert message on every image
  Alert=FALSE
  
  # If an alert is desired:
  #Make list of images to alert by listing all years when alerts are wanted (must be four-digit years: 2015,2016,...)
  alertyears = as.character(c(2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020))
  #Make list of images to alert by listing all months when alerts are wanted (quotes are necessary as it must be two-digit months: c("01","02",...))
  alertmonths = c("01","02","03","04","05","06","07","08","09","10","11","12")
  #Make list of images to alert by listing all days of the month when alerts are wanted (must be two-digit days: 01,02,...)
  alertdays = c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31")
  #Make list of images to alert by listing all hours of the day when alerts are wanted (must be two-digit hours: 01,02,...)
  alerthours = c("06","15")
  #Make list of images to alert by listing all minutes of the hour wanted (must be two-digit minutes: 01,02,...)
  alertminutes = c("00")
  # this code will set the ImageAlert to "TRUE" for all images matching the above specified time conditions
  if (Alert==T){
    imagefilesinfo$ImageAlert <- c(substr(imagefilesinfo$ImageDate,1,4) %in% alertyears & 
                                     substr(imagefilesinfo$ImageDate,6,7) %in% alertmonths & 
                                     substr(imagefilesinfo$ImageDate,9,10) %in% alertdays & 
                                     substr(imagefilesinfo$ImageTime,1,2) %in% alerthours & 
                                     substr(imagefilesinfo$ImageTime,4,5) %in% alertminutes)
  } else {
    imagefilesinfo$ImageAlert<- FALSE
  }
  
  ## write a .csv file named after the working directory containing the image data.  All the data from this .csv file should be copied into the 
  ## Excel form.  The .csv file will show up in the same directory as this script once this script is run.
  
  excelfilename<-paste(i,'/',rev(strsplit(i,split="/")[[1]])[1],".csv",sep="")
  write.csv(imagefilesinfo,excelfilename,row.names=F)
}
