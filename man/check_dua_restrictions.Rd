% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check.R
\name{check_dua_restrictions}
\alias{check_dua_restrictions}
\title{Check data frame columns against currently set restrictions}
\usage{
check_dua_restrictions(df)
}
\arguments{
\item{df}{Data frame to check against set DUA restriction level.}
}
\description{
Once the DUA crosswalk and level have been set, a working data
frame can be checked against active data element restrictions. The
data frame must pass before it can be writen using
\code{write_dua_df()}.
}
\examples{
## --------------
## Setup
## --------------
## set DUA crosswalk
dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
set_dua_cw(dua_cw)
## read in data
admin <- system.file('extdata', 'admin_data.csv', package = 'duawranglr')
df <- read_dua_file(admin)
## --------------

## set restriction level
set_dua_level('level_iii')

## show restrictions
see_dua_level(show_restrictions = TRUE)

## see variables in administrative data file
names(df)

## remove restrictive variables
df <- dplyr::select(df, -c(sid,sname,tname))

## confirm
check_dua_restrictions(df)

}
