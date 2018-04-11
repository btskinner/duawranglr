#' Write securely cleaned data set
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
dua_write <- function(df,
                      file_name,
                      path = '.',
                      output_type = c('rds', 'rdata', 'csv', 'tsv',
                                      'delimited', 'stata', 'sas', 'spss'),
                      ...) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }

    ## check if already passed
    if (!dua_env[['check_pass']]) {
        messager__(paste0('Data set has not yet passed check. Run ',
                          '-check_protect()- to check status.'))
    }

    ## file extension list
    fe <- list('rds' = 'rds', 'rdata' = 'rdata', 'csv' = 'csv', 'tsv' = 'tsv',
               'delimited' = 'txt', 'stata' = 'dta', 'sas' = 'sas7bdat')

    ## check for file extension
    ext <- tolower(tools::file_ext(file_name))
    if (ext == '') { paste(file_name, fe[[output_type]], sep = '.') }

    ## -----------------------
    ## write
    ## -----------------------

    ## arguments
    args <- list(...)

    ## RDS
    if (output_type == 'rds') {
        do.call('saveRDS', c(list(df = df, file = file.path(path, file_name)),
                             args))
    }

    ## Rdata
    if (output_type == 'rdata') {
        do.call('save', c(list(df, file = file.path(path, file_name)),
                          args))
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
        do.call('write.table', c(list(df), arg))
    }

    ## Stata
    if (output_type == 'stata') {
        do.call('haven::write_dta',
                c(list(file = df, path = file.path(path, file_name)), args))
    }

    ## SAS
    if (output_type == 'sas') {
        do.call('haven::write_sas',
                c(list(file = df, path = file.path(path, file_name))))
    }

    ## SPSS
    if (output_type == 'spss') {
        do.call('haven::write_sav',
                c(list(file = df, path = file.path(path, file_name))))
    }

}
