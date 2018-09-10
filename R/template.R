#' Interactive function to create template file
#'
#' Use this function to create a template script that puts package
#' functions in order and, based on question answers, prepopulates
#' some arguments.  By default, this function is run in interactive
#' mode, meaning that it will not work in a script unless a list of
#' answers is given to \code{answer_list} argument.  Note that the
#' saved template file is not intended to be run as is, but only to
#' provide a starting structure for a cleaning script.
#'
#' Questions to answer if using the \code{answer_list} argument:
#'
#' \enumerate{
#' \item Do you want to set the DUA crosswalk file? \code{'Yes'} or \code{'No'}
#' \enumerate{
#' \item DUA crosswalk file (with path): '< file name with path >'
#' }
#' \item Do the data need to be deidentified? \code{'Yes'} or \code{'No'}
#' \enumerate{
#' \item Would like to select the ID column now? \code{'Yes'} or \code{'No'}
#' \item ID column name: '< column name string >'
#' }
#' }
#'
#' If answers to questions (1) and (2) are \code{No}, then strings for 1(a),
#' 2(a), and 2(b) can be left empty since they will be ignored.
#'
#' @param file_name Name with path of template script.
#' @param include_notes If \code{TRUE}, the template file will include
#'     notes and suggestions for completing the script; default value
#'     is \code{TRUE}.
#' @param answer_list List of answer strings to provide if you don't
#'     want to answer questions interactively. See details for
#'     questions and expected input type. Leave as default \code{NULL}
#'     for interactive mode.
#'
#' @examples
#' \dontrun{
#' ## run interactively
#' make_dua_template('data_clean.R')
#'
#' ## ...and don't include extra notes
#' make_dua_template('data_clean.R', include_notes = FALSE)
#' }
#'
#' ## make template to be filled in
#' file <- file.path(tempdir(), 'data_clean.R')
#' make_dua_template(file, answer_list = list('No','','No','',''))
#'
#' ## show
#' writeLines(readLines(file))
#'
#' @export
make_dua_template <- function(file_name, include_notes = TRUE,
                              answer_list = NULL) {

    ## -------------------------------------------
    ## question logic
    ## -------------------------------------------

    ## check for answer list
    if (!is.null(answer_list)) {
        if (!is.list(answer_list)) {
            stop('Answers must be provided in a list or left NULL',
                 call. = FALSE)
        }
        if (length(answer_list) != 5) {
            stop('Answer list must have 5 values.', call. = FALSE)
        }
        q1 <- ifelse(tolower(answer_list[[1]]) %in% c('yes','y','1'), 1, 0)
        duafile <- ifelse(q1 == 1, answer_list[[2]],
                          '< dua crosswalk file name >')
        q2 <- ifelse(tolower(answer_list[[3]]) %in% c('yes','y','1'), TRUE,
                     FALSE)
        q3 <- ifelse(isTRUE(q2) & tolower(answer_list[[4]]) %in% c('yes','y','1'),
                     answer_list[[5]], 0)
        if (q3 == 0) q3 <- NULL
    } else {

        yn <- c('Yes','No')

        q1 <- utils::menu(yn, title = 'Do you want to set the DUA crosswalk file?')

        if (q1 == 1) {
            duafile <- readline('DUA crosswalk file (with path): ')
        } else {
            duafile <- '< dua crosswalk file name >'
        }

        q2 <- utils::menu(yn, title = 'Do the data need to be deidentified?')

        if (q2 == 1) {
            q2 <- TRUE
            q3 <- utils::menu(yn, title = 'Would like to select the ID column now?')
            if (q3 == 1) {
            q3 <- readline('ID column name: ')
            } else {
                q3 <- NULL
            }
        } else {
            q2 <- FALSE
            q3 <- NULL
        }
    }

    ## -------------------------------------------
    ## template sections
    ## -------------------------------------------

    ## spacer function for quick add of blank rows
    spacer <- function(rows) { rep(' ', rows) }

    ## column widths
    full <- 80
    fullc <- 77
    shortc <- 27

    ## header boilerplate with some fill
    header <- c(paste(rep('#', full), collapse = ''),
                '##',
                '## [ Proj ] < general project name >',
                paste0('## [ File ] ', basename(file_name)),
                '## [ Auth ] < author name >',
                paste0('## [ Init ] ', format(Sys.time(), '%d %B %Y')),
                '##',
                paste(rep('#', full), collapse = ''))

    ## footer b/c it's nice
    footer <- c(paste0('## ', paste(rep('-', fullc), collapse = '')),
                '## end script',
                paste(rep('#', full), collapse = ''))



    ## ------------------
    ## (0) libraries
    ## ------------------

    libraries <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
                   '## libraries',
                   paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: Include additional libraries using either ',
                         '-library()- or -require()- functions here.'),
                       collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        libraries <- c(libraries, spacer(1), notes)
    }

    ## ------------------
    ## (1) Set DUA
    ## ------------------

    set_dua <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
                 '## set DUA crosswalk',
                 paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: Choose the DUA agreement crosswalk ',
                         'file if you didn\'t when setting up the template. ',
                         'If the file is a delimited file that isn\'t a ',
                         'CSV or TSV, be sure to indicate the delimiter ',
                         'string with the -delimiter- argument. Similarly ',
                         'if the crosswalk is in an Excel file on any ',
                         'sheet beyond the first, set the -sheet- ',
                         'argument to the correct sheet.'), collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        set_dua <- c(set_dua, spacer(1), notes)
    }

    set_dua <- c(set_dua,
                 spacer(1),
                 paste0('set_dua(dua = \'', duafile, '\')'))

    ## ------------------
    ## (2) Set DUA level
    ## ------------------

    set_level <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
                   '## set DUA level',
                   paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: Choose the DUA agreement crosswalk ',
                         'level. If you indicated that the data should ',
                         'be deidentified, those options, including the ',
                         'ID column if choosen, are included below. ',
                         'If you did not indicate the name of the ID ',
                         'column to be deidentified, add its name ',
                         'after the -id_column- argument.\n\nIf you did not ',
                         'indicate that the data should be deidentified, ',
                         'but they should be, see ?deid_dua().'),
                       collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        set_level <- c(set_level, spacer(1), notes)
    }

    if (q2) {

        idc <- ifelse(is.null(q3), '\'< ID column name > \'',
                      paste0('\'', q3, '\''))

        set_level <- c(set_level,
                       spacer(1),
                       c('set_dua_level(level = \'< level name >\',',
                         paste0('              deidentify_required = ', q2, ','),
                         paste0('              id_column = ', idc, ')')))
    } else {

        set_level <- c(set_level,
                       spacer(1),
                       'set_dua_level(level = \'< level name >\')')
    }

    ## ------------------
    ## (3) Working
    ## ------------------

    working <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
                 '## data cleaning',
                 paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: Use standard scripts to build and clean ',
                         'data set here.'), collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        working <- c(working, spacer(1), notes)
    }


    ## ------------------
    ## (4) check
    ## ------------------

    check <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
               '## check DUA restrictions',
               paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: If your data frame includes restricted ',
                         'data elements or should have been deidentified ',
                         'and has not been, -check_dua_restrictions()- will ',
                         'return an error and stop. Fix above and rerun or ',
                         'set -remove_protected- arguement to TRUE to ',
                         'automatically remove restricted columns.'),
                       collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        check <- c(check, spacer(1), notes)
    }

    check <- c(check,
               spacer(1),
               'check_dua_restrictions(df = \'< data frame >\')')

    ## ------------------
    ## (5) write
    ## ------------------

    write <- c(paste0('## ', paste(rep('-', shortc), collapse = '')),
               '## write cleaned file',
               paste0('## ', paste(rep('-', shortc), collapse = '')))

    if (include_notes) {
        notes <- paste(c('NOTES: Write cleaned file to disk. Select ',
                         'the file type (e.g., CSV, TSV, Stata, Rdata) ',
                         'and include additional arguments required ',
                         'by -haven- or base R writing functions.'),
                       collapse = '')
        notes <- paste0('## ', strwrap(notes, fullc))
        write <- c(write, spacer(1), notes)
    }

    write <- c(write,
               spacer(1),
               paste0('write_dua_df(df = \'< data frame >\', ',
                      'output_type = \'< output file type >\''))

    ## -------------------------------------------
    ## write template
    ## -------------------------------------------

    template_obj <- c(header,
                      spacer(1),
                      libraries,
                      spacer(1),
                      set_dua,
                      spacer(1),
                      set_level,
                      spacer(1),
                      working,
                      spacer(1),
                      check,
                      spacer(1),
                      write,
                      spacer(1),
                      footer)

    writeLines(template_obj, con = file_name)
}
