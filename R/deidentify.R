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
#'     ID to console (unless \code{crosswalk_path} is given value).
#' @param crosswalk_name Name of crosswalk file; defaults to generic
#'     name with current date (YYYYMMDD) appended.
#' @examples
#' \dontrun{
#'
#' deid_dua(df, id_col = 'sid', id_length = 20)
#' deid_dua(df, write_crosswalk = TRUE)
#' deid_dua(df, existing_crosswalk = './crosswalk/master_crosswalk.csv')
#'
#' }
#'
#' @export
deid_dua <- function(df, id_col = NULL, new_id_name = 'id', id_length = 64,
                     existing_crosswalk = NULL, write_crosswalk = FALSE,
                     crosswalk_name = NULL) {

    ## get ID column if NULL or error
    if (is.null(id_col)) {
        id_col <- dua_env[['deidentify_column']]
        if (is.null(id_col)) {
            stop(paste0('ID column not set. Set using -set_dua_level()- ',
                        'or with id_col argument'), call. = FALSE)
        }
    } else {
        ## set ID column
        dua_env[['deidentify_column']] <- id_col
    }

    ## read in existing crosswalk
    if (!is.null(existing_crosswalk)) {
        if (!file.exists(existing_crosswalk)) {
            stop(paste0('Crosswalk file given to -existing_crosswalk- argument ',
                        'doesn\'t exist. Check file name and/or path.'),
                 call. = FALSE)
        }
        cw__ <- sreader__(existing_crosswalk)
        write_crosswalk <- TRUE
        crosswalk_name <- get_basename(existing_crosswalk)
        ## get new name from crosswalk (which is the one that's !id_col)
        new_id_name <- grep(paste0('\\b', id_col, '\\b'), names(cw__),
                            value = TRUE, invert = TRUE)
        cw_id_name <- grep(paste0('\\b', id_col, '\\b'), names(cw__), value = TRUE)
        ## get id length to match
        char_length <- nchar(cw__[[new_id_name]])
        id_length <- ifelse(length(char_length) > 0, max(char_length), id_length)
    }

    ## check that id_col matches crosswalk
    if (exists('cw_id_name') && cw_id_name != id_col) {
        stop(paste0('Named ID column does not match the one in the ',
                    'existing crosswalk. Check the crosswalk file ',
                    'to make sure that the correct file has been ',
                    'read in.'), call. = FALSE)
    }

    ## error if new ID column name same as old
    if (identical(id_col, new_id_name)) {
        stop('New ID name must be different from old name', call. = FALSE)
    }

    ## ids to be transformed
    old_ids <- df[[id_col]]

    ## get existing ids and new ids from crosswalk
    if (exists('cw__')) {
        exist_cw_df <- cw__[cw__[[id_col]] %in% old_ids,]
        old_ids <- old_ids[!(old_ids %in% exist_cw_df[[id_col]])]
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
    if (exists('exist_cw_df')) {
        old_ids <- c(exist_cw_df[[id_col]], old_ids)
        new_ids <- c(exist_cw_df[[new_id_name]], new_ids)
    }

    ## write crosswalk if desired
    if (write_crosswalk) {
        old <- old_ids
        new <- new_ids
        tmp_df <- data.frame(old = old, new = new, stringsAsFactors = FALSE)
        colnames(tmp_df) <- c(id_col, new_id_name)
        if (is.null(crosswalk_name)) {
            file <-  paste0('id_crosswalk_', format(Sys.Date(), format='%Y%m%d'))
        } else {
            file <- paste0(crosswalk_name, '.csv')
        }
        utils::write.csv(tmp_df, file, quote = FALSE, row.names = FALSE)
    }

    ## replace values with hashed values
    df[[id_col]] <<- new_ids

    ## change name of id column
    names(df)[names(df) == id_col] <<- new_id_name

    ## set check to TRUE
    dua_env[['deidentified']] <- TRUE

}
