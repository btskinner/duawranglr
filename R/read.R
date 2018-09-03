#' Read in raw data file
#'
#' This function is a wrapper for that will read a variety of file
#' types. The primary reason to use it rather than base R or tidyverse
#' functions is that every new file read will reset the
#' \code{check_pass} environment variable to \code{FALSE}. This is a
#' security feature in that it requires a new data check each time a
#' new file is read into memory.
#'
#' The following input types are supported (with the underlying read
#' function and default arguments accompanying):
#'
#' \itemize{
#'  \item \bold{rds}: \code{readRDS()}
#'  \item \bold{rdata}: \code{load()}
#'  \item \bold{csv}: \code{readr::read_delim(...,row.names = FALSE, sep = ,)}
#'  \item \bold{tsv}: \code{read::read_delim(...,row.names = FALSE, sep = '\\t')}
#'  \item \bold{delimited}: \code{readr::read_delim(...,row.names = FALSE)}
#'  \item \bold{excel}: \code{read_xl::read_excel(...,sheet = 1)}
#'  \item \bold{stata}: \code{haven::read_dta()}
#'  \item \bold{sas}: \code{haven::read_sas()}
#'  \item \bold{spss}: \code{haven::read_sav()}
#' }
#'
#' All arguments for these internal write functions, including those
#' with default values, can be modified by adding them to the
#' top-level \code{read_dua_file()} function.
#'
#' @param file File name to be read into memory
#' @param ... Arguments to pass to read function based on the
#'     input type; see details for more information.
#' @examples
#' ## --------------
#' ## Setup
#' ## --------------
#' ## set DUA crosswalk
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#' set_dua_cw(dua_cw)
#' ## --------------
#'
#' ## read in data
#' file <- system.file('extdata', 'admin_data.csv', package = 'duawranglr')
#' df <- read_dua_file(file)
#'
#' ## show
#' df
#'
#' \dontrun{
#' ## read in other file types
#' read_dua_file('admin_data.rds')
#' read_dua_file('admin_data.txt', sep = '|')
#' read_dua_file('admin_data.dta')
#' read_dua_file('admin_data.xlsx', sheet = 2)
#' }
#'
#' @export
read_dua_file <- function(file, ...) {
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }
    df <- sreader__(file, ...)
    dua_env[['deidentified']] <- FALSE  # reset
    dua_env[['check_pass']] <- FALSE    # reset
    return(df)
}
