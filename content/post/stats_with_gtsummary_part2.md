---
title: Publication Stats with the R Normality Tests Part 2 of 3
date: 2022-03-22
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---

# Introduction
In part 1, we used the `gtsummary` package to create a publication-ready demographics table with a few (relatively!) lines of code.

In part 2, we will examine the normality of the data to help chose the right statistical test.

In part 3, we will finally conduct mean testing and export a publication-ready table.

## Dataset information
To complete this tutorial you do not need to understand the response variables being presented, but might be interested nonetheless.

The event-related potentials (ERP) are auditory evoked potentials in response to an auditory chirp stimuli. This stimulus evokes a characteristic EEG response - brain oscillations phase synchronize to the frequency of the auditory stimulus. 

Our patient group in this population are individuals with Fragile X Syndrome (FXS), the most common heriditary form of intellectual disability. Individuals with FXS demonstrate a reduction in brain synchronization to the auditory chirp compared to controls.

If you are interested in learning more, see:
Ethridge, L. E., De Stefano, L. A., Schmitt, L. M., Woodruff, N. E., Brown, K. L., Tran, M., Wang, J., Pedapati, E. V., Erickson, C. A., & Sweeney, J. A. (2019). Auditory EEG Biomarkers in Fragile X Syndrome: Clinical Relevance. Front Integr Neurosci, 13, 60. https://doi.org/10.3389/fnint.2019.00060 

The current dataset is Dr. Ethridge and I attempting to reconstruct cortical sources from scalp electrode encephalography. Since in humans, the auditory cortex is aligned in such a way that the frontal and temporal lobe activity projected to the frontal scalp - scalp level EEG cannot distinguish between source. 

Using source localization, we can model the superficial cortical sources that the signal emerge from and answer questions such as 1) does the response to the cortical chirp emerge from the temporal or frontal sources? 2) can we distinguish difference in response from left to right? 3) does group or sex affect where the syncrhonizaton signal emerges from?

## Goals
Our major goal for this lesson is to examine and summarize our response variables. Next, we want to perform group comparisions and summarize everything in a table. 

## Dataset
As a reminder from Part 1:
The dataset consists of several event-related potential (ERP) responses collected from electroencephalography (EEG). The research cohort of 75 participants consists of those diagnosed with Fragile X Syndrome and so-called typically developing controls (Control). The EEG data was source localized which classifies response variables within a certain brain region.

The data, of course, deidentified and source recording for this data is available publicly from federal NDAR database.

## Setting up the analysis

```r
pacman::p_load(tidyverse, gtsummary, flextable)

# import dataset
df <- read_csv("https://tinyurl.com/2p8ksuzt") %>%
  mutate(eegid = factor(eegid))

df.select <- df %>% select(
  eegid, group, sex, visitage, chan, lobe,
  starts_with(c("itc", "ersp"))
)
```
I'll point a few highlights:
1. the `pacman` package makes it simple to install and load packages in a single step. It also allows for multiple packages separated by commas.
2. I'll again point out the convenience of cloud-hosted data links!
3. Notice the multiple strings in the `starts_with` command.
4. make sure the eegid column is converted to factor from numeric.

