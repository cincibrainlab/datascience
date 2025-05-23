---
title: Generating a Correlation Table - Part 2
date: 2022-03-30
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
# Correlation Tutorial: Performing Correlation Analysis

If you haven't prepared data for this tutorial, please see part 1 [here](https://www.cincibrainlab.com/post/generating-correlations/).

## Introduction and Goals
In this tutorial, we will conduct clinical correlations in a large EEG dataset. Our ambitious set of goals includes:
1. Wrangling data into a wide-format for correlation anaysis
2. Conducting bivariate correlations   **<- you are here**
3. Performing partial correlations
4. Correction for multiple comparisions
4. Visualizing relationships
5. Creating an interactive application for exploring correlations

## Dataset
After part I, we created a wide-style dataset of our grouping, response, and clinical variables. This table follows the form of *x* response variables with *y* clinical variables and *z* grouping variables for *n* subjects, your table should be *n* rows with *x* + *y* + *z* columns.

The completed dataset from part one can be accessed here:
<https://figshare.com/ndownloader/files/34558217>

The completed code for this tutorial can be found here:

## Preparation
As we are performing computations on data, you will have a variety of different packages and base R functions to choose from. I am going to recommend an excellent package called `corx` which is well suited for large volume exploratory clinical correlations.

Please see the development branch here:
<https://github.com/conig/corx/tree/devel>

The author has been very responsive to feedback and has included new features such as adjusting for multiple comparisons. However, the main CRAN version of the package is outdated and so to install the development branch you can either use:

```r
remotes::install_github("conig/corx@devel")
```
or my recommendation is to use the `pacman` package manager:
```r
pacman::p_load_gh("conig/corx@devel")
```
If you use the package manager it will not reload the package after installation on subsequent runs.

Other package that we will need is the `tidyverse`. For themes, I will recommend `koundy` excellent theme_Publication which can be installed with as single line of code.

## Data preparation
Let's load the dataset and prepare variable names. Let's also take a peak at how the data looks by printing the first few rows.

```r
pacman::p_load_gh("conig/corx@devel")
pacman::p_load(tidyverse)

source("https://bit.ly/3lgsJ4e") # theme publication

df.raw <- read_csv("https://figshare.com/ndownloader/files/34558217")

grouping_variable <- c("group","sex")
response_variables <- c("itc", "stp", "ersp") # use with starts_with
clinical_variables <-  c(
  "eegid",
  "Age at Visit",
  "Deviation IQ",
  "Non Verbal Z Score",
  "Verbal Z Score",
  "ADAMS General Anxiety",
  "ADAMS Obsessive/Compliance Behavior",
  "SCQ Total",
  "ABC FXS subscale 1: irritability/aggression",
  "ABC FXS subscale 4: Hyperactivity/Noncompliance",
  "ABC FXS subscale 5: Inappropriate speech",
  "ABC FXS subscale 2: lethargy/social withdrawal",
  "ABC FXS subscale 3: stereotypy",
  "WJ-III"
)

```
```
> df.raw
# A tibble: 75 × 76
   eegid group sex   itc40_LF itc40_LO itc40_LT itc40_RF itc40_RO itc40_RT
   <dbl> <chr> <chr>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>
 1   179 FXS   F      0.0257  0.00595  0.0145    0.0224   0.00480  0.0167 
 2   199 TDC   M      0.00932 0.000846 0.00273   0.00940  0.0110   0.00890
 3   221 TDC   M     -0.00270 0.0134   0.0181    0.00695  0.0112   0.0141
 ```
## Validate your table dimensions
Spending a few minutes here to verify you data can save you a lot of time later. Here, I am confirming that the table fits my expected dimensions. If you are off by even 1 column or row I would carefully inspect previous steps before moving on.

Here the table conforms to our expectation: 
With 75 rows corresponding to each subject and a total of 76 columns which includes 3 grouping variables, 60 response variables, and 13 clinical variables.

