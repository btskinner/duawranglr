#' Set data restriction level in system environment variable
#'
#' @param level String value of the data restriction level
#' @param deidentify_required Set to \code{TRUE} if ID column must be changed
#' to protect unique identifier
#' @param id_column Column with unique IDs that must be identified if
#' \code{deidentify_required == TRUE}
#'
#' @export
set_dua_level <- function(level,
                          deidentify_required = FALSE,
                          id_column = NULL) {

    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment')) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }

    ## check if level name matches dua_lvl
    if (!(level %in% names(dua_env[['restrictions']]))) {
        stop('Level name doesn\'t match name in DUA.', call. = FALSE)
    }

    ## message if deidentification required
    if (deidentify_required) {
        if (is.null(id_column)) {
            stop(paste0('Must set id_column argument to name of column ',
                        'with unique IDs that must be deidentified.'),
                       call. = FALSE)
        } else {
            dua_env[['deidentify_required']] <- TRUE
            dua_env[['deidentify_column']] <- id_column
            messager__(paste0('Unique IDs in [ ',
                              dua_env[['deidentify_column']],
                              ' ] must be deidentified; use -deidentify()-.'))
        }
    }

    ## set level
    dua_env[['level_set']] = TRUE
    dua_env[['dua_level']] = level

}

#' Show DUA options
#'
#' @param print_width Defaults to global option for screen width
#'
#' @export
see_dua_options <- function(print_width = getOption('width')) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }

    ## pretty print
    for (level in sort(names(dua_env[['restrictions']]))) {
        message(rep('-', print_width))
        message(paste0('LEVEL NAME: ', level))
        message(rep('-', print_width))
        message('RESTRICTED VARIABLE NAMES:\n')
        vars <- unlist(dua_env[['restrictions']][[level]])
        for (v in vars[!is.na(vars) & vars != '']) {
            message(paste0(' - ', v))
        }
        message(' ')
    }
    message(rep('-', print_width))
}

#' Show DUA current level setting
#'
#' @param show_restrictions If \code{TRUE}, show the names of the variables
#' that are restricted by the current level.
#' @param print_width Defaults to global option for screen width.
#'
#' @export
see_dua_level <- function(show_restrictions = FALSE,
                          print_width = getOption('width')) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }

    ## check if DUA level has been set
    if (is.null(dua_env[['level_set']])) {
        messager__('You have not yet set a DUA level.')
    } else {
        if (show_restrictions) {
            message(' ')
            message(paste0('You have set restrictions at [ ',
                           dua_env[['dua_level']],
                           ' ] which includes: '))
            message(' ')
            vars <- unlist(dua_env[['restrictions']][[dua_env[['dua_level']]]])
            for (v in vars) {
                message(paste0(' - ', v))
            }
            message(' ')
        } else {
            messager__(paste0('You have set restrictions at ',
                              dua_env[['dua_level']], '.'))
        }
    }
}
