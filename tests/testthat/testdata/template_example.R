################################################################################
##
## [ Proj ] < general project name >
## [ File ] clean_data.R
## [ Auth ] < author name >
## [ Init ] 12 April 2018
##
################################################################################
 
## ---------------------------
## libraries
## ---------------------------
 
## NOTES: Include additional libraries using either -library()- or -require()-
## functions here.
 
## ---------------------------
## set DUA
## ---------------------------
 
## NOTES: Choose the DUA agreement crosswalk file if you didn't when setting up
## the template. If the file is a delimited file that isn't a CSV or TSV, be
## sure to indicate the delimiter string with the -delimiter- argument.
## Similarly if the crosswalk is in an Excel file on any sheet beyond the
## first, set the -sheet- argument to the correct sheet.
 
set_dua(dua = '< dua crosswalk file name >')
 
## ---------------------------
## set DUA level
## ---------------------------
 
## NOTES: Choose the DUA agreement crosswalk level. If you indicated that the
## data should be deidentified, those options, including the ID column if
## choosen, are included below. If you did not indicate the name of the ID
## column to be deidentified, add it's name after the -id_column- argument.
## 
## If you did not indicate that the data should be deidentified, but they
## should be, see ?deidentify().
 
set_level(level = '< level name >')
 
## ---------------------------
## data cleaning
## ---------------------------
 
## NOTES: Use standard scripts to build and clean data set here.
 
## ---------------------------
## check/protect
## ---------------------------
 
## NOTES: If your data frame includes restricted data elements or should have
## been deidentified and has not been, -check_protect()- will return an error
## and stop. Fix above and rerun or set -remove_protected- arguement to TRUE to
## automatically remove restricted columns.
 
check_protect(df = '< data frame >')
 
## ---------------------------
## write cleaned file
## ---------------------------
 
## NOTES: Write cleaned file to disk. Select the file type (e.g., CSV, TSV,
## Stata, Rdata) and include additional arguments required by -haven- or base R
## writing functions.
 
dua_write(df = '< data frame >', output_type = '< output file type >'
 
## -----------------------------------------------------------------------------
## end script
################################################################################
