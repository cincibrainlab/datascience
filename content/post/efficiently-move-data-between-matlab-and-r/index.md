---
title: "Part II: Efficiently Move Data Between MATLAB and R"
subtitle: "Part II: Bulk Import of Data Variables into R from MATLAB"
date: 2021-10-03T00:45:00.000Z
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

## 1. Load required packages into R

```r
install.packages(c("tidyverse","purrr", "R.matlab"))
library(tidyverse)
library(purrr)
library(R.matlab)
```

### R.matlab package can import MAT files into R

Other than the familiar tidyverse libraries, the [R.matlab Package](https://github.com/HenrikBengtsson/R.matlab) package can import MAT files. Remember that you must save your MAT file on the MATLAB side using the '-v6' tag to make sure the format is compatible. 

## 2. Import MAT file

```R
list.import.mat <- R.matlab::readMat("Build/model_cfcparfor4.mat") 

key <- list.import.mat$output[1] %>% unlist()
data <-list.import.mat$output[2]
```

The syntax here should be straightforward. We are importing the MAT file. We are also separating out the "key" which describes each variable and "data" which is field that stores the data. This is a particular advantage of using MATLAB struct as the data export vehicle as it is easy to orientate with fieldnames.

## 3. Home Base: Preparing the data frame with all variables

The following series of code may appear complicated on the surface, but should be highly reusable for future MATLAB imports. The readMat function imports the contents of the MAT files into lists. R Lists are similar to MATLAB cells and this approach lessens the upfront hassle of holding different data types. However, working with lists on subsequent steps can be extremely frustrating! Many are probably unfamiliar with R's advanced tools for handling lists, but in this case, several functions make this import incredibly efficient. 

Let's start by creating an R dataframe/tibble for holding all the data contained within the MATLAB data struct. This will serve as a "home base" for creating individual datasets as needed.

```R
df.import.mat <- data  %>% as_tibble(.name_repair = ~c("allData"))%>% 
  unnest_longer(col = allData, indices_include = FALSE) %>%
  unnest_wider("allData", simplify = TRUE, names_repair = ~key) %>% 
  mutate(eegid = unlist(eegid))
```

Let's walk through this code line by line:

1. **df.import.mat:**  the output tibble   
2. **data:** the large list imported from the MAT file
3. **as_tibble(.name_repair = ~c("allData")):** we convert the large list into a tibble data structure with a single column, "allData", using the .name_repair parameter.
4. **unnest_longer(col = allData, indices_include = FALSE):** we are reversing the "nesting" of the lists and extracting the individual cells from the column allData that contain data (12 variables) for each subject. 

   ```coffeescript
   # A tibble: 136 x 1
   allData     
      <named list>
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
     <list [13]> 
   ```
5. **unnest_wider("allData", simplify = TRUE, names_repair = ~key):** we now spread the 12 data variables across into individual columns and assign names from the key variable we defined earlier.

   ```
   # A tibble: 136 x 13
      eegid    mvarpac1   mvarpac2   pli1     pli2     evecs    evals    sFiltMap   netMaps    frex    chans   tfP     tfT    
      <list>   <list>     <list>     <list>   <list>   <list>   <list>   <list>     <list>     <list>  <list>  <list>  <list> 
    1 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    2 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    3 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    4 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    5 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    6 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    7 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    8 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
    9 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
   10 <named ~ <named li~ <named li~ <named ~ <named ~ <named ~ <named ~ <named li~ <named li~ <named~ <named~ <named~ <named~
   # ... with 126 more rows
   ```

   6. **mutate(eegid = unlist(eegid)):** we explicitly extract the ID field from a list to prepare for the next steps.

   ```
   # A tibble: 136 x 13
      eegid   mvarpac1    mvarpac2    pli1     pli2     evecs    evals    sFiltMap   netMaps   frex    chans   tfP     tfT    
      <chr>   <list>      <list>      <list>   <list>   <list>   <list>   <list>     <list>    <list>  <list>  <list>  <list> 
    1 D0079_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    2 D0099_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    3 D0101_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    4 D0148_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    5 D0179_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    6 D0199_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    7 D0221_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    8 D0272_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
    9 D0339_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
   10 D0366_~ <named lis~ <named lis~ <named ~ <named ~ <named ~ <named ~ <named li~ <named l~ <named~ <named~ <named~ <named~
   # ... with 126 more rows
   ```

   ##### After approximately 8 lines of code, we have the data in almost the same format as when left Matlab! However, since the data is now in a R Tibble, the data is far more workable from this position for visualization, statistics, and tabulation than when in the MATLAB cell format. 

## 4. Generating individual datasets

Without these functions, working with the nested lists created by the import function would be incredibly time consuming and frustrating. With the "unnest" series of functions ([tidyr ](https://tidyr.tidyverse.org/reference/nest.html), the data transformation into functional R data frames is very manageable. As mentioned previously, this is a relatively small price to be able to more easily work with the data downstream in R rather than remain in Matlab or attempt to create individual intermediates (i.e., CSV files). 

These code snippets can be modified to convert the lists within the "home base" structure into conventional data frames. I often rename the first column "selData" so I can reuse the code with other variables but similar data type.

### Example 1: Import frequency vector

I would like to extract this label vector for use in subsequent data frames. The data from MATLAB was stored with each subject as a {1×70 double}. 

```terra
df.frex  <- df.import.mat %>% select(eegid, frex) %>% rename(selData = 2) %>%
  unnest_longer(col = selData, indices_include = FALSE) %>% select(-eegid) %>%
  slice(1)  %>% 
  unlist(., use.names=FALSE)

labels.frex <- paste0("F",round(df.frex,1))
```

1. **df.frex:** output variable
2. **df.import.mat:** the "home base" created in Step 3 (135 subjects x 12 variable lists)
3. **select(eegid, frex):** focus on the common key column and the frequency column of lists only.
4. **rename(selData = 2):** give a common name to the variable common so code can be reused for other variables
5. **unnest_longer(col = selData, indices_include = FALSE):** The frequencies are extracted out of the list into a vector within the data frame.
6. **select(-eegid):** I remove the eegid column which is unnecessary for my frequency label vector
7. **slice(1):** I "slice" and extract all values from a single row
8. **unlist(., use.names=FALSE):** we finally convert this single row into a vector
9. **labels.frex <- paste0("F",round(df.frex,1)):** Add a leading "F" to each rounded frequency to comply with column naming in R

The results of the above:

```
labels.frex
 [1] "F10"   "F11.2" "F12.3" "F13.5" "F14.6" "F15.8" "F17"   "F18.1" "F19.3" "F20.4" "F21.6" "F22.8" "F23.9" "F25.1"
[15] "F26.2" "F27.4" "F28.6" "F29.7" "F30.9" "F32"   "F33.2" "F34.3" "F35.5" "F36.7" "F37.8" "F39"   "F40.1" "F41.3"
[29] "F42.5" "F43.6" "F44.8" "F45.9" "F47.1" "F48.3" "F49.4" "F50.6" "F51.7" "F52.9" "F54.1" "F55.2" "F56.4" "F57.5"
[43] "F58.7" "F59.9" "F61"   "F62.2" "F63.3" "F64.5" "F65.7" "F66.8" "F68"   "F69.1" "F70.3" "F71.4" "F72.6" "F73.8"
[57] "F74.9" "F76.1" "F77.2" "F78.4" "F79.6" "F80.7" "F81.9" "F83"   "F84.2" "F85.4" "F86.5" "F87.7" "F88.8" "F90"  
```

### Example 2: Import cross-frequency coupling results for each subject 

The R lists with the column names mvarpac1 and mvarpac2 represent lists which contain the key results for this analysis. Like the frequency array were also stored in MATLAB as {1×70 double}. However, each vector must be associated with their paired ID. In this case, the biggest challenge is extracting the unusual "matrix-column" that R creates.