## using `corx` to run an example correlation
Before performing the function across the whole dataset, let's try a simple example. The corx function takes two columns (`x` and `y`) and returns a table with the bivariate correlation coefficient and significance.

```r
df.raw %>% corx(x = itc40_RT, y=`WJ-III`)
```
```
---------------
         WJ-III
---------------
itc40_RT  .46**
---------------
Note. * p < 0.05; ** p < 0.01; *** p < 0.001
```
### Running a spearmans correlation
A few tutorials ago we took a deep dive on these eeg variables and found they are not normally distributed. So in this case, we will switch our `method` to `Spearman` to correct for this.

```r
df.raw %>% corx(x = itc40_RT, y=`WJ-III`, method = "spearman")
```
```
---------------
         WJ-III
---------------
itc40_RT .69***
---------------
Note. * p < 0.05; ** p < 0.01; *** p < 0.001
```

### Plotting our results
Let's also plot our results using a scatter plot and plot a quantile regression which is better suited to represent the spearman correlation.
```r
df.raw %>% ggplot(aes(x = itc40_RT, y=`WJ-III`)) +
  stat_quantile(quantiles =0.5) +
  geom_point(size=5, fill="darkgray",color="black", shape=21) +
  xlim(0,.08) +
  theme_Publication() +
  theme(aspect.ratio = 1)
```
<img src="https://www.dropbox.com/s/9wpsd3jh1s01bqn/CleanShot%202022-03-30%20at%2009.50.05.png?raw=1" alt="drawing" width="300"
 style="display: block; margin: 0 auto" />

### Converting the results to a dataframe for further analysis
The results from `corx` are a custom table that can be easily converted to a `tibble` using the `as_tibble` function.

```
> corr.res %>% as_tibble(rownames = "measure")
# A tibble: 1 × 2
  measure  `WJ-III`
  <chr>    <chr>   
1 itc40_RT .69***  
```
## Putting it all together to run a correlation across the whole dataset
Now that we have our basic functions in place, we can use the `corx` function to run a correlation across the whole dataset. The output will be a large `tibble` we can use to correct for multiple comparisons and tabulate for publication.

### Designing a corx based function
The function we will build will have inputs:
1. The raw values
1. A grouping variable to filter by
1. response variables
1. clinical variables

In this case, we are not interested in how the response and clinical variables relate within each other, just between them. So we will specify our `x` and `y` inputs as the response variables and clinical variables separately.

The output should be a `tibble` with the following columns:
1. `measure`: the name of the measure
1. `corr`: the correlation coefficient
1. `p`: the p value
1. `adj.p`: the adjusted p value

To go from the inputs to the desired output, we have a few steps to implement, so let's build our function step by step and test it along the way.

Let's first create a skeleton function with our inputs and outputs. Check your syntax by running the empty function. 

```r
corr.res <- function(df, group.variable, group.filter,
                     response.variables, clinical.variables){
  
}
```
Let's add in our `corx` function and the other functionality needed for our inputs:
```r
fx.corr.res <- function(df,
                     group.variable,
                     group.filter,
                     response.variables,
                     clinical.variables) {
  df %>%
    filter(eval(parse(text = group.variable)) == group.filter) %>%
    corx(x = response.variables, y = clinical.variables,
         method = "spearman")  
}
```
### Parsing Strings into Variables: Specifying an input variable with a character string
As we may want flexiblity in our function to filter by different variables, we have to find a way to take the string input (group.variable) and let R evaluate it as a variable. There are several ways of doing things, but I added the most common tried and true method to the function.
```
filter(eval(parse(text = group.variable)) == group.filter) 
```
-the inner `parse` function takes a string and evaluates it as an R expression. 
-the outer `eval` function takes the result of the inner `parse` function and evaluates it as an R expression.

When we run the function, the filter function "sees" the string as a column name in the dataframe and allows it's usual operation.

