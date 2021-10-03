---
title: "Part II: Efficiently Move Data Between MATLAB and R"
subtitle: "Part II: Bulk Import of Data Variables into R from MATLAB"
date: 2021-10-03T00:45:29.507Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
In Part I we demonstrate an extremely rapid method to export high-dimensional data in MATLAB and export it to a MAT file. In this post we will demonstrate how to import and disentangle the data in R.

## An overview of the process

* load required packages into R
* import MAT file
* preparing the data frame with all variables
* individual extraction of datasets

## Load required packages into R

```r
install.packages(c("tidyverse","purrr", "R.matlab"))
library(tidyverse)
library(purrr)
library(R.matlab)
```