The `duawranglr` package is designed with the idea that rather than
setting a new data usage agreement (DUA) for each project in an ongoing
collaboration between researchers and data partners, two things will
happen instead:

1.  A master DUA will be signed that establishes a general framework for
    collaboration alongside multiple levels of data restriction; for
    each new project, these levels (*e.g.*, I, II, & III) can then be
    invoked and used to determine which variables may be shared, with
    whom, and under what conditions.  
2.  A associated crosswalk file will list the names of data elements
    that are restricted at each level and be used with this package to
    easily and clearly transform raw restricted data files into those
    that can be shared under the conditions of the master DUA.

This vignette goes through the process of using `duawranglr` functions
to create a sharable data set from a raw administrative file. Though no
two projects are alike, users should generally follow the steps below.

**Important upfront caveat:** using `duawranglr` does not guarantee data
security. It goes without saying, but users, of course, can simply *not
use* the package when attempting to secure restricted data. What this
package does is offer a framework and a set of useful functions that,
when followed, help users secure data in a clear and replicable manner.

Administrative data
===================

After loading some libraries, we’ll first read in the raw administrative
data file and take a look.

    library(tidyverse)
    library(duawranglr)

    ## read in raw administrative data
    df <- readr::read_csv('./admin_data.csv')
    df

    # A tibble: 9 x 10
      sid         sname    dob      gender raceeth   tid tname   zip mathscr readscr
      <chr>       <chr>    <chr>     <int>   <int> <int> <chr> <int>   <int>   <int>
    1 000-00-0001 Schaefer 19900114      0       2     1 Smith 22906     515     496
    2 000-00-0002 Hodges   19900225      0       1     1 Smith 22906     488     489
    3 000-00-0003 Kirby    19900305      0       4     1 Smith 22906     522     498
    4 000-00-0004 Estrada  19900419      0       3     1 Smith 22906     516     524
    5 000-00-0005 Nielsen  19900530      1       2     1 Smith 22906     483     509
    6 000-00-0006 Dean     19900621      1       1     2 Brown 22906     503     523
    7 000-00-0007 Hickman  19900712      1       1     2 Brown 22906     539     509
    8 000-00-0008 Bryant   19900826      0       2     2 Brown 22906     499     490
    9 000-00-0009 Lynch    19900902      1       3     2 Brown 22906     499     493

The `admin_data.csv` file contains observations for 9 students and has
10 variables associated with each observation. Of these, 1 uniquely
identifies each student, 6 are associated with the student’s personal
characteristics, 2 with each student’s teacher, and 2 with the student’s
test scores in reading and math.

Though there is no codebook, it appears that the identifier for each
student, `sid`, may be the student’s social security number. As
researchers interested in test scores, we have no need for this highly
protected data element other than for its ability to uniquely identify a
student or allow linking to other records. Since we do not need to link
to other records at the moment, any unique number or string will work
for our purposes. Similarly, we don’t really need the student’s last
name.

Besides math (`mathscr`) and reading (`readscr`) scores, we may be
interested in some of the other covariates. It’s likely that many of
these data elements, however, also carry restrictions of varying
severity. For example, the school may be able to share the student’s
race/ethnicity and gender (provided the student is not otherwise
identified) with most approved researchers, but can only share teachers’
names (`tid`) under more tightly restricted scenarios.

This is where our DUA crosswalk file comes in handy.

Data usage agreement
====================

The crosswalk file, `dua_cw.csv`, for the current DUA looks like this:

<table>
<thead>
<tr class="header">
<th style="text-align: center;">level_i</th>
<th style="text-align: center;">level_ii</th>
<th style="text-align: center;">level_iii</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">sid</td>
<td style="text-align: center;">sid</td>
<td style="text-align: center;">sid</td>
</tr>
<tr class="even">
<td style="text-align: center;">sname</td>
<td style="text-align: center;">sname</td>
<td style="text-align: center;">sname</td>
</tr>
<tr class="odd">
<td style="text-align: center;">dob</td>
<td style="text-align: center;">dob</td>
<td style="text-align: center;"></td>
</tr>
<tr class="even">
<td style="text-align: center;">gender</td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
</tr>
<tr class="odd">
<td style="text-align: center;">raceeth</td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
</tr>
<tr class="even">
<td style="text-align: center;">tid</td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
</tr>
<tr class="odd">
<td style="text-align: center;">tname</td>
<td style="text-align: center;">tname</td>
<td style="text-align: center;">tname</td>
</tr>
<tr class="even">
<td style="text-align: center;">zip</td>
<td style="text-align: center;">zip</td>
<td style="text-align: center;"></td>
</tr>
</tbody>
</table>

Each column represents a level, `level_i`, `level_ii`, or `level_iii`,
along with the corresponding data element names that are restricted at
that level. The names are arbitrary as far as the package goes, but in
conjunction with the master DUA, they have meaning:

-   **Level I**: The first level produces data sets that can be shared
    more widely, but at the cost of losing access to most data elements
    in the final data set. Only math and reading scores can be shared at
    this level.
-   **Level II:** The second level has slightly fewer data element
    restrictions, making it better for more research projects. Data
    produced at this level likely come with more sharing and storage
    restrictions than those produced at the first level.
-   **Level III:** The third level has the fewest restrictions: only
    names and the student’s id cannot be contained in the final data
    set. Data produced at this level will have the strongest
    restrictions on who can use it an how it is stored.

The benefit of this level-plus-crosswalk system is two-fold:

1.  Data element restrictions are clearly defined for each level, which
    in turn has it’s own clearly defined scope for data storage and
    sharing. When starting a new project under the scope of the master
    DUA, researchers and data partners need only to assign it a proper
    level based on the needs of the analyses.
2.  Because the crosswalk is a simple tabular file, data element names
    can easily be added or deleted by data partners who do not typically
    use data analysis software. This helps keep the process transparent
    for all team members.

Set DUA
-------

After reading in the administrative data, the next step is to set the
DUA crosswalk file. The crosswalk file can be in many different formats
and, in most cases, will be read in automatically no matter the type.
(If using a delimited file that isn’t a comma- or tab-separated value
format, give the `delimiter` argument the delimiter string; if using an
Excel file with more than one sheet, give the `sheet` argument the sheet
name or number.) If successful, you will get message telling you so.

    ## set the DUA crosswalk
    set_dua_cw('dua_cw.csv')

    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    DUA crosswalk has been set!
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------

Check DUA options
-----------------

In case you’ve forgotten the data elements that are restricted at a
particular level, you can check them using the `see_dua_options()`
function with the `level` argument set to the appropriate level. If you
want to compare restrictions across more than one level, you can give
the `level` argument a vector.

    ## compare level II and III restrictions
    see_dua_options(level = c('level_ii', 'level_iii'))
    ------------------------------------------------------------------------------------------
    LEVEL NAME: level_ii
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - dob
     - tname
     - zip
     
    ------------------------------------------------------------------------------------------
    LEVEL NAME: level_iii
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - tname
     
    ------------------------------------------------------------------------------------------

Alternately, you can see restrictions at all levels if you leave the
`level` argument at its default `NULL` value.

    ## check all level restrictions
    see_dua_options()
    ------------------------------------------------------------------------------------------
    LEVEL NAME: level_i
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - dob
     - gender
     - raceeth
     - tid
     - tname
     - zip
     
    ------------------------------------------------------------------------------------------
    LEVEL NAME: level_ii
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - dob
     - tname
     - zip
     
    ------------------------------------------------------------------------------------------
    LEVEL NAME: level_iii
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - tname
     
    ------------------------------------------------------------------------------------------

Set DUA level
-------------