### Testing our function to output standard corx results
Before wrangling the output, let's test our function and see if we can get corx results for the entire dataset.

Let's populate our function call:
```r
df.corr.res <- fx.corr.res(
  df = df.raw,
  group.variable = "group",
  group.filter = "FXS",
  response.variables = response_variables,
  clinical.variables = clinical_variables)
```
and see the results ...
```
Error: 1 name could not be found: response.variables.
```

### Troubleshooting 1: Generating multiple variable names from a dataset
The function throws an error that `response.variables` could not be found. The error description is not very helpful, but looking at the `response_variables` definition gives us some clue on what is going on.
```r
response_variables <- c("itc", "stp", "ersp") # use with starts_with
```
R is attempting to `select` columns that match the `response_variables` input but since they only are search terms, R cannot make a match and throws an error. We opted to use a search term for a `select` helper function since typing in all 60 variable names would be tedious.

So let's construct a simple expression that gives R a proper list of variable names to search for. There are many ways to accomplish this, but I chose a version with familiar functions.
```r
response_variable_names <- df.raw %>% 
  select(starts_with(response_variables)) %>% 
  names()
```
Here we are using the `starts_with` function to generate a list of variables that start with the string `itc`, `stp`, or `ersp`:
```
> response_variable_names
 [1] "itc40_LF"       "itc40_LO"       "itc40_LT"       "itc40_RF"      
 [5] "itc40_RO"       "itc40_RT"       "itc80_LF"       "itc80_LO"      
 [9] "itc80_LT"       "itc80_RF"       "itc80_RO"       "itc80_RT"      
[13] "itconset_LF"    "itconset_LO"    "itconset_LT"    "itconset_RF"   
[17] "itconset_RO"    "itconset_RT"    "itcoffset_LF"   "itcoffset_LO"  
[21] "itcoffset_LT"   "itcoffset_RF"   "itcoffset_RO"   "itcoffset_RT"  
...
```
### Testing our function with the autogenerated variable names
Let's retry our function with our new variable names and we have successful corx output!

```r
df.corr.res <- fx.corr.res(
  df = df.raw,
  group.variable = "group",
  group.filter = "FXS",
  response.variables = response_variable_names,
  clinical.variables = clinical_variables)
```
```
-----------------------------------------------------------------
               eegid Age at Visit Deviation IQ Non Verbal Z Score
-----------------------------------------------------------------
itc40_LF         .16         -.28        .49**               .36*
itc40_LO        -.04         -.23          .27                .31
itc40_LT         .14         -.20        .47**              .46**
itc40_RF         .10          .17        .46**               .38*
itc40_RO        -.08          .23         -.15               -.20
itc40_RT         .03          .22          .10                .12
itc80_LF         .18          .09          .17               -.02
```

Though this output could be exported as is for further review, we want to integrate the results into the rest of our workflow which is standardized on dataframe/tibbles. We also note that the `p` columns are not included in the output and are hidden by default.

### Modifying Function Output
Let's work on the following adjustments to our custom corx function:
1. extract out the r, p, and n values from the corx output
1. convert each to a tibble
1. combine columns into a single tibble
1. corrected for multiple comparisions

The default output of `corx` is an result object which contains statistical measures, but are not by default outputted in a tidy format. We can retrieve these columns by accessing the `corx` object directly.
The  `pluck` function from the`purrr` package can be used to extract the columns from the result object. 

    The `pluck` function can deeply access nested objects and extract the columns from the result object.

Let's try it with the `p` values:
```r
corx.corr.res %>% pluck("p") 
# as an alternative to 
corx.corr.res$p
```
```
                    eegid Age at Visit Deviation IQ Non Verbal Z Score
itc40_LF       0.36043976  0.096467994  0.003660203        0.037139640
itc40_LO       0.80688081  0.173993007  0.124372333        0.078895703
itc40_LT       0.41534232  0.239117466  0.006384824        0.006548105
itc40_RF       0.56527182  0.320416246  0.007689071        0.030320911
itc40_RO       0.62869072  0.186083951  0.420001714        0.274026467
```
`pluck` can be used within pipes and also can find nested objects which makes it a smart alternative to directly accessing the variable using the base $ sign.

