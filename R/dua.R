#' Function to set data usage agreement data restrictions
#'
#' @param dua Data frame object or file with columns representing
#'     security levels (header equalling name of level) and rows in
#'     each column representing restricted variables
#' @param path File path to DUA file
#' @param delimiter If reading in DUA delimited file that is neither a
#'     comma separated value (CSV) nor tab separated value (TSV), a
#'     string value of the delimiter
#' @param sheet If reading in DUA from Excel file with values not on
#'     the first sheet, supply the sheet number or name
#' @param ignore_columns Columns to ignore
#' @param remap_list If raw variable names should be remapped to new names,
#'     provide list with mappings from old names column to new names column:
#'     \code{list('level_one_new' = 'level_one_old')}.
#'
#' @export
set_dua <- function(dua, path = '.', delimiter = NULL, sheet = NULL,
                    ignore_columns = NULL, remap_list = NULL) {

    if (is.object(dua)) {
        df <- dua
    } else {
        df <- sreader__(file.path(path, dua), delimiter = delimiter,
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
}