After consultation with our data partner, we’ve decided that data for
this project need to be set at Level II. Because no level allows us to
use the current unique ID, `sid`, we also need to deidentify the data.
We could just delete the `sid` column, but for reasons discussed below,
it will be better if we use it to make new, non-identifiable but unique
IDs. Therefore, we use additional arguments in `set_dua_level()` to note
that deidentification is required and set the targeted ID column.

    ## set DUA level
    set_dua_level('level_ii', deidentify_required = TRUE, id_column = 'sid')
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    Unique IDs in [ sid ] must be deidentified; use -deid_dua()-.
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------

Check DUA level
---------------

As we’re preparing the data, we can check our restriction level and the
data element names it restricts using `see_dua_level()`.

    ## see set DUA level 
    see_dua_level(show_restrictions = TRUE)
    ------------------------------------------------------------------------------------------
    You have set restrictions at [ level_ii ]
    ------------------------------------------------------------------------------------------

    RESTRICTED VARIABLE NAMES:
     - sid
     - sname
     - dob
     - tname
     - zip
     
    ------------------------------------------------------------------------------------------

Deidentify data
===============

Single file or no existing crosswalk
------------------------------------

So far, we have set the DUA crosswalk as well as the restriction level
we will abide by. But our underlying data has not changed at all:

    ## show administrative data has not changed
    df
    # A tibble: 9 x 10
      sid         sname    dob      gender raceeth   tid tname   zip mathscr readscr
      <chr>       <chr>    <chr>     <int>   <int> <int> <chr> <int>   <int>   <int>
    1 000-00-0001 Schaefer 19900114      0       2     1 Smith 22906     515     496
    2 000-00-0002 Hodges   19900225      0       1     1 Smith 22906     488     489
    3 000-00-0003 Kirby    19900305      0       4     1 Smith 22906     522     498
    4 000-00-0004 Estrada  19900419      0       3     1 Smith 22906     516     524
    5 000-00-0005 Nielsen  19900530      1       2     1 Smith 22906     483     509
    6 000-00-0006 Dean     19900621      1       1     2 Brown 22906     503     523
    7 000-00-0007 Hickman  19900712      1       1     2 Brown 22906     539     509
    8 000-00-0008 Bryant   19900826      0       2     2 Brown 22906     499     490
    9 000-00-0009 Lynch    19900902      1       3     2 Brown 22906     499     493

We indicated that the data need to be deidentified, so a good first step
in cleaning the raw data is to convert unique student id, `sid`, into a
similarly unique, but unidentifiable value.

Why not just generate some random string for each value? Though we don’t
care to merge these data with other files, we may need to do so in the
future. If we randomly generate new IDs, discarding the old ones in the
process, we will be stuck.

The `deid_dua()` function does two things:

1.  It uses a secure `SHA-2` algorithm to convert sensitive IDs into
    unique hexadecimal strings that are almost impossible back convert;
2.  It has the option to save a crosswalk file that links the old secure
    IDs to the new IDs.

Clearly, it defeats the purpose of deidentifying IDs if a crosswalk
between old and new travels with the new data. But if the crosswalk file
is keep in a secure location, perhaps on the same server that hosts the
raw administrative data, then old IDs can be retrieved if necessary by
those with the proper clearance to do so.

    ## deidentify data
    deid_dua(df, write_crosswalk = TRUE, id_length = 20)

Here’s what the saved crosswalk looks like:

    # A tibble: 9 x 2
      sid         id                  
      <chr>       <chr>               
    1 000-00-0001 f008e8e6179270fd5e2b
    2 000-00-0002 d9a24845737fc64322d7
    3 000-00-0003 a981e3c8c2bcee9b64b6
    4 000-00-0004 76e8d38b59ee630ade91
    5 000-00-0005 800b2aa9daa677d76c22
    6 000-00-0006 897d9f571155e3812a09
    7 000-00-0007 57b16064133a0dc87a6e
    8 000-00-0008 d1b496d63877e708a4a9
    9 000-00-0009 3099e70845e4d23b3881

