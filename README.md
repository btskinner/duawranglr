# duawranglr

[![Build
Status](https://travis-ci.org/btskinner/duawranglr.svg?branch=master)](https://travis-ci.org/btskinner/duawranglr)
[![GitHub
release](https://img.shields.io/github/release/btskinner/duawranglr.svg)](https://github.com/btskinner/duawranglr)
<!-- [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/duawranglr)](http://cran.r-project.org/package=duawranglr) -->

This package offers a set of functions to help users create shareable
data sets from raw data files that contain protected elements. Relying
on master crosswalk files that list restricted variables, package
functions warn users about possible violations of data usage agreement
and prevent writing protected elements.  

### Install

<!-- Install the latest released version from CRAN with -->

<!-- ```r -->
<!-- install.packages('duawranglr') -->
<!-- ``` -->

Install the latest development version from Github with

```r
devtools::install_github('btskinner/duawranglr')
```

### Dependencies

This package relies on the following packages, available in CRAN:

* [digest](https://cran.r-project.org/package=digest)
* [tidyverse](https://cran.r-project.org/package=tidyverse)
  * [dplyr](https://cran.r-project.org/package=dplyr)
  * [haven](https://cran.r-project.org/package=haven)
  * [readr](https://cran.r-project.org/package=readr)
  * [readxl](https://cran.r-project.org/package=readxl)	