### Extracting out P Values
Let's extract out the p values from the corx output and convert them to a tibble.
```r
corx.corr.res %>% pluck("p") %>% as_tibble(rownames = "measure") %>%  
  pivot_longer(cols = -measure, names_to = "clinvar", values_to = "p" )
```
The `pivot_longer` function can be used to convert a wide format into a long format. This means each observation (in this p values) will be in a single column with the current column names representing clinical measures in an adjacent column.
```
# A tibble: 780 × 3
   measure  clinvar                                                p
   <chr>    <chr>                                              <dbl>
 1 itc40_LF Age at Visit                                    0.0965  
 2 itc40_LF Deviation IQ                                    0.00366 
 3 itc40_LF Non Verbal Z Score                              0.0371  
 4 itc40_LF Verbal Z Score                                  0.00182 
 ```

 ### Combining P Values with r and n values
 Let's extract the rest of the relevant variables and see if we can neatly combine them together using a join type command.

 Let's make a function for the pull, otherwise the code will get very messy very quickly:
 ```r
pull_corr <- function(df, var_name){
  # extracts statistical columns from corx object
  df %>% pluck(var_name) %>% 
    as_tibble(rownames = "measure") %>%  
    pivot_longer(cols = -measure, 
                 names_to = "clinvar", 
                 values_to = var_name)
}
 ```

 Let's use a join command to merge the tables together. As tempting as it is to simply `bind_columns` this is different than a join and can potentially match two tables with different orders. Join functions can recognize that both measure and clinvar are matched columns and will use the unique combination to match the unique pairs:
 ```r
# create tibble of correlation statistics
df.corr.res.tmp <- left_join(left_join(pull_corr(corx.corr.res, var_name = "r"), 
                    pull_corr(corx.corr.res, var_name = "p")),
          pull_corr(corx.corr.res, var_name = "n"))
```

Our output is a satisfying table of all the correlations and p values:
```
Joining, by = c("measure", "clinvar") # very important
Joining, by = c("measure", "clinvar")

# A tibble: 780 × 5
   measure  clinvar                                              r        p     n
   <chr>    <chr>                                            <dbl>    <dbl> <dbl>
 1 itc40_LF Age at Visit                                    -0.281 0.0965      36
 2 itc40_LF Deviation IQ                                     0.492 0.00366     33
 3 itc40_LF Non Verbal Z Score                               0.364 0.0371      33
 4 itc40_LF Verbal Z Score                                   0.522 0.00182     33
 5 itc40_LF ADAMS General Anxiety                           -0.110 0.561       30
 ```