Let's see the results:
![](https://www.dropbox.com/s/jzb7tx9wjx0e7ga/CleanShot%202022-03-22%20at%2021.27.44.gif?raw=1)

## Off to analyze
The data has gone through a basic data cleaning and so we know there are no missing values and the data itself is organized correctly.

As we will look at mean differences, I am most interested in the distribution of the data. We are expecting a skew in the itc values based on previous results.

Let's make a graph of the data distribution:
```r
# Checking distribution of variables for skew and need for transformation:
p.skewcheck <- df.source.group %>% 
  select(starts_with(c("itc","ersp"))) %>% 
  pivot_longer(everything()) %>% 
  mutate(name = factor(name, levels = str_sort(unique(name), 
                                               numeric = TRUE))) %>% 
  ggplot() +
  geom_histogram(aes(x = value), color="blue", bins = 30) +
  facet_wrap(vars(name), scales = "free") +
  theme_minimal()
  ```
  ### Examining the plot
  ![](https://www.dropbox.com/s/vc8sodi86zkxfbc/CleanShot%202022-03-22%20at%2021.54.28%402x.png?raw=1)

  There is some data wrangling in this example. We are solely looking at the response variables across all groups. The pivot_longer in this case is very straightforward - it makes a column of the variable names and it puts the values of each within a new column called `value`.

  Looking at the output plot, it is clear that the `itc` variables are skewed with a right tail. Though at first glance the `ersp` variables look normally distributed, they do appear to be little narrow.

### Normality Testing in a pipe
  Let's try to get a bit more quantitative by adding some normality testing.

  Let's update our packages list with `moments` which gives us access to several normality functions:
  ```r
  pacman::p_load(tidyverse, gtsummary, flextable, moments)

# Conduct Normality Tests
# Conduct Normality Tests
df.skewcheck %>%
  group_by(name) %>%
  summarize(
    skew = skewness(value),
    kurtosis = kurtosis(value),
    ks = ks.test(value, "pnorm") %>% pluck("statistic"),
    ks_pval = ks.test(value, "pnorm") %>% pluck("p.value"),
    jt = jarque.test(value) %>% pluck("statistic"),
    jt_pval = jarque.test(value) %>% pluck("p.value"),
    n = n()
  )

```
![](https://www.dropbox.com/s/6rn22e3yj2tiyjs/CleanShot%202022-03-23%20at%2003.33.45%402x.png?raw=1)

### Custom Normality Testing Table
Our ad-hoc table now contains additional information to assess if they follow a normal distribution.

### Moments: skewness, kurtosis, and Jarque-Bera Test
Here we calculate two additional descriptive variables: skewness and kurtosis (both from the package `moments`). 

To learn more about these concepts, I found this particular link helpful:
https://medium.com/analytics-vidhya/moment-in-statistics-9407438c083b

You can, for example, learn the "tall" distribution we observed for the `ERSP` variables is termed "leptokurtic".

Next, we compute normality significance testing within each variable using two tests:
1. Kolmogorov-Smirnov (`stats`)
1. Jarque-Bera Test (`moments` pkg)

Here is a journal article discussing the two tests: https://www.econstor.eu/bitstream/10419/49919/1/668828234.pdf

In this particular case, I felt having two tests (which had valid assumptions on our data) would help bolster our decision making.

### Under the hood: `group_by` and `summarize` functions
You have likely used the summarize function to average together rows. I like the present example since it shows how powerful the `group_by` and `summarize` can be with other functions in the R universe. `group_by` creates virtual tibbles/dataframes within a larger dataframe by a grouping variable. This allows operations to be performed across each set, rather than across all the rows in the table.
#### Sanity test with n()
In this case, we run the normality test within a `summarize` command to consider the distribution of each response variable. The test is calculated "within" the group. Having the `n()` function to print the number of items for each row is an easy sanity check. In this case 5100 is the correct number of rows for each variables representing the 75 subjects times the 68 cortical regions.
#### `Pluck` command
The `pluck` command adds the ability to add results to your data table that may usually not "fit". For example, the output of the normality tests is an non-standard R object with different variables including a test statistic and a p-value. Let's look at the output directly from console by running the test on the `itc40` variable:
```
> jarque.test(df.select$itc40)

Jarque-Bera Normality Test

data:  df.select$itc40
JB = 44619, p-value < 2.2e-16
alternative hypothesis: greater
```
##### Examining the Result Environment
As you can see, these results do not fit neatly into a single cell. Let's examine the results placed in a variable `jt` in the environment tab in R-Studio:
![](https://www.dropbox.com/s/i9ebiu3s11cnuuh/CleanShot%202022-03-23%20at%2003.51.02%402x.png?raw=1)

Here you can see the underlying `environment` of the results includes several variables that the function summarizes into statements when you run the test. It also has the names of the values which we can use to `pluck` them out.

##### Pluck is under used!
So the `pluck` command automatically extracts a value deep within a result environment and presents that single value. This single value can then be used within a table cell. In our example, we `pluck` the normality test `statistic`and the `p` value. There are a surprising number of places where `pluck` can tidy up your workflows.

### Examining normality results
The results all point in the same direction - the variables are not normally distributed. This information helps us determine what inferential statistical tests would be appropriate.

#### Transforming the data
Transforming the data may allow it to fit a normal distribution but adds additional complications. For example, since the response is in a different set of units the interpretation of the results is not as straightforward as the difference in means. 

That being said, let's recalculate our table after applying a log transform:

```r
# add log versions of each variable
# create minimum table to account for negative values
df.minvalues <- df.skewcheck %>%
  group_by(name) %>%
  summarize(minvalue = min(value))
# log transform (minimum = 1)
df.skewcheck.log <- df.skewcheck %>%
  left_join(df.minvalues) %>%
  mutate(logvalue = value + 1 - minvalue)
```
As the dataset contains negative values, we also have to linearly transform the variable (+1 - minvalue) for the log calculation to not produce NaNs.

![](https://www.dropbox.com/s/znv51rlmhwd4t29/CleanShot%202022-03-23%20at%2004.26.07%402x.png?raw=1)

Let's rerun our normality table on the transformed variable:
```r
```
Let's examine the results table:
![](https://www.dropbox.com/s/7gx85ddkmuzxh6x/CleanShot%202022-03-23%20at%2004.30.51%402x.png?raw=1)
And the associated plots:
![](https://www.dropbox.com/s/mjwf21rk181c0ev/CleanShot%202022-03-23%20at%2004.30.31%402x.png?raw=1)

As you can see the log transform was not sufficient for this data! If you are more interested in more complex transforms I would refer you to the `bestNormalize` package (https://github.com/petersonR/bestNormalize). 

### Non-parametric testing
A common assumption of most statistical analyses is that of normality. In the face of violating normality assumptions, we can move on to using non-parametric methods. 

## Exporting our work
Our normality table and figure may be useful in the supplementary materials to justify our analytic approach. 

Creating a nicely formatted version of our table can end up being a time consuming process. So I have a few tricks to speed it up.

### Naming vectors
```r
var.levels <- c("itc40", "itc80", "itconset", "itcoffset", "ersp_alpha", "ersp_gamma1", "ersp_gamma2")
var.labels <- c("ITC: 40 Hz", "ITC: 80 Hz", "ITC: Onset", "ITC: Offset", "ERSP: Alpha", "ERSP: Gamma1", "ERSP: Gamma2")
header.labels <- c(
  name = "Measure", mean = "Mean",
  median = "Med.", sd = "SD",
  skew = "Skew", kurtosis = "Kurtosis",
  ks = "KS", ks_pval = "p", jt = "JT", jt_pval = "p"
)
```
There are various forms of this technique, but essentially strings that you would usually pass to functions through lists should standalone in variables. This makes maintaining the code much easier (edit in one place) and also can align the labels throughout various scripts.

### Creating a formatted `flextable` to export to Word

```r
ft.normtable <- df.normtable %>%
  select(-n) %>%
  mutate(name = factor(name,
    levels = var.levels,
    labels = var.labels
  )) %>%
  mutate(
    across(contains("pval"), .fns = ~ ifelse(.x <= .05, paste0("*", ""))),
    across(where(is.numeric), .fns = ~ round(.x, digits = 2))
  ) %>%
  mutate(
    ks = paste0(ks, ks_pval),
    jt = paste0(jt, jt_pval)
  ) %>%
  select(-contains("pval")) %>%
  flextable() %>%
  set_header_labels(values = header.labels) %>%
  theme_booktabs()
  ```

Let's run over simple steps:

#### Select the final data columns
This step consists for both removing columns, but also the option of combining columns. For example, the two p value columns in our original table take up additional space. We can represent a significant p value with a character instead and combine it with the statistical column.

### Formatting
On this step I am looking on how headers, labels, and data is formatted. This includes proper rounding and abbreviations.

Let's look at the output table:
![](https://www.dropbox.com/s/apt4jqpn0zndjop/CleanShot%202022-03-23%20at%2005.31.47%402x.png?raw=1)

## Exporting to Word
One of the reasons I advocate for using `flextables` is the easy export to Word. In this case, we just have to string together one additional command:

`ft.normtable %>% save_as_docx(path = "supplemental_table_normality.docx")`

## Summary of Part II
In this tutorial we reviewed the some times tedious process of closely examining the "moments" of our data. Journal and grant reviewers often raise concerns about the appropriateness of a specific statistical test. In this case, normality testing can provide key data in selecting the best analysis for subsequent tests.

In part 3, we will work on conducting group comparisons. 




