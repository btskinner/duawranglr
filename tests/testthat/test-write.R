context('dua_write')

tmpdir <- tempdir()
df <- read.csv('./testdata/admin_data.csv')
dua_env <<- new.env(parent = .GlobalEnv)
dua_env[['dua_set']] <- TRUE
dua_env[['check_pass']] <- TRUE
fn <- 'test'

## ## delimited (pipe)
## test_that('Failed to write crosswalk file of type: delimited (pipe)', {

##     dua_write(df, file_name = fn, path = tmpdir, output_type = 'delimited',
##               sep = '|')
##     md5 <- tools::md5sum(file.path(tmpdir, paste0(fn, '.txt')))
##     expect_identical(md5[[1]], 'ab9507c5fac154666f6d8bf2e0c2fce4')
## })

## ## CSV
## test_that('Failed to write crosswalk file of type: delimited (CSV)', {

##     dua_write(df, file_name = fn, path = tmpdir, output_type = 'csv')
##     md5 <- tools::md5sum(file.path(tmpdir, paste0(fn, '.csv')))
##     expect_identical(md5[[1]], '2dc48f84b0d275c482a4b703e6733da6')
## })

## ## TSV
## test_that('Failed to write crosswalk file of type: delimited (TSV)', {

##     dua_write(df, file_name = fn, path = tmpdir, output_type = 'tsv')
##     md5 <- tools::md5sum(file.path(tmpdir, paste0(fn, '.tsv')))
##     expect_identical(md5[[1]], '629f8119e7a8aeab2796a1ea48b64296')
## })

## NOTE: checksums are an all-around bad idea

rm(tmpdir)

