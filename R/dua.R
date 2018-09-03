#' Function to set data usage agreement data crosswalk
#'
#' Initial function to read in and set the working DUA crosswalk.
#'
#' The crosswalk file can be in a variety of formats. It will be read
#' automatically without additional arguments if it's in the following
#' formats:
#'
#' \itemize{
#' \item \bold{R}: \code{*.rdata}, \code{*.rda}, \code{*.rds}
#' \item \bold{delimited}: if \code{*.csv} or \code{*.tsv}
#' \item \bold{Stata}: \code{*.dta}
#' \item \bold{SAS}: \code{*.sas7bdat}
#' \item \bold{SPSS}: \code{*.sav}
#' \item \bold{Excel}: \code{*.xls}, \code{*.xlsx} if on first sheet
#' }
#'
#' If a \bold{delimited} file other than comma- or tab-separated
#' values or an \code{Excel} file with information on a sheet other
#' than the first, use the appropriate arguments to set that correct
#' values.
#'
#' @param dua_cw Data frame object or file with columns representing
#'     security levels (header equalling name of level) and rows in
#'     each column representing restricted variables
#' @param delimiter Set the delimiter if reading in a delimited file
#'     that is neither a comma separated value (CSV) nor tab separated
#'     value (TSV).
#' @param sheet Set the sheet name or number if reading in a DUA
#'     crosswalk from Excel file with values not on the first sheet.
#' @param ignore_columns \bold{(Experimental)} Columns to ignore when
#'     reading in DUA crosswalk.
#' @param remap_list \bold{(Experimental)} If raw variable names should
#'     be remapped to new names, provide list with mappings from old
#'     names column to new names column.
#' @examples
#' ## path to DUA crosswalk file
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#'
#' ## set DUA restrictions using crosswalk file
#' set_dua_cw(dua_cw)
#'
#' \dontrun{
#' ## set using crosswalks stored in other file types
#' set_dua_cw('dua_cw.dta')
#' set_dua_cw('dua_cw.txt', delimiter = '|')
#' set_dua_cw('dua_cw.csv', remap_list = list('level_i_new' = 'level_i_old'))
#' }
#'
#' @export
set_dua_cw <- function(dua_cw, delimiter = NULL, sheet = NULL,
                       ignore_columns = NULL, remap_list = NULL) {
    ## read in crosswalk
    if (is.object(dua_cw)) {            # ... from working environment
        df <- dua_cw
    } else {                            # ... from file
        df <- sreader__(dua_cw, delimiter = delimiter, sheet = sheet)
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
    messager__('DUA crosswalk has been set!')
}

#' Set data restriction level
#'
#' Set data restrictions to one of the levels in the DUA crosswalk.
#'
#' @param level String value of the data restriction level
#' @param deidentify_required Set to \code{TRUE} if ID column must be
#'     changed to protect unique identifier.
#' @param id_column Column with unique IDs that must be identified if
#'     \code{deidentify_required == TRUE}.
#' @examples
#' ## --------------
#' ## Setup
#' ## --------------
#' ## set DUA crosswalk
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#' set_dua_cw(dua_cw)
#' ## --------------
#'
#' ## set restrictions at first level
#' set_dua_level('level_i')
#'
#' ## ...same, but set unique ID column to be deidentified
#' set_dua_level('level_i', deidentify_required = TRUE, id_column = 'sid')
#'
#' @export
set_dua_level <- function(level,
                          deidentify_required = FALSE,
                          id_column = NULL) {
    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua()-.', call. = FALSE)
    }
    ## check if level name matches dua_level available in restrictions
    if (!(level %in% names(dua_env[['restrictions']]))) {
        stop('Level name doesn\'t match name in DUA.', call. = FALSE)
    }
    ## message if deidentification required
    if (deidentify_required) {
        if (is.null(id_column)) {
            stop('Must set id_column argument to name of column ',
                 'with unique IDs that must be deidentified.',
                 call. = FALSE)
        } else {
            dua_env[['deidentify_required']] <- TRUE
            dua_env[['deidentify_column']] <- id_column
            messager__('Unique IDs in [ ',
                       dua_env[['deidentify_column']],
                       ' ] must be deidentified; use -deid_dua()-.')
        }
    }
    ## set level
    dua_env[['level_set']] = TRUE
    dua_env[['dua_level']] = level
}