## Correction for Multiple Comparisions
R makes it relatively simple to correct for multiple comparisions with a dataframe with a p value. Though there are cases where you may want to individually correct groups of comparisions, in this case we will perform a 5% false discovery rate on 780 correlations. This rate expects about 780 * .05 = 38 comparisons to be positive due to chance. 

  FDR = expected (# false predictions/ # total predictions)

Let's look at our actual observed significant values:
```r
df.corr.res.corrected %>% filter(p <= .05)
```
```
# A tibble: 71 × 6
   measure  clinvar                                  r        p     n   adjp
   <chr>    <chr>                                <dbl>    <dbl> <dbl>  <dbl>
 1 itc40_LF Deviation IQ                         0.492 0.00366     33 0.190 
 2 itc40_LF Non Verbal Z Score                   0.364 0.0371      33 0.471 
 3 itc40_LF Verbal Z Score                       0.522 0.00182     33 0.163 
 4 itc40_LF SCQ Total                           -0.576 0.000698    31 0.0838
 5 itc40_LO ADAMS Obsessive/Compliance Behavior -0.361 0.0461      31 0.521 
 6 itc40_LO SCQ Total                           -0.461 0.00905     31 0.240 
 ```
We have about 71 significant correlations out of 780 which is approximately 71/780 * 100 = 7.1% of the total. Thus, we would expect a small number of highly significant corrections after accounting for 5% of false positives.

Let's implement the correction in code:
```r
df.corr.res.corrected <- df.corr.res.tmp %>% mutate(adjp = p.adjust(p, method="fdr"))

# check for positive results at our threshold of 5% FDR
df.corr.res.corrected %>% filter(adjp <= .05)
```
```
# A tibble: 5 × 6
  measure       clinvar                                 r         p     n   adjp
  <chr>         <chr>                               <dbl>     <dbl> <dbl>  <dbl>
1 itc40_RF      WJ-III                              0.712 0.0000214    28 0.0167
2 itc40_RT      WJ-III                              0.642 0.000227     28 0.0355
3 itc80_RT      WJ-III                              0.646 0.000203     28 0.0355
4 stp_gamma1_LT ADAMS Obsessive/Compliance Behavior 0.623 0.000183     31 0.0355
5 stp_gamma2_LT ADAMS Obsessive/Compliance Behavior 0.635 0.000123     31 0.0355
```

So we ended up with 5 significant correlations out of 71 and from first glance these are physiologically interesting. At this point, we want to perform a subgroup analysis on males only (in Fragile X Syndrome males expression little to no protein compared to females with FXS). For this exploratory analysis, we will also correct values, but will use a typical p < .05 as the cutoff. Instead of making 2 tables, I want to combine both correlation tables into a single table. We can do this by adding an additional column to the present table which will serve as a label for later filtering.

```r
# add label column for table
df.corr.res.all <- df.corr.res.corrected %>% mutate(label = "ALL")
```

Let's now use our functions to quickly spin up a male only subgroup correlation analysis for male affected with Fragile X only:
```r
# run main correlation function
corx.corr.res.males <- fx.corr.res(
  df = df.raw %>% filter(sex == "M"),
  group.variable = "group",
  group.filter = "FXS",
  response.variables = response_variable_names,
  clinical.variables = clinical_variables)

# create tibble of correlation statistics
df.corr.res.male.tmp <-
  left_join(left_join(
    pull_corr(corx.corr.res.males,
              var_name = "r"),
    pull_corr(corx.corr.res.males, var_name = "p")
  ),
  pull_corr(corx.corr.res.males, var_name = "n"))

# adjust for multiple comparisons
df.corr.res.male.corrected <- df.corr.res.male.tmp %>% mutate(adjp = p.adjust(p, method="fdr"))
df.corr.res.male.corrected %>% filter(p <= .05) %>% 
  arrange(p)

# add label column for table
df.corr.res.male <- df.corr.res.male.corrected %>% mutate(label = "MALE")
```
Notice that in the function itself, I perform a inline filter for males ("M") prior to the the function inputs. This lets me overcome the limitation of my function of only allowing a single filtering variable. 

## Creating a final raw results table
By adding labels to each dataset, we now have the ability to bind the rows into a single table since the `label` column will be unique between the two. This will simplify reporting and allow us to implement this table easily into an R-shiny application for visualization.

```r
df.corr.res <- df.corr.res.all %>% bind_rows(df.corr.res.male)
write_csv(df.corr.res, file = 'figshare/jon_srcchirp_correlationResults.csv')
```

## Wrapping up
To summarize, during this lesson we:
1. learned how to perform correlation analysis on a dataset
1. plotted a scatter plot of the correlation results
1. adjusted for multiple comparisons
1. created a table which contains a main and subgroup analysis of correlations results

At this point, I would recommend clearing your environmental variables and running your script to see if it will remain error free.

## Coming up
Now that we have our correlation results, it would be nice to plot the data to better understand the relationships. In this case, building a simple R shiny application to display and print plots may be of use.