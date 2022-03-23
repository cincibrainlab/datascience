---
title: Publication Stats with the R Non-parametric mean tests with gtsummary Part 3 of 3
date: 2022-03-23
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---

# Introduction
In part 1, we used the `gtsummary` package to create a publication-ready demographics table with a few (relatively!) lines of code.

In part 2, we examined the normality of the data to help chose the right statistical test.

In part 3, we will finally conduct mean testing and export a publication-ready table.

## Dataset information
Please see Publication Stats with the R Normality Tests Part 2 for details of the data set. Links to download the data are presented directly in the R code below.

Briefly, the dataset consists of several event-related potential (ERP) responses collected from electroencephalography (EEG). The research cohort of 75 participants consists of those diagnosed with Fragile X Syndrome and so-called typically developing controls (Control). The EEG data was source localized which classifies response variables within a certain brain region. The data, of course, deidentified and source recording for this data is available publicly from federal NDAR database.

## Goals
1. Examine group differences in response variables between frontal, temporal, and occipital lobe.
2. Confirm or refute our hypothesis that the auditory synchronization signal should be strongest in the temporal lobes
3. Confirm or refute our hypothesis that the auditory synchronization will be minimal in the occipital lobes.

## Setting up the analysis

```r
# Initial hypothesis testing
pacman::p_load(tidyverse, gtsummary, flextable, moments)

# import dataset
df <- read_csv("https://tinyurl.com/2p8ksuzt") %>%
  mutate(eegid = factor(eegid))

df.select <- df %>% select(
  eegid, group, sex, visitage, chan, lobe,
  starts_with(c("itc", "ersp"))
)
```

## Guidance from normality tests
Part 2 investigated the normality of the response variables. The testing confirmed the data did not follow a normal distribution. 
Our scientific question involves comparing the mean difference in response variables between two groups. In this case, the Wilcoxon signed rank test is an appropriate non-parametric test. In addition, as we will be comparing multiple variables we will adjust p values to account for multiple tests.

## Summarizing replicate data
Your data, like this set, may have replicate values that need to be summarize. Each cortical `lobe` contains multiple source localized `chan` which represent atlas regions of interest (ROI). For consistency in naming conventions we use `chan` to represent scalp electrodes or atlas ROIs from a source localization.

```r
# A tibble: 5,100 × 2
   chan                     lobe     
   <chr>                    <chr>    
 1 banksstsL                Temporal 
 2 banksstsR                Temporal 
 3 caudalanteriorcingulateL Limbic   
 4 caudalanteriorcingulateR Limbic   
 5 caudalmiddlefrontalL     Frontal  
 6 caudalmiddlefrontalR     Frontal  
```

We will use basic dplyr techniques to average across `lobes` for individual subjects. Thus, each subject will have response variables for 7 `lobes` versus 68 `chan`.