And here now is the data frame:

    ## show data frame
    df
    # A tibble: 9 x 10
      id                   sname    dob      gender raceeth   tid tname   zip mathscr readscr
      <chr>                <chr>    <chr>     <int>   <int> <int> <chr> <int>   <int>   <int>
    1 f008e8e6179270fd5e2b Schaefer 19900114      0       2     1 Smith 22906     515     496
    2 d9a24845737fc64322d7 Hodges   19900225      0       1     1 Smith 22906     488     489
    3 a981e3c8c2bcee9b64b6 Kirby    19900305      0       4     1 Smith 22906     522     498
    4 76e8d38b59ee630ade91 Estrada  19900419      0       3     1 Smith 22906     516     524
    5 800b2aa9daa677d76c22 Nielsen  19900530      1       2     1 Smith 22906     483     509
    6 897d9f571155e3812a09 Dean     19900621      1       1     2 Brown 22906     503     523
    7 57b16064133a0dc87a6e Hickman  19900712      1       1     2 Brown 22906     539     509
    8 d1b496d63877e708a4a9 Bryant   19900826      0       2     2 Brown 22906     499     490
    9 3099e70845e4d23b3881 Lynch    19900902      1       3     2 Brown 22906     499     493

Links across multiple files with existing crosswalk
---------------------------------------------------

If the deidentified data frame is built from multiple files (*e.g.*, a
panel data set of observations across years), then we’ll want to reuse
an existing crosswalk. Otherwise, the same original ID will end up with
multiple new IDs and we won’t be able to link observations across data
sets.

Let’s say we already have master crosswalk file that looks like this:

    # A tibble: 9 x 2
      sid         id                  
      <chr>       <chr>               
    1 000-00-0001 db3681caa7e4789c9a99
    2 000-00-0002 8e13af4fbb998c26348f
    3 000-00-0003 2c7f2f98f9ee0e3b69ba
    4 000-00-0004 ed7041ab2076a84fe611
    5 000-00-0005 d4180e00af840a7a8e29
    6 000-00-0006 9d42b365e2e49989b620
    7 000-00-0007 a997bd9ffc4ee8030081
    8 000-00-0008 43fc27899df21721b0c5
    9 000-00-0009 e3150a7010e9a08d52f0

Rather than create new IDs, we can use the `existing_crosswalk` argument
to read in and use the new IDs we’ve already made. Everything else works
the same as before.

    deid_dua(df, existing_crosswalk = 'master_crosswalk.csv')

The new ID values now match those from the crosswalk.

    df
    # A tibble: 9 x 10
      id                   sname    dob      gender raceeth   tid tname   zip mathscr readscr
      <chr>                <chr>    <chr>     <int>   <int> <int> <chr> <int>   <int>   <int>
    1 db3681caa7e4789c9a99 Schaefer 19900114      0       2     1 Smith 22906     515     496
    2 8e13af4fbb998c26348f Hodges   19900225      0       1     1 Smith 22906     488     489
    3 2c7f2f98f9ee0e3b69ba Kirby    19900305      0       4     1 Smith 22906     522     498
    4 ed7041ab2076a84fe611 Estrada  19900419      0       3     1 Smith 22906     516     524
    5 d4180e00af840a7a8e29 Nielsen  19900530      1       2     1 Smith 22906     483     509
    6 9d42b365e2e49989b620 Dean     19900621      1       1     2 Brown 22906     503     523
    7 a997bd9ffc4ee8030081 Hickman  19900712      1       1     2 Brown 22906     539     509
    8 43fc27899df21721b0c5 Bryant   19900826      0       2     2 Brown 22906     499     490
    9 e3150a7010e9a08d52f0 Lynch    19900902      1       3     2 Brown 22906     499     493

Updates to existing crosswalk
-----------------------------

