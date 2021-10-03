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

### R.matlab package can import MAT files into R
Other than the familiar tidyverse libraries, the [R.matlab Package](https://github.com/HenrikBengtsson/R.matlab) package can import MAT files. Remember that you must save your MAT file on the MATLAB side using the '-v6' tag to make sure the format is compatible. 

## Import MAT file
```R
list.import.mat <- R.matlab::readMat("Build/model_cfcparfor4.mat") 

key <- list.import.mat$output[1] %>% unlist()
data <-list.import.mat$output[2]
```
The syntax here should be straightforward. We are importing the MAT file. We are also separating out the "key" which describes each variable and "data" which is field that stores the data. This is a particular advantage of using MATLAB struct as the data export vehicle as it is easy to orientate with fieldnames.

