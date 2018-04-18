context('deid_dua')

df <- read.csv('./testdata/admin_data.csv')
dua_env <<- new.env(parent = .GlobalEnv)
dua_env[['dua_set']] <- TRUE
dua_env[['deidentify_required']] <- TRUE
dua_env[['deidentify_column']] <- 'sid'
dua_env[['deidentified']] <- FALSE

old_names <- c('sid','sname','dob','gender','raceeth','tid','tname','zip',
               'mathscr','readscr')
new_names <- c('id','sname','dob','gender','raceeth','tid','tname','zip',
               'mathscr','readscr')

## test_that('No conversion from old to new name', {

##     deid_dua(df)
##     varnames <- names(df)
##     expect_identical(varnames, new_names)

## })
