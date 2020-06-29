# Photo_Chonker
Contains two scripts that work together to organize sorted photos into smaller more manageable chunks. This allows planning and processing to occur unencumbered. 

If you dont plan on using a Sorting Log to sort photos skip to the Second part of the Workflow.

## Workflow
### Proto_CollectionConsolidate
This script works under the assumption that you have access to the [Sorting log](https://docs.google.com/spreadsheets/d/1wera4XFmGMdztjZvAY5lXWEHg4LszraBr96a-KU1pp4/edit#gid=792627629). 

Through sorting log you can locate a site of interest and download the sorted file. This should be down when all of the sorting has been completed on a site for the season. Doing so in chunks might reduce the time need to copy files over but in the long run this time is pretty insignificant compared to moving over entire folders.  

![](https://imgur.com/9kn54QM.jpg)

Save the csv file to "sorting_log" folder in the cloned folder. (Current Rscript should have a pathway set up to the cloned folder this should make the scripts use a bit easier)

------

When "Proto_CollectionConsolidate.R" is loaded you'll need to change the pathways for:

* photo folder on either a server or an external harddrive
* three letter code for the sorting log file (Sorting Log - _@@@_.csv) 

	Enter in as 			"csv <- @@@""


![](https://imgur.com/emAep8z.jpg)
 
 After running steps in script to fill empty columns the csv should show up as shown above. 
 
 This follows along with the proto_sort_consolidate.R objective, but in this case instead of sorting all of the photos by site we're sorting by collection period and site.
 This is done to limit the effect of date errors on when using the sorting log. 
 
 ------
 
 ## Proto_Photo_Chonker
 ![A pretty Tiger](https://bigmemes.funnyjunk.com/pictures/C+h+o+n+k_3f0892_6814883.jpg=250x250)

Using a prebuilt CSV, listing filenames and pathways, the  script allows you to break up large photo collections into manageable chunks for processing and provides chunked versions of the original CSV as well. 
* The size of your photo chunk depends on ow many photos you believe is comfrotably accomplishable by you or a technician.   

"Proto_CollectionConsolidate.R" includes script for creating a CSV of filenames and pathways for any sorted folder of photos. 

Details on workflow are included in script. 
GOOD LUCK
