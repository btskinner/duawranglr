#' Write DUA approved data set
#'
#' This function is a wrapper for a variety of write functions that
#' also checks whether the data set has been cleared for writing based
#' on the DUA level restrictions chosen by the user. If restricted
#' variables remain in the data set, the function will return an error
#' and will not write the data set.
#'
#' The following output types are supported (with the underlying write
#' function and default arguments accompanying):
#'
#' \itemize{
#'  \item \bold{rds}: \code{saveRDS()}
#'  \item \bold{rdata}: \code{save()}
#'  \item \bold{csv}: \code{write.table(...,row.names = FALSE, sep = ,)}
#'  \item \bold{tsv}: \code{write.table(...,row.names = FALSE, sep = '\\t')}
#'  \item \bold{delimited}: \code{write.table(...,row.names = FALSE)}
#'  \item \bold{stata}: \code{haven::write_dta()}
#'  \item \bold{sas}: \code{haven::write_sas()}
#'  \item \bold{spss}: \code{haven::write_sav()}
#' }
#'
#' All arguments for these internal write functions, including those
#' with default values, can be modified by adding them to the
#' top-level \code{write_dua_df()} function.
#'
#' @param df Data frame object to save.
#' @param file_name Name for saved file, with or without file type
#'     ending.
#' @param path Path for saved file with the default is the working
#'     directory.
#' @param output_type Output data file type; options include
#'     \code{rds} (DEFAULT), \code{rdata}, \code{csv}, \code{tsv},
#'     \code{delimited}, \code{stata}, \code{sas}, and \code{spss}.
#' @param ... Arguments to pass to write function based on the
#'     selected \code{output_type}; see details for more information.
#' @examples
#' \dontrun{
#'
#'  write_dua_df(df, 'clean_data', output_type = 'csv')
#'  write_dua_df(df, 'clean_data', output_type = 'delimited', sep = '|')
#'  write_dua_df(df, 'clean_data', output_type = 'stata', version = 11)
#'
#' }
#'
#' @export
write_dua_df <- function(df,
                         file_name,
                         path = '.',
                         output_type = c('rds', 'rdata', 'csv', 'tsv',
                                         'delimited', 'stata', 'sas',
                                         'spss'),
                         ...) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }

    ## check if already passed
    if (!dua_env[['check_pass']]) {
        messager__(paste0('Data set has not yet passed check. Run ',
                          '-check_dua_restrictions()- to check status.'))
    }

    ## file extension list
    fe <- list('rds' = 'rds', 'rdata' = 'rdata', 'csv' = 'csv', 'tsv' = 'tsv',
               'delimited' = 'txt', 'stata' = 'dta', 'sas' = 'sas7bdat',
               'spss' = 'sav')

    ## check for file extension
    ext <- tolower(tools::file_ext(file_name))
    if (ext == '') {
        file_name <- paste(file_name, fe[[output_type]], sep = '.')
    }

    ## join name and path
    f <- file.path(path, file_name)

    ## -----------------------
    ## write
    ## -----------------------

    ## arguments
    args <- list(...)

    ## RDS
    if (output_type == 'rds') {
        do.call('saveRDS', c(list('object' = df, 'file' = f), args))
    }

    ## Rdata
    if (output_type == 'rdata') {
        do.call('save', c(list('df', 'file' = f), args))
    }

    ## delimited files
    delims <- c('csv','tsv','delimited')
    if (output_type %in% delims) {
        if (!'row.names' %in% names(args)) { args[['row.names']] <- FALSE }
        if (output_type == 'csv') {
            if (!'sep' %in% names(args)) { args[['sep']] <- ',' }
        }
        if (output_type == 'csv') {
            if (!'sep' %in% names(args)) { args[['sep']] <- '\t' }
        }
        do.call('write.table', c(list(df, 'file' = f), args))
    }

    ## Stata
    if (output_type == 'stata') {
        fun <- get('write_dta', asNamespace('haven'))
        do.call(fun, c(list('data' = df, 'path' = f), args))
    }

    ## SAS
    if (output_type == 'sas') {
        fun <- get('write_sas', asNamespace('haven'))
        do.call(fun, c(list('data' = df, 'path' = f)))
    }

    ## SPSS
    if (output_type == 'spss') {
        fun <- get('write_sav', asNamespace('haven'))
        do.call(fun, c(list('data' = df, 'path' = f)))
    }

}
