# duawranglr

[![R build
status](https://github.com/btskinner/duawranglr/workflows/R-CMD-check/badge.svg)](https://github.com/btskinner/duawranglr/actions)
[![GitHub
release](https://img.shields.io/github/release/btskinner/duawranglr.svg)](https://github.com/btskinner/duawranglr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/duawranglr)](https://CRAN.R-project.org/package=duawranglr)

The guiding principle behind duawranglr is to make it easier for
organizations to share data that contain protected elements and/or
personally identifiable information (PII) with researchers. There are two
key problems this package attempts to solve:

1.  Data owners and reseachers may wish to collaborate on multiple
    projects, each with a different level of data security required;
    executing a unique data usage agreement (DUA) for each project can
    be time consuming and inefficient.  
2.  Administrators tasked with approving data requests do not always
    have the time or technical proficiency to closely review the code
    that reads, subsets, filters, and deidentifies data files according
    to a DUA.

This package offers a set of functions to help users create shareable
data sets from raw data files that contain protected elements. Relying
on master crosswalk files that list restricted variables, package
functions warn users about possible violations of data usage agreement
and prevent writing protected elements.

## Installation

Install the latest released version from CRAN with

    install.packages("duawranglr")

Install the latest development version from Github with

    devtools::install_github("btskinner/duawranglr")

## Usage

See vignettes or [documentation site](https://btskinner.io/duawranglr)
for package motivation and an example use case.