```r
df.forWilcox1 <- df.select %>%
  select(eegid, group, chan, lobe, 
  starts_with(c("itc", "ersp"))) %>%
  group_by(eegid, group, lobe) %>%
  summarize(across(
    starts_with(c("itc", "ersp")), 
    .fns = mean)) %>%
  ungroup() %>% 
  filter(lobe %in% c("Frontal","Temporal","Occipital"))
```
![](https://www.dropbox.com/s/32k6oak0p6wvakp/CleanShot%202022-03-23%20at%2009.54.26%402x.png?raw=1)
Notice the row numbers have dropped to 75 subjects x 7 regions.
Finally, we also filter the data to address our main hypothesis which is looking at only three lobes.

If you haven't investigated the `across` helper, it is highly recommended and replaces older commands like `summarize_all`. Don't forget to `ungroup` your dataset at the end!

## Using `gtsummary` to accelerate table creation and workflow
Now lets run our comparisons using the `tbl_summary` function.

The most stripped down version of this function looks like this:
```r
df.forWilcox1 %>% 
  tbl_summary(include = c(group, 
                          starts_with(c("itc","ersp"))),
              by = group)
```
With the following output:
![](https://www.dropbox.com/s/7d5jg5aofwnt8fm/CleanShot%202022-03-23%20at%2010.00.09%402x.png?raw=1)

Let's consider what revisions this table needs:
1. Summary statistics displayed are not optimal for this data
1. Labels are not formatted
1. No statistical comparisons
1. There is consideration for the grouping variable `lobe`

All of these are easy to address within the `gtsummary` package.

### Optimizing summary statistics for the dataset
Let use more conventional measures such as mean and standard deviation. Given the skew in the data using median would also be reasonable. We will also round off the digits at three significant places for the `itc` variables. Let's also use our naming vectors from part 2 to clean up the labels.

```r
# variable names
var.levels <- c("itc40", "itc80", "itconset", "itcoffset", "ersp_alpha", "ersp_gamma1", "ersp_gamma2")
# labels corresponding to variable names
var.labels <- c("ITC: 40 Hz", "ITC: 80 Hz", "ITC: Onset", "ITC: Offset", "ERSP: Alpha", "ERSP: Gamma1", "ERSP: Gamma2")
# create a "named" list in R
var.named <- setNames(var.levels, var.labels)

gt.forWilcox1 <- df.forWilcox1 %>%
  rename(var.named)  # use named list to rename variables
  tbl_summary(
    include = c(
      group,
      starts_with(c("itc", "ersp"))
    ),
    by = group,
    statistic = list(
      all_continuous() ~ "{mean}\u00B1{sd}"),
    digits = starts_with("itc") ~ 3)
```

Let's now add our Wilcoxon test by adding `gtsummary` functions to the new `tbl_summary` object, `gt.forWilcox1`:
```r
  gt.forWilcox1 %>% 
    add_p(everything() ~ "wilcox.test") %>% 
    add_q(method = "fdr")
```
Output:
![](https://www.dropbox.com/s/fswm1ynp2z7eme5/CleanShot%202022-03-23%20at%2010.58.22%402x.png?raw=1)

### `Strata` (Stratify) by Cortical Lobe
At this point, I'm very satisfied with the `tbl_summary` output and am ready to add the `strata` layer with the cortical `lobe`. This is similar to `facet` if you have used `ggplot`.

To be honest, the syntax to setup a strata is a little tricky and I usually cut and paste a template when I use it. 

Here is how it works:
```r
df.forWilcox1 %>%
  tbl_strata(
    strata = c(lobe),  ~.x %>% 
    tbl_summary(
      include = c(
        group,
        starts_with(c("itc", "ersp"))
      ),
      by = group
    )
  )
```
Notice how the `tbl_strata` function internally takes a `tbl_summary` object as an input. This unwieldness comes with a big advantage - underneath the `gtsummary` function it is using the `purrr` package which really makes it compatable with all of the R universe.

Let's see the output:
![](https://www.dropbox.com/s/i2exgv6v074g4lq/CleanShot%202022-03-23%20at%2011.06.43%402x.png?raw=1)

### Reviewing the stratified table output:
This table is a little wide and will require some formatting adjustments. Let's revise our code:
```r
theme_gtsummary_journal("jama") # adding gtsummary styling
theme_gtsummary_compact()  # compact styling

gt.forWilcox1 <- df.forWilcox1 %>%
  mutate(lobe = factor(lobe, levels=c("Temporal","Frontal", "Occipital"))) %>% 
  rename(var.named) %>% # named list
  tbl_strata(
    .combine_with = "tbl_stack",
    strata = c(lobe), ~ .x %>%
      tbl_summary(
        include = c(
          group,
          starts_with(c("itc", "ersp"))
        ),
        by = group,
        statistic = list(
          all_continuous() ~ "{mean}\u00B1{sd}"
        ),
        digits = starts_with("itc") ~ 3
      ) %>%
      modify_fmt_fun(
        update = c(stat_1, stat_2) ~ function(x) str_remove(x, "^0+")
      ) %>% 
      modify_fmt_fun(
        update = c(stat_1, stat_2) ~ function(x) str_replace(x, "\u00B10+","\u00B1")
      )  %>%
      add_p(everything() ~ "wilcox.test", 
            pvalue_fun = ~ .x %>%
              style_pvalue(digits = 2) %>%
              stringr::str_replace("0.", ".")) %>%
      add_q(method = "fdr",
            pvalue_fun = ~ .x %>%
              style_pvalue(digits = 2) %>%
              stringr::str_replace("0.", "."))
  )

gt.forWilcox1 %>% as_flex_table() %>% save_as_docx(path = "test.docx")
```
The new output is as follows:
![](https://www.dropbox.com/s/zfpoo3nz7ihzvy6/CleanShot%202022-03-23%20at%2013.51.29%402x.png?raw=1)

Let's look at the polishing updates in this last revision:
1. Use `gtsummary` theme to preset formatting
1. Use the `gtsummary_compact` to use a more compact theme.
1. added code to remove leading zeros
1. used `.combine_with` parameter of `tbl_strata` to stack tables vertically instead of side-by-side.

The final output looks great! There will be some small formatting changes we can update in Microsoft Word.

![](https://www.dropbox.com/s/lb8s4cv4d5ghyau/CleanShot%202022-03-23%20at%2014.48.09%402x.png?dl=0)

Hopefully this three part tutorial has been helpful in working through a real-world example of the initial steps of an analysis before more complex modeling. 

Here is a link to the final script:
https://www.dropbox.com/s/uwlon6xrr6jsv6e/srchirp_results3_groupmean.R?dl=1



