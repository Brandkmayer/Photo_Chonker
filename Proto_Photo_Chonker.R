# Photo chunking script for already sorted photos
# By Brandon Mayer
Sys.Date()
# last updated : 2020-06-29

# This script follows the use of proto_sort_consolidate or Proto_CollectionConsolidate scripts. 
# In either script, photos are cross-referenced with a sorted list that is downloaded from the "Sorting log" google sheet. 
# The resulting folder with the consolidated photos is labeled with the three letter site code as **XXX_Analysis_year**. 

# If you aren't using the script named above, use folder name containing a site's photos, and include in the 
# folder a csv with extracted paths from the "extractimagepaths" script.  

library(tidyverse)

# Create final folder to dump chunked folders
#               **Keep the same once location is set** **Change this depending on site**
final_dir <- paste("D:/CameraProject/Chunked_folders/","ACH_Analysis_2019", sep = "") 
dir.create(final_dir)

# After creating a folder to store the chunks you just need to reenter 
# each "sorted" folder in succession at "line 21". You could make a for-loop with the same chunk size
# set for each chunk, but this would leave a small chunk with the remaining photos. I figured 
# keeping size the same throughout a collection period would be better for planning. 

# Source file to chunk
file_source <- "ACH_09072019_09212019_sorted"
source_dir <- "D:/CameraProject/aguachiquita/homestead"
# Using "Proto_CollectionConsolidate" performs for-loops of "extractimagepaths" for folders tagged with "Sorted"  
source_csv <- paste(source_dir,"/", file_source,"/",file_source ,".csv", sep = "")

# Breakdown of Chunking parameters
To_sort <- read_csv(source_csv)
n <- nrow(To_sort)
n/2 # Change the number decide on an appropriate chunk size. I personally shoot for a chunk between 700-800  
chunk <- 730 # once chunk is set you can run everything below to completion. 

# Actual Chunking of csv into a list of chunks
r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
d <- split(To_sort,r)
dir_source_comb <- paste(final_dir,file_source, sep = "/")

for (i in 1:length(d)){
  x <- paste(dir_source_comb, i, sep = "_")
  dir.create(x)
  write.csv(d[i], paste0(x,"/",file_source,"_", i, ".csv"), row.names=F)
  photo_list_path <-  data.frame(d[[i]][3])
  for(j in photo_list_path){
    file.copy(j,x)
  }
}

# old script. Don't know why it didnt work

# # Sorting CSVs and photos into their chunked folders
# 
# for (i in 1:length(d)){
#   x <- paste(dir_source_comb, i, sep = "_")
#   dir.create(x)
#   write.csv(d[i], paste0(x,"/",file_source,"_", i, ".csv"), row.names=F)
#   replace <- paste(".*",file_source,"/", sep = "")
#   photo_list_path <-  data.frame(lapply(d[[1]][3], function(x) {
#     gsub(replace, source_dir, x)}))
#   for(j in photo_list_path){
#     file.copy(j,x)
#   }
# }
# 
# 



