# duawranglr 0.6.5

- Removed {tidyverse} package from `Suggests` in `DESCRIPTION` to improve load time

# duawranglr 0.6.4

- Increment to change contact information

# duawranglr 0.6.3

- First release on CRAN

# duawranglr 0.6.2

## Bug fix

- Appending crosswalk, `deid_dua()` no longer rewrites column names

# duawranglr 0.6.0

## Updates

- When reading in existing crosswalk, only append crosswalk file if
  new IDs rather than rewriting the entire file 
  
# duawranglr 0.5.1

## Bug fix

- fixed bug that dropped existing IDs from crosswalk that weren't also
  in current data frame being deidentified 
  
# duawranglr 0.5.0 

## Updates

- turn off `readr::read_delim()` progress bar from when reading files
- converted default path in functions to `tempdir()` rather than `'.'`
- update `dua_env` when reading in new file so that it has to be
rechecked with every new file 

## Bug fixes

- `deid_dua()` only makes IDs for unique old IDs, which was import to
  set since salt is added to the old ID before making new hashed IDs 
  
# duawranglr 0.3.0

## Updates

- added `read_dua_file()` that reads in admin files and sets
  `check_pass` to `FALSE` whenever a new file is read in as added
  level of security 

# duawranglr 0.2.0

## Updates

- `deid_dua()` now can use existing crosswalk file, which is good for
building panel data sets. (fixes #6)
- update to page link in gh-pages information

## Bug fixes

- fixed error where `write_dua_df()` would still write the file even
  if not passing data set check 

# duawranglr 0.1.0

- initial release
