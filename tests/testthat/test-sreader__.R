context('sreader__')

colnames <- c('level_i','level_ii','level_iii')
values <- c('sid','sname','dob','gender','raceeth','tid','tname','zip')

## delimited (pipe)
test_that('Failed to read crosswalk file of type: delimited (pipe)', {

    dua_one <- sreader__('./testdata/dua_one.txt', delimiter = '|')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## delimited (CSV)
test_that('Failed to read crosswalk file of type: delimited (CSV)', {

    dua_one <- sreader__('./testdata/dua_one.csv')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## delimited (TSV)
test_that('Failed to read crosswalk file of type: delimited (TSV)', {

    dua_one <- sreader__('./testdata/dua_one.tsv')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## Excel (XLS)
test_that('Failed to read crosswalk file of type: Excel (XLS)', {

    dua_one <- sreader__('./testdata/dua_one.xls')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## Excel (XLSX)
test_that('Failed to read crosswalk file of type: Excel (XLSX)', {

    dua_one <- sreader__('./testdata/dua_one.xlsx')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## Stata
test_that('Failed to read crosswalk file of type: Stata (DTA)', {

    dua_one <- sreader__('./testdata/dua_one.dta')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## SPSS
test_that('Failed to read crosswalk file of type: SPSS (sav)', {

    dua_one <- sreader__('./testdata/dua_one.sav')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## R (rdata)
test_that('Failed to read crosswalk file of type: R (rdata)', {

    dua_one <- sreader__('./testdata/dua_one.rdata')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## R (rda)
test_that('Failed to read crosswalk file of type: R (rda)', {

    dua_one <- sreader__('./testdata/dua_one.rda')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})

## R (rds)
test_that('Failed to read crosswalk file of type: R (rds)', {

    dua_one <- sreader__('./testdata/dua_one.rds')
    expect_is(dua_one, 'data.frame')
    expect_identical(names(dua_one), colnames)
    expect_identical(unlist(dua_one[colnames[1]], use.names = FALSE), values)

})