In our example, we have nine students in the current file. Let’s say
that though we have a crosswalk, it only has new IDs for the first five
observations:

    # A tibble: 5 x 2
      sid         id                  
      <chr>       <chr>               
    1 000-00-0001 db3681caa7e4789c9a99
    2 000-00-0002 8e13af4fbb998c26348f
    3 000-00-0003 2c7f2f98f9ee0e3b69ba
    4 000-00-0004 ed7041ab2076a84fe611
    5 000-00-0005 d4180e00af840a7a8e29

If the existing crosswalk doesn’t have values for all observations, then
`deid_dua()` will:

1.  Match old IDs with new IDs that **do** exist in the crosswalk
2.  Generate new IDs for the old IDs that **don’t** exist in the
    crosswalk
3.  Update and save the crosswalk

The command is the same for a partial crosswalk as for a complete
crosswalk.

    deid_dua(df, existing_crosswalk = 'crosswalk_partial.csv')

Notice that the new IDs for the first five observations match those that
were already in the existing crosswalk. The last four are new.

    df
    # A tibble: 9 x 10
      id                   sname    dob      gender raceeth   tid tname   zip mathscr readscr
      <chr>                <chr>    <chr>     <int>   <int> <int> <chr> <int>   <int>   <int>
    1 db3681caa7e4789c9a99 Schaefer 19900114      0       2     1 Smith 22906     515     496
    2 8e13af4fbb998c26348f Hodges   19900225      0       1     1 Smith 22906     488     489
    3 2c7f2f98f9ee0e3b69ba Kirby    19900305      0       4     1 Smith 22906     522     498
    4 ed7041ab2076a84fe611 Estrada  19900419      0       3     1 Smith 22906     516     524
    5 d4180e00af840a7a8e29 Nielsen  19900530      1       2     1 Smith 22906     483     509
    6 5144051905dad92bda7a Dean     19900621      1       1     2 Brown 22906     503     523
    7 b21bce7a83b349b9db19 Hickman  19900712      1       1     2 Brown 22906     539     509
    8 df5236bac822fb8b248f Bryant   19900826      0       2     2 Brown 22906     499     490
    9 806f6319155814f87081 Lynch    19900902      1       3     2 Brown 22906     499     493

Looking at the partial crosswalk, we see that it now has four new rows
with new IDs each for the observations it didn’t have before.

    # A tibble: 9 x 2
      sid         id                  
      <chr>       <chr>               
    1 000-00-0001 db3681caa7e4789c9a99
    2 000-00-0002 8e13af4fbb998c26348f
    3 000-00-0003 2c7f2f98f9ee0e3b69ba
    4 000-00-0004 ed7041ab2076a84fe611
    5 000-00-0005 d4180e00af840a7a8e29
    6 000-00-0006 5144051905dad92bda7a
    7 000-00-0007 b21bce7a83b349b9db19
    8 000-00-0008 df5236bac822fb8b248f
    9 000-00-0009 806f6319155814f87081

Should we encounter those students in future files, `deid_dua()` will
use the new IDs we just created.

Check data frame
================

If we try to write the data frame using the `write_dua_df()` function,
we get an error.

    ## write data to disk with one last check
    write_dua_df(df, 'cleaned_data.csv', output_type = 'csv')
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    Data set has not yet passed check. Run -check_dua_restrictions()- to check status.
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------

Right, we haven’t removed all the restricted data elements. Following
the directions, we can check to see what still needs to be removed using
the `check_dua_restrictions()` function.

    ## check
    check_dua_restrictions(df)
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    The following variables are not allowed at the current data usage level (level_ii) and
    STILL MUST be removed:
     
     - sname
     - dob
     - tname
     - zip

    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------

We’ve successfully removed `sid` already (when we deidentified the data
frame), but still have to remove the student’s last name, date of birth,
teacher’s name, and zip code to meet level II restrictions. Once we
remove those columns, we can check again.

    ## remove restricted columns
    df <- df %>% select(-c(sname, dob, tname, zip))

    ## check again
    check_dua_restrictions(df)
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    Data set has passed check and may be saved.
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------

