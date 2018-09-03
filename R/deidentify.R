#' Convert identifying variable to unique hash
#'
#' Convert a column of unique but restricted IDs into a set of new IDs
#' using secure (SHA-2) hashing algorithm. Users have the option of
#' saving a crosswalk between the old and new IDs in case observations
#' need to reidentified at a later date.
#'
#' @param df Data frame
#' @param id_col Column name with IDs to be replaced. By default it is
#'     \code{NULL} and uses the value set by the \code{id_column}
#'     argument in \code{set_dua_level()} function.
#' @param new_id_name New hashed ID column name, which must be
#'     different from old name.
#' @param id_length Length of new hashed ID; cannot be fewer than 12
#'     characters (default is 64 characters).
#' @param existing_crosswalk File name of existing crosswalk. If
#'     existing crosswalk is used, then \code{new_id_name},
#'     \code{id_length}, \code{id_length}, and \code{crosswalk_name}
#'     will be determined by the already existing crosswalk. Arguments
#'     given for these values will be ignored.
#' @param write_crosswalk Write crosswalk between old ID and new hash
#'     ID to console (unless \code{crosswalk_name} is given value).
#' @param crosswalk_filename Name of crosswalk file with path;
#'     defaults to generic name with current date (YYYYMMDD) appended.
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
#' ## show identified data
#' df
#'
#' ## deidentify
#' df <- deid_dua(df, id_col = 'sid', new_id_name = 'id', id_length = 12)
#'
#' ## show deidentified data
#' df
#'
#' \dontrun{
#' ## save crosswalk between old and new ids for future
#' deid_dua(df, write_crosswalk = TRUE)
#'
#' ## use existing crosswalk (good for panel datasets that need link)
#' deid_dua(df, existing_crosswalk = './crosswalk/master_crosswalk.csv')
#' }
#'
#' @export
deid_dua <- function(df, id_col = NULL, new_id_name = 'id', id_length = 64,
                     existing_crosswalk = NULL, write_crosswalk = FALSE,
                     crosswalk_filename = NULL) {
    ## check if DUA has been set
    if (!exists('dua_env', mode = 'environment') || !dua_env[['dua_set']]) {
        stop('Must set DUA first with -set_dua_cw()-.', call. = FALSE)
    }
    ## defaults
    append_crosswalk <- FALSE
    ## get ID column if NULL or error
    if (is.null(id_col)) {
        id_col <- dua_env[['deidentify_column']]
        if (is.null(id_col)) {
            stop('ID column not set. Set using -set_dua_level()- ',
                 'or with id_col argument', call. = FALSE)
        }
    } else {
        dua_env[['deidentify_column']] <- id_col
    }
    ## read in existing crosswalk
    if (!is.null(existing_crosswalk)) {
        if (!file.exists(existing_crosswalk)) {
            stop('Crosswalk file given to -existing_crosswalk- argument ',
                 'doesn\'t exist. Check file name and/or path.',
                 call. = FALSE)
        }
        cw <- sreader__(existing_crosswalk)
        write_crosswalk <- FALSE
        append_crosswalk <- TRUE
        crosswalk_filename <- existing_crosswalk
        ## get new name from crosswalk (which is the one that's !id_col)
        new_id_name <- grep('\\b' %+% id_col %+% '\\b', names(cw),
                            value = TRUE, invert = TRUE)
        cw_id_name <- grep('\\b' %+% id_col %+% '\\b', names(cw), value = TRUE)
        ## get id length to match
        char_length <- nchar(cw[[new_id_name]])
        id_length <- ifelse(length(char_length) > 0, max(char_length), id_length)
    }
    ## check that id_col matches crosswalk
    if (exists('cw_id_name') && cw_id_name != id_col) {
        stop('Named ID column does not match the one in the ',
             'existing crosswalk. Check the crosswalk file ',
             'to make sure that the correct file has been ',
             'read in.', call. = FALSE)
    }
    ## error if new ID column name same as old
    if (identical(id_col, new_id_name)) {
        stop('New ID name must be different from old name', call. = FALSE)
    }
    ## uinque IDs to be transformed
    old_ids <- unique(df[[id_col]])
    ## subset IDs to those not already in crosswalk
    if (exists('cw')) {
        old_ids <- old_ids[!(old_ids %in% cw[[id_col]])]
        new_ids <- NULL
    }
    ## get new id values for ones that need it
    if (length(old_ids) > 0) {
        new_ids <- make_new_ids(old_ids)
    }
    ## shorten
    if (id_length < 12) {
        stop('New ID length must be 12 or longer', call. = FALSE)
    }
    ## reduce size
    new_ids <- substr(new_ids, 1, id_length)
    ## append new to old if they exist
    if (exists('cw')) {
        if (length(old_ids) > 0) {
            cw_append <- data.frame('old' = old_ids, 'new' = new_ids,
                                    stringsAsFactors = FALSE)
        }
        old_ids <- c(cw[[id_col]], old_ids)
        new_ids <- c(cw[[new_id_name]], new_ids)
    }
    ## combine into data frame
    id_df <- data.frame('old' = old_ids, 'new' = new_ids, stringsAsFactors = FALSE)
    colnames(id_df) <- c(id_col, new_id_name)
    ## replace old values with new or recovered hashed values
    df[[id_col]] <- id_df[[new_id_name]][match(df[[id_col]], id_df[[id_col]])]
    ## change name of id column
    names(df)[names(df) == id_col] <- new_id_name
    ## set check to TRUE
    dua_env[['deidentified']] <- TRUE
    ## write crosswalk if desired
    if (write_crosswalk) {
        if (is.null(crosswalk_filename)) {
            file <- 'id_crosswalk_' %+% format(Sys.Date(), format = '%Y%m%d')
        } else {
            file <- crosswalk_filename
        }
        utils::write.csv(id_df, file, quote = FALSE, row.names = FALSE)
    }
    ## append crosswalk if reading a new one and there are new ids to add
    if (append_crosswalk && exists('cw_append')) {
        utils::write.table(cw_append, crosswalk_filename, append = TRUE,
                           quote = FALSE, sep = ',', row.names = FALSE,
                           col.names = FALSE)
    }
    return(df)
}
