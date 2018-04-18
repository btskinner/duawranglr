#' Check data frame columns against currently set restrictions
#'
#' Once the DUA crosswalk and level have been set, a working data
#' frame can be checked against active data element restrictions. The
#' data frame must pass before it can be writen using
#' \code{write_dua_df()}.
#'
#' @param df Data frame to check against set DUA restriction level.
#' @param remove_protected Will remove protected variables as
#'     determined by DUA restriction level if set to
#'     \code{TRUE}; default behavior is to warn only.
#' @examples
#' \dontrun{
#'
#' check_dua_restrictions(df)
#' check_dua_restrictions(df, remove_protected = TRUE)
#'
#' }
#'
#' @export
check_dua_restrictions <- function(df, remove_protected = FALSE) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }

    ## check if already passed
    if (dua_env[['check_pass']]) {
        messager__('Data set has passed check and may be saved.')
    } else {

        ## check if DUA level has been set
        if (!dua_env[['level_set']]) {
            stop('Must set DUA level with -set_dua_level()-.', call. = FALSE)
        }

        ## check if needs to be deidentified and, if so, if it has
        if (!dua_env[['deidentified']] && dua_env[['deidentify_required']]) {
            if (is.null(dua_env[['deidentify_column']])) {
                stop(paste0('ID column not set. Set using -set_dua_level()- ',
                            'or with id_col argument in -deid_dua()-.'),
                     call. = FALSE)
            } else {
                stop(paste0('ID column ',
                            dua_env[['deidentify_column']],
                            ' has not been deidentified. Use -deid_dua()-.'),
                     call. = FALSE)
            }
        }

        ## check data frame
        col_vec <- vector()
        restrict <- unlist(dua_env[['restrictions']][[dua_env[['dua_level']]]])
        for (col in names(df)) {
            if (col %in% restrict) {
                col_vec <- c(col_vec, col)
            }
        }

        if (length(col_vec > 0)) {
            if (remove_protected) {
                df <<- df[,-which(names(df) %in% col_vec)]
                text <- paste('The following variables are not allowed at ',
                              'the current data usage level  (',
                              dua_env[['dua_level']],
                              ') and HAVE BEEN removed: \n\n', sep = '')
            } else {
                text <- paste('The following variables are not allowed at ',
                              'the current data usage level  (',
                              dua_env[['dua_level']],
                              ') and STILL MUST be removed: \n\n', sep = '')
            }
            messager__(text, col_vec)
        } else {
            dua_env[['check_pass']] <- TRUE
            messager__('Data set has passed check and may be saved.')
        }
    }
}