Success! And to be sure, here’s what our data frame looks like now:

    df
    # A tibble: 9 x 6
      id                   gender raceeth   tid mathscr readscr
      <chr>                 <int>   <int> <int>   <int>   <int>
    1 db3681caa7e4789c9a99      0       2     1     515     496
    2 8e13af4fbb998c26348f      0       1     1     488     489
    3 2c7f2f98f9ee0e3b69ba      0       4     1     522     498
    4 ed7041ab2076a84fe611      0       3     1     516     524
    5 d4180e00af840a7a8e29      1       2     1     483     509
    6 5144051905dad92bda7a      1       1     2     503     523
    7 b21bce7a83b349b9db19      1       1     2     539     509
    8 df5236bac822fb8b248f      0       2     2     499     490
    9 806f6319155814f87081      1       3     2     499     493

Write cleaned data frame to disk
================================

Now that we’ve passed our check, we can write the level II secure data
frame to disk. Just like the `set_dua_cw()` function, which automates
reading in many types of files, `write_dua_df()` will write many types
of files. See `?write_dua_df` for options.

    ## write data to disk 
    write_dua_df(df, 'cleaned_data_lev_ii.csv', output_type = 'csv')

Interactive template
====================

Particularly for the first few times you use this package, you may need
help remembering the steps. To help the process, the interactive
`make_dua_template()` function will help you make a template script that
you can then modify to meet your data cleaning needs. When called, the
function will ask you a few yes or no questions and, based on your
answers, build a template script that pre-fills some function arguments.

An example template script is printed below.

    ## save template to disk
    make_dua_template('clean_data.R')

#### EXAMPLE

    ################################################################################
    ##
    ## [ Proj ] < general project name >
    ## [ File ] clean_data.R
    ## [ Auth ] < author name >
    ## [ Init ] 06 August 2018
    ##
    ################################################################################
     
    ## ---------------------------
    ## libraries
    ## ---------------------------
     
    ## NOTES: Include additional libraries using either -library()- or -require()-
    ## functions here.
     
    ## ---------------------------
    ## set DUA crosswalk
    ## ---------------------------
     
    ## NOTES: Choose the DUA agreement crosswalk file if you didn't when setting up
    ## the template. If the file is a delimited file that isn't a CSV or TSV, be
    ## sure to indicate the delimiter string with the -delimiter- argument.
    ## Similarly if the crosswalk is in an Excel file on any sheet beyond the
    ## first, set the -sheet- argument to the correct sheet.
     
    set_dua(dua = '< dua crosswalk file name >')
     
    ## ---------------------------
    ## set DUA level
    ## ---------------------------
     
    ## NOTES: Choose the DUA agreement crosswalk level. If you indicated that the
    ## data should be deidentified, those options, including the ID column if
    ## choosen, are included below. If you did not indicate the name of the ID
    ## column to be deidentified, add its name after the -id_column- argument.
    ## 
    ## If you did not indicate that the data should be deidentified, but they
    ## should be, see ?deid_dua().
     
    set_dua_level(level = '< level name >')
     
    ## ---------------------------
    ## data cleaning
    ## ---------------------------
     
    ## NOTES: Use standard scripts to build and clean data set here.
     
    ## ---------------------------
    ## check DUA restrictions
    ## ---------------------------
     
    ## NOTES: If your data frame includes restricted data elements or should have
    ## been deidentified and has not been, -check_dua_restrictions()- will return
    ## an error and stop. Fix above and rerun or set -remove_protected- arguement
    ## to TRUE to automatically remove restricted columns.
     
    check_dua_restrictions(df = '< data frame >')
     
    ## ---------------------------
    ## write cleaned file
    ## ---------------------------
     
    ## NOTES: Write cleaned file to disk. Select the file type (e.g., CSV, TSV,
    ## Stata, Rdata) and include additional arguments required by -haven- or base R
    ## writing functions.
     
    write_dua_df(df = '< data frame >', output_type = '< output file type >'
     
    ## -----------------------------------------------------------------------------
    ## end script
    ################################################################################
