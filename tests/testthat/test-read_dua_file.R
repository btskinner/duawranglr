context('read_dua_file')

colnames <- c('sid','sname','dob','gender','raceeth','tid','tname','zip',
              'mathscr','readscr')

## delimited (pipe)
test_that('Failed to read admin file of type: delimited (pipe)', {

    admin_data <- sreader__('./testdata/admin_data.txt', delimiter = '|')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## delimited (CSV)
test_that('Failed to read admin file of type: delimited (CSV)', {

    admin_data <- sreader__('./testdata/admin_data.csv')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## delimited (TSV)
test_that('Failed to read admin file of type: delimited (TSV)', {

    admin_data <- sreader__('./testdata/admin_data.tsv')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## Excel (XLS)
test_that('Failed to read admin file of type: Excel (XLS)', {

    admin_data <- sreader__('./testdata/admin_data.xls')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## Excel (XLSX)
test_that('Failed to read admin file of type: Excel (XLSX)', {

    admin_data <- sreader__('./testdata/admin_data.xlsx')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## Stata
test_that('Failed to read admin file of type: Stata (DTA)', {

    admin_data <- sreader__('./testdata/admin_data.dta')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## SAS
test_that('Failed to read admin file of type: SAS (sas7bdat)', {

    admin_data <- sreader__('./testdata/admin_data.sas7bdat')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## SPSS
test_that('Failed to read admin file of type: SPSS (sav)', {

    admin_data <- sreader__('./testdata/admin_data.sav')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## R (rdata)
test_that('Failed to read admin file of type: R (rdata)', {

    admin_data <- sreader__('./testdata/admin_data.rdata')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## R (rda)
test_that('Failed to read admin file of type: R (rda)', {

    admin_data <- sreader__('./testdata/admin_data.rda')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})

## R (rds)
test_that('Failed to read admin file of type: R (rds)', {

    admin_data <- sreader__('./testdata/admin_data.rds')
    expect_is(admin_data, 'data.frame')
    expect_identical(names(admin_data), colnames)

})