#' Show DUA crosswalk options
#'
#' Once the DUA crosswalk has been loaded, show the available
#' restriction levels with associated data element names.
#'
#' @param level String name or vector of string names of levels to
#'     show.
#' @param sort_vars Sort variables alphabetically when printing
#'     restrictions; if \code{FALSE}, prints in the order saved in the
#'     crosswalk file
#' @param ... For debugging.
#' @examples
#' ## --------------
#' ## Setup
#' ## --------------
#' ## set DUA crosswalk
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#' set_dua_cw(dua_cw)
#' ## --------------
#'
#' ## see level i options
#' see_dua_options(level = 'level_i')
#'
#' ## compare two levels of options
#' see_dua_options(level = c('level_i','level_ii'))
#'
#' ## show all option levels
#' see_dua_options()
#'
#' @export
see_dua_options <- function(level = NULL, sort_vars = TRUE, ...) {
    ## set print width
    print_width = getOption('width')
    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }
    ## get levels and restrict if necessary
    levels <- sort(names(dua_env[['restrictions']]))
    if (!is.null(level)) {
        for (lev in level) {
            if (!(lev %in% levels)) {
                stop('Level [ ', lev, ' ] not in DUA crosswalk. Pick another ',
                     'or leave NULL for full list', call. = FALSE)
            }
        }
        levels <- level
    }
    ## pretty print
    for (lev in levels) {
        message(rep('-', print_width))
        message('LEVEL NAME: ', lev)
        message(rep('-', print_width))
        message('\nRESTRICTED VARIABLE NAMES:\n')
        vars <- unlist(dua_env[['restrictions']][[lev]])
        if (sort_vars) { vars <- sort(vars) }
        for (v in vars[!is.na(vars) & vars != '']) {
            message(' - ', v)
        }
        message(' ')
    }
    message(rep('-', print_width))
}

#' Show current DUA restriction level setting
#'
#' After setting the DUA restriction level, check the setting and
#' restricted data elements.
#'
#' @param show_restrictions Show the names of the variables that are
#'     restricted by the current level if \code{TRUE}.
#' @param sort_vars Sort variables alphabetically when printing
#'     restrictions; if \code{FALSE}, prints in the order saved in the
#'     crosswalk file
#' @param ... For debugging.
#' @examples
#' ## --------------
#' ## Setup
#' ## --------------
#' ## set DUA crosswalk
#' dua_cw <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
#' set_dua_cw(dua_cw)
#' ## --------------
#'
#' ## set restriction level
#' set_dua_level('level_i')
#'
#' ## show name of current restriction level
#' see_dua_level()
#'
#' ## ...include names of restricted elements
#' see_dua_level(show_restrictions = TRUE)
#'
#' ## ...show variable names in order saved in crosswalk file
#' see_dua_level(show_restrictions = TRUE, sort_vars = FALSE)
#'
#' @export
see_dua_level <- function(show_restrictions = FALSE, sort_vars = TRUE, ...) {
    print_width = getOption('width')
    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }
    ## check if DUA level has been set
    if (!dua_env[['level_set']]) {
        messager__('You have not yet set a DUA level.')
    } else {
        if (show_restrictions) {
            message(rep('-', print_width))
            message('You have set restrictions at [ ',
                    dua_env[['dua_level']],
                    ' ]')
            message(rep('-', print_width))
            message('\nRESTRICTED VARIABLE NAMES:\n')
            vars <- unlist(dua_env[['restrictions']][[dua_env[['dua_level']]]])
            if (sort_vars) { vars <- sort(vars) }
            for (v in vars) {
                message(' - ', v)
            }
            message(' ')
            message(rep('-', print_width))
        } else {
            messager__('You have set restrictions at [ ',
                       dua_env[['dua_level']], ' ].')
        }
    }
}
