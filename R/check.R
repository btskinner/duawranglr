#' Check data frame columns against currently set restrictions
#'
#' Once the DUA crosswalk and level have been set, a working data
#' frame can be checked against active data element restrictions. The
#' data frame must pass before it can be writen using
#' \code{write_dua_df()}.
#'
#' @param df Data frame to check against set DUA restriction level.
#' @examples
#' ## --------------
#' ## Setup
#' ## --------------
#' ## set DUA crosswalk
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#' set_dua_cw(dua_cw)
#' ## read in data
#' admin <- system.file('extdata', 'admin_data.csv', package = 'duawranglr')
#' df <- read_dua_file(admin)
#' ## --------------
#'
#' ## set restriction level
#' set_dua_level('level_iii')
#'
#' ## show restrictions
#' see_dua_level(show_restrictions = TRUE)
#'
#' ## see variables in administrative data file
#' names(df)
#'
#' ## remove restrictive variables
#' df <- dplyr::select(df, -c(sid,sname,tname))
#'
#' ## confirm
#' check_dua_restrictions(df)
#'
#' @export
check_dua_restrictions <- function(df) {
    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
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
                stop('ID column not set. Set using -set_dua_level()- ',
                     'or with id_col argument in -deid_dua()-.',
                     call. = FALSE)
            } else {
                stop('ID column ',
                     dua_env[['deidentify_column']],
                     ' has not been deidentified. Use -deid_dua()-.',
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
        ## write message and pass check if true
        if (length(col_vec > 0)) {
            text <- 'The following variables are not allowed at ' %+%
                'the current data usage level restriction [ ' %+%
                dua_env[['dua_level']] %+%
                ' ] and MUST BE REMOVED before saving:'

            messager__(text, var_vec = col_vec)
        } else {
            dua_env[['check_pass']] <- TRUE
            messager__('Data set has passed check and may be saved.')
        }
    }
}
