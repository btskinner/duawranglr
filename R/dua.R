#' Function to set data usage agreement data crosswalk
#'
#' @param dua_cw Data frame object or file with columns representing
#'     security levels (header equalling name of level) and rows in
#'     each column representing restricted variables
#' @param path File path to DUA crosswalk file.
#' @param delimiter If reading in a delimited file that is neither a
#'     comma separated value (CSV) nor tab separated value (TSV), a
#'     string value of the delimiter is necessary.
#' @param sheet If reading in DUA from Excel file with values not on
#'     the first sheet, supply the sheet number or name
#' @param ignore_columns Columns to ignore when reading in DUA crosswalk.
#' @param remap_list If raw variable names should be remapped to new names,
#'     provide list with mappings from old names column to new names column:
#'     \code{list('level_one_new' = 'level_one_old')}.
#'
#' @export
set_dua_cw <- function(dua_cw, path = '.', delimiter = NULL, sheet = NULL,
                       ignore_columns = NULL, remap_list = NULL) {

    if (is.object(dua_cw)) {
        df <- dua_cw
    } else {
        df <- sreader__(file.path(path, dua_cw), delimiter = delimiter,
                        sheet = sheet)
    }

    ## create environment with process indicators
    dua_env <<- new.env(parent = .GlobalEnv)
    dua_env[['dua_set']] <- TRUE
    dua_env[['remapped_names']] <- ifelse(is.null(remap_list), FALSE, TRUE)
    dua_env[['level_set']] <- FALSE
    dua_env[['dua_level']] <- NULL
    dua_env[['deidentify_required']] <- FALSE
    dua_env[['deidentify_column']] <- NULL
    dua_env[['deidentified']] <- FALSE
    dua_env[['check_pass']] <- FALSE

    ## hash to dua environment
    hasher__(df, 'restrictions', ignore_col = ignore_columns,
             remap_list = remap_list, assign_env = dua_env)

    ## message to note set
    messager__('DUA crosswalk has been set!')
}

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
                              ' ] must be deidentified; use -deid_dua()-.'))
        }
    }

    ## set level
    dua_env[['level_set']] = TRUE
    dua_env[['dua_level']] = level

}

#' Show DUA options
#'
#' @param level String name or vector of string names of levels to show.
#' @param print_width Defaults to global option for screen width.
#'
#' @export
see_dua_options <- function(level = NULL,
                            print_width = getOption('width')) {

    ## check if DUA has been set
    if (!dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }

    ## get levels and restrict if necessary
    levels <- sort(names(dua_env[['restrictions']]))

    if (!is.null(level)) {
        for (lev in level) {
            if (!(lev %in% levels)) {
                stop(paste0('Level [ ',
                            lev,
                            ' ] not in DUA crosswalk. Pick another ',
                            'or leave NULL for full list', call. = FALSE))
            }
        }
        levels <- level
    }

    ## pretty print
    for (lev in levels) {
        message(rep('-', print_width))
        message(paste0('LEVEL NAME: ', lev))
        message(rep('-', print_width))
        message('\nRESTRICTED VARIABLE NAMES:\n')
        vars <- unlist(dua_env[['restrictions']][[lev]])
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
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }

    ## check if DUA level has been set
    if (is.null(dua_env[['level_set']])) {
        messager__('You have not yet set a DUA level.')
    } else {
        if (show_restrictions) {
            message(rep('-', print_width))
            message(paste0('You have set restrictions at [ ',
                           dua_env[['dua_level']],
                           ' ]'))
            message(rep('-', print_width))
            message('\nRESTRICTED VARIABLE NAMES:\n')
            vars <- unlist(dua_env[['restrictions']][[dua_env[['dua_level']]]])
            for (v in vars) {
                message(paste0(' - ', v))
            }
            message(' ')
            message(rep('-', print_width))
        } else {
            messager__(paste0('You have set restrictions at ',
                              dua_env[['dua_level']], '.'))
        }
    }
}
