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
#' @param write_crosswalk Write crosswalk between old ID and new hash
#'     ID to console (unless \code{crosswalk_path} is given value).
#' @param crosswalk_name Name of crosswalk file; defaults to generic
#'     name with current date (YYYYMMDD) appended.
#' @param crosswalk_path Path to write crosswalk file (CSV), which is
#'     only used if \code{write_crosswalk == TRUE}; defaults to
#'     current directory.
#' @examples
#' \dontrun{
#'
#' deid_dua(df, id_col = 'sid', id_length = 20)
#' deid_dua(df, write_crosswalk = TRUE)
#'
#' }
#'
#' @export
deid_dua <- function(df, id_col = NULL, new_id_name = 'id', id_length = 64,
                     write_crosswalk = FALSE,
                     crosswalk_name = paste0('id_crosswalk_',
                                             format(Sys.Date(),
                                                    format='%Y%m%d')),
                     crosswalk_path = '.') {

    ## get ID column if NULL or error
    if (is.null(id_col)) {
        id_col <- dua_env[['deidentify_column']]
        if (is.null(id_col)) {
            stop(paste0('ID column not set. Set using -set_dua_level()- ',
                        'or with id_col argument'), call. = FALSE)
        }
    }

    ## error if new ID column name same as old
    if (identical(id_col, new_id_name)) {
        stop('New ID name must be different from old name', call. = FALSE)
    }

    ## set ID column
    dua_env[['deidentify_column']] <- id_col

    ## get new hashed values
    new_hash <- vdigest__(df[[id_col]], algo = 'sha2')

    ## shorten
    if (id_length < 12) {
        stop('New ID length must be 12 or longer', call. = FALSE)
    }

    ## reduce size
    new_hash <- substr(new_hash, 1, id_length)

    ## write crosswalk if desired
    if (write_crosswalk) {
        old <- names(new_hash)
        new <- new_hash
        tmp_df <- data.frame(old = old, new = new, stringsAsFactors = FALSE)
        colnames(tmp_df) <- c(id_col, new_id_name)
        if (is.null(crosswalk_path)) {
            print(tmp_df)
        } else {
            file <- paste0(crosswalk_name, '.csv')
            utils::write.csv(tmp_df, file.path(crosswalk_path, file),
                             quote = FALSE, row.names = FALSE)
        }
    }

    ## replace values with hashed values
    df[[id_col]] <<- new_hash

    ## change name of id column
    names(df)[names(df) == id_col] <<- new_id_name

    ## set check to TRUE
    dua_env[['deidentified']] <- TRUE

}
