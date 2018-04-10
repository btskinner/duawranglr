#' Write securely cleaned data set
#'
#' @param df Data frame
#' @param ... Options to pass to base \code{write.table()} function.
#'
#' @export
dua_write <- function(df, ...) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }

    ## check if already passed
    if (!dua_env[['check_pass']]) {
        messager__(paste0('Data set has not yet passed check. Run ',
                          '-check_protect()- to check status.'))
    }

    ## defaults
    arg <- list(...)
    if (!'sep' %in% names(arg)) { arg[['sep']] <- ',' }
    if (!'row.names' %in% names(arg)) { arg[['row.names']] <- FALSE }

    ## write
    do.call('write.table', c(list(df), arg))

}
