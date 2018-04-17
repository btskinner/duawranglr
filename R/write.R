#' Write DUA approved data set
#'
#' @param df Data frame object to save.
#' @param file_name Name for saved file.
#' @param path Path for saved file; default is current directory.
#' @param output_type Output data file type. Options include \code{rds}
#' (DEFAULT), \code{rdata}, \code{csv}, \code{tsv}, \code{delimited},
#' \code{stata}, and \code{sas}.
#' @param ... Arguments to pass to write function. Will change depending
#' on selected \code{output_type}.
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
