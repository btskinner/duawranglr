## utils.R

## quick paste
`%+%` <- function(a,b) paste0(a,b)

## global variables
utils::globalVariables(c('.getSerializeVersion', 'dua_env'))

## smart reader
sreader__ <- function(file, delimiter = NULL, sheet = NULL, ...) {
    ## check to make sure file exists
    if (!file.exists(file)) {
        stop('File not found. Please confirm file name and path.',
             call. = FALSE)
    }
    ## get file ending, ignoring case
    ext <- tolower(tools::file_ext(file))
    ## read based on filetype
    if (ext == 'xls' || ext == 'xlsx') { # Excel
        sheet <- ifelse(!is.null(sheet), sheet, 1)
        df <- readxl::read_excel(file, sheet = sheet, col_types = 'text')
    } else if (ext == 'rda' || ext == 'rdata' || ext == 'rds') { # R
        if (ext == 'rds') { df <- readRDS(file, ...) }
        else { df <- get(load(file, ...)) }
    } else if (ext == 'dta') {          # Stata
        df <- haven::read_stata(file, ...)
    } else if (ext == 'sas7bdat') {     # SAS
        df <- haven::read_sas(file, ...)
    } else if (ext == 'sav') {          # SPSS
        df <- haven::read_spss(file, ...)
    } else {                            # delimited (csv, tst, user-supplied)
        if (ext == 'csv' && is.null(delimiter)) { delim <- ',' }
        else if (ext == 'tsv' && is.null(delimiter)) { delim <- '\t' }
        else if (!is.null(delimiter)) { delim <- delimiter }
        else {                          # error
            stop('File type not recognized; please supply delimiter string.',
                 call. = FALSE)
        }
        df <- readr::read_delim(file, delim = delim,
                                col_types = readr::cols(.default = 'c'),
                                progress = FALSE,
                                ...)
    }
    return(df)
}

## check for duplicates in column
check_dups__ <- function(file, column) {
    if (anyDuplicated(file[[column]], incomparables = c(NA, ''))) {
        dups <- file[[column]][duplicated(file[[column]])]
        stop(paste(c('The following values are duplicated in the',
                     column,
                     'column:\n\n',
                     paste(dups, '\n'),
                     '\n',
                     'Please specify a 1:1 mapping.'),
                   collapse = ' '),
             call. = FALSE)
    }
}

## hash mapper list
assign_hash_list__ <- function(hash, df, remap_list = NULL) {
    if (!is.null(remap_list)) {
        cols <- names(remap_list)
    } else {
        cols <- colnames(df)
    }
    for (col in cols) {
        ## check for duplicates
        check_dups__(df, col)
        ## create list of restricted variable names
        varlist <- list(df[[col]])
        ## if remapping names append new names too
        if (!is.null(remap_list)) {
            tmp <- list(df[[remap_list[[col]]]])
            varlist <- list(c(unlist(varlist), unlist(tmp)))
        }
        ## remove NAs
        varlist <- lapply(varlist, function(x) {
            x[x == '' | x == ' '] <- NA
            return(x[!is.na(x)])
        })
        ## add list to hash under level name
        hash[[col]] <- varlist
    }
}


## hash mapper wrapper
hasher__ <- function(df, name, ignore_col = NULL, remap_list = NULL,
                     assign_env = .GlobalEnv) {
    ## get column names
    cols <- colnames(df)
    ## ...less remapped column and any ignored columns
    if (!is.null(remap_list)) {
        cols <- cols[!(cols %in% unlist(remap_list, use.names = FALSE))]
    }
    if (!is.null(ignore_col)) {
        cols <- cols[!(cols %in% c(ignore_col))]
    }
    ## create hash environment
    hash <- new.env(parent = emptyenv())
    ## apply each remaining column value to clean value
    assign_hash_list__(hash, df = df, remap_list = remap_list)
    ## assign hash environment to name
    assign(name, hash, envir = assign_env)
}

## vectorized digest::digest
vdigest__ <- Vectorize(digest::digest)

## messager
messager__ <- function(..., var_vec = NULL) {
    width <- getOption('width')
    text <- paste(unlist(list(...)), collapse = ' ')
    text <- paste(strwrap(text, width = width), collapse = '\n')
    pre <- '-- duawranglr note '
    pre <- pre %+% paste(rep('-', width - nchar(pre)), collapse = '') %+% '\n'
    if (!is.null(var_vec)) {
        message(pre, text, '\n')
        for (v in var_vec) {
            message(' - ', v)
        }
    } else {
        message(pre, text)
    }
}

## get file basename without extension
get_basename <- function(file) {
    tools::file_path_sans_ext(basename(file))
}

## create sha2 hash strings from old_string + salt
make_new_ids <- function(old_ids) {
    salt <- vdigest__(stats::runif(length(old_ids), -100, 100), algo = 'md5')
    old_ids <- old_ids %+% salt
    vdigest__(old_ids, algo = 'sha2')
}
