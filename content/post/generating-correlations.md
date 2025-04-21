---
title: Generating a Correlation Table (Part 1)
date: 2022-03-30
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
# A tutorial on generating correlations

## Introduction and Goals
In this tutorial, we will conduct clinical correlations in a large EEG dataset. Our ambitious set of goals includes:
1. Wrangling data into a wide-format for correlation anaysis
2. Conducting bivariate correlations
3. Performing partial correlations
4. Correction for multiple comparisions
4. Visualizing relationships
5. Creating an interactive application for exploring correlations

## Dataset
We have used the auditory chirp dataset in previous tutorials. You can download the data from *Figshare*, however, we will plan on pulling the data directly into R. 

[Link to Chirp Dataset @ Figshare](https://figshare.com/ndownloader/files/34554656)

## Code and final results
The full code used in the tutorial below is available [here](https://github.com/cincibrainlab/jom_sourcechirp/blob/main/Rscripts/jon_srcchirp_prepareCorrelationData.R)
The completed dataset for correlations is available [here](https://figshare.com/ndownloader/files/34558217)


## Preparing data for correlation functions
Though we have tricks up our sleeve, in general, a wide format is best for most correlation functions. For clinical data, this means you aim for creating a single row of values for each subject. 

## The ideal correlation table
If you want to correlate *x* response variables with *y* clinical variables for *n* subjects, your table should be *n* rows with *x* + *y* columns. In R, we primarily work with data in long format, which is typically a single row for an observation rather than a subject. 

## Variable selection
Prior to any data wrangling, we want to be clear what variables should be included in the table. When you are converting long tables into wide format, this is a crucial step. 

When generating clinical correlations, I like to think about three different types of variables: 
1. Grouping - analysis type, diagnosis, sex, subject ids, 
1. Response variables - there are interesting variables generated in the results
1. Clinical variables - these measures quantify a clinical dimension, i.e. IQ testing

Today, I feel it is much more convenient to have a single table which contains all of these variables even if they are across different analyses. That is the strength of the wide format. You should always be able to summarize the data in a single row per a particular subject.

## Reducing dimensionality of the data
Modern physiological data is often highly dimensional. For example, a typical EEG dataset contains a large number of channels and a large number of time points. However, when performing correlations, this high dimensionality is not necessary and can even be paralyzing. 

A single subject may have had resting EEG data collected with a 128-channel EEG net for 5-minutes. You can calculate several response variables from this data including spectral power. In this case you may have 7 frequency bands X 128 channels (7x128 = 896). How do you know which of the 896 values are the most important for your clinical correlations?

## Consider underlying reasons for selecting and reducing data
Having a scientific basis to your data is important - was the rest of your analysis concerned with a subset of electrodes in the frontal lobe examining alpha activity? In that case, you have now narrowed your possibilities to 20 channels x 1 frequency band (20 possibilities). At this point, if you are using each electrode as a replicate for significance testing, it would be a good idea to create a single value as the average of the 20 values. This now gets us to a single value per subject. 

## Returning to our dataset
Our present dataset consists of 5100 rows. This data is source localized so instead of electrode channels we have source atlas regions (but still have the column labelled `chan`). This value comes from 75 subjects X 68 atlas regions for a total of 5100 values. In this case, we have hypotheses which can guide our initial steps of reducing dimensionality.

```{r}
# Load the data
df <- read_csv("https://figshare.com/ndownloader/files/34554656") %>%
  mutate(eegid = factor(eegid))
# Review # of rows and columns
df
```

```
# A tibble: 5,100 × 46
    ...1 eegid chan    rejtrials stp_gamma stp_gamma1 stp_gamma2 stp_alpha
   <dbl> <fct> <chr>       <dbl>     <dbl>      <dbl>      <dbl>     <dbl>
 1     1 179   bankss…         0     -207.      -206.      -209.     -203.
 2     2 179   bankss…         0     -208.      -207.      -211.     -202.
 3     3 179   caudal…         0     -207.      -206.      -211.     -201.
 4     4 179   caudal…         0     -206.      -206.      -211.     -200.
 ```

## Selecting data based on our scientific hypothesis and analysis at large
Our main analysis is primarily interested in the frontal, temporal, and occipital regions. So, we will start by selecting our grouping and response variables and filtering the data based on our hypothesis. We will also use the `distinct` function to identify the unique values in the `chan` column. 

```{r}
# Reduce dimensionality 
# Reduce dimensionality
df.select <- df %>% filter(region %in% c("RF", "LF",
                                         "RT", "LT",
                                         "RO", "LO")) %>%
  select(eegid,
         group,
         sex,
         chan,
         region,
         starts_with(c("itc", "stp", "ersp",-contains("raw"))),
         -stp_gamma,
         -ersp_gamma,
         -itc40_og)

df.select %>% distinct(chan)
```
## The results of strategic filtering
```
# A tibble: 2,850 × 15
   eegid group sex   chan      region    itc40    itc80 itconset itcoffset
   <fct> <chr> <chr> <chr>     <chr>     <dbl>    <dbl>    <dbl>     <dbl>
 1 179   FXS   F     banksstsL LT      0.0100  -9.51e-3   0.0892   0.0104 
 2 179   FXS   F     banksstsR RT      0.0186   7.05e-4   0.0280   0.0138 
 3 179   FXS   F     caudalmi… LF      0.0761   1.21e-2   0.219    0.0403 

 # A tibble: 38 × 1
   chan                
   <chr>               
 1 banksstsL           
 2 banksstsR           
 3 caudalmiddlefrontalL
 ```

## Summarizing our data by averaging replicates
Though we have not technically reduced dimensionality (other than discarding some columns), we have reduced the number of rows in our data based on our scientific hypothesis. At this point, we are still interested in right and left sides, but less interested in the individual atlas nodes. So we can reduce dimensionality by treating nodes as replicates and averaging across regions.

```{r}
df.select.avg <- df.select %>% group_by(eegid, group, sex, region) %>% 
  summarize(across(.cols = where(is.numeric), .fns = mean))
```
```
# A tibble: 450 × 14
# Groups:   eegid, group, sex [75]
   eegid group sex   region   itc40    itc80 itconset itcoffset stp_gamma1
   <fct> <chr> <chr> <chr>    <dbl>    <dbl>    <dbl>     <dbl>      <dbl>
 1 179   FXS   F     LF     2.57e-2  2.89e-3   0.129    0.0302       -202.
 2 179   FXS   F     LO     5.95e-3 -3.93e-4   0.0482   0.0105       -202.
```
We now have a much more reasonable 450 rows which is composed of 75 subjects X 2 sides (right and left) and 3 regions (=450 rows). We also have 10 response variables of interest.

## A note about the clinical values we have left behind
What about our clinical variables? Once we have organized our response variables we will then rejoin our clinical variables to this table!

## Creating our "ideal" correlation table
We are now only a few steps away from creating a table with 75 rows which represent a single row of response variables for each subject. For this final step we will have to use a more advanced R function called `pivot_wider`.

## Using Pivot Wider

The `pivot_wider` function can reorientate a dataset so information rows can be "pivoted" to columns. This is useful for creating a table with a single row of response variables for each subject. It is much easier to see an example of this in action rather than try to explain it in detail!

## Consider where you want to go before using pivot_wider!
When I get lost in using pivot_wider, it is usually because of a lack of preparation. Prior to using pivot_wider you should know exactly what you want your final table to look like.

In our present dataset, what would be the ideal column structure? Let's look at what we are stating with. For this example, I am going to reduce the number of response variables to 2 for clarity.

```
> # Prototype for testing pivot_wider
> df.select.avg %>% select(eegid, group, sex, region, itc40, itc80)
# A tibble: 450 × 6
# Groups:   eegid, group, sex [75]
   eegid group sex   region    itc40     itc80
   <fct> <chr> <chr> <chr>     <dbl>     <dbl>
 1 179   FXS   F     LF     0.0257    0.00289 
 2 179   FXS   F     LO     0.00595  -0.000393
 3 179   FXS   F     LT     0.0145    0.00163 
 ```

 ## Imagining a "wide" table
 In this case, my final correlation table should retain each unique eegid which represents individual subjects. This also means any demographic grouping variables (group,sex) will come along for the ride since they are associated 1:1 with the eegid/subject. 

 However, to reduce my table to 75 rows I have to do something with the region column. Each region column is associated with a unique response variable. So, I will have to pivot the region column to a new column and under each column there will be a unique response variable.

 Let's see this in action before thinking too hard about how this would work!
 ```r
df.select.avg %>% select(eegid, group, sex, region, itc40, itc80) %>% pivot_wider(names_from = region, values_from = starts_with("itc"))
```
```
# A tibble: 75 × 15
# Groups:   eegid, group, sex [75]
   eegid group sex   itc40_LF itc40_LO itc40_LT itc40_RF itc40_RO itc40_RT
   <fct> <chr> <chr>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>
 1 179   FXS   F      0.0257  0.00595  0.0145    0.0224   0.00480  0.0167 
 2 199   TDC   M      0.00932 0.000846 0.00273   0.00940  0.0110   0.00890
 3 221   TDC   M     -0.00270 0.0134   0.0181    0.00695  0.0112   0.0141 
 ```
## Examining the pivot_wider results
Prior to discussing how to write the function, let's look at the results. First, notice tha we now have 75 rows each corresponding to an eegid/subject. The demographic grouping variables (group, sex) are still associated with every now. However, instead of 2 response variable columns, we now have a total of 12. These 12 include each of the two response variables combined with the 6 possible regions (LF, LO, LT, RF, RO, RT).

### Pivot_wider syntax and commentary
The pivot_wider function takes two arguments: `names_from` and `values_from`. The `names_from` argument is the column name that will be pivoted to a new column. The `values_from` argument is the column name that will be used to create the new column.

You can see why using this function is much easier when you have carefully prepared your dataset and you also can imagine what the final table should look like. For example, having an additional column such as atlas `chan` would have created 68 X 2 response variables. In this case our prototype code can now be used with all of the response variables and we can complete our response variable portion of the correlation table.

```r
# Full pivot wider 
df.wide.response <- df.select.avg %>% 
  pivot_wider(names_from = region, 
              values_from = starts_with(c("itc", "stp", "ersp")))
```
```
# A tibble: 75 × 63
# Groups:   eegid, group, sex [75]
   eegid group sex   itc40_LF itc40_LO itc40_LT itc40_RF itc40_RO itc40_RT
   <fct> <chr> <chr>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>
 1 179   FXS   F      0.0257  0.00595  0.0145    0.0224   0.00480  0.0167 
 2 199   TDC   M      0.00932 0.000846 0.00273   0.00940  0.0110   0.00890
 ```
Hopefully the current table dimensions now make sense. The 75 corresponds to the number of subjects. The 60 columns (not including eegid, group, and sex) are the 10 response variables x the 3 regions * 2 sides.

## Rejoining the clinical variables to complete our dataset for correlations
Though it would be possible to take the clinical variables along for the ride during this process, I don't think it is best practice. As datasets get increasingly larger, that would also mean for each row you would also have to "carry" a copy of the clinical variable (which is usually 1 per subject). Instead, it is far more efficient to keep your clinical measures in a separate table and then join them to the response variables after dimension reduction. 

However, in this case, we kept all of our variables together for convenience. So let's return to our original table and extract just the eegid (subject) and the clinical variables.

```r
# extract clinical variables
selectvars <- c(
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

df.wide.clinical <- df %>% select(eegid, selectvars) %>% distinct(eegid, .keep_all = TRUE)
```
```
# A tibble: 75 × 14
   eegid `Age at Visit` `Deviation IQ` `Non Verbal Z Sc…` `Verbal Z Score`
   <fct>          <dbl>          <dbl>              <dbl>            <dbl>
 1 179             18.1           91.4              -0.9             -0.25
 2 199             20.7           96.8               0.14            -0.57
 ```
### Store your clinical variables in a separate variable for quick access
A couple tutorial points - I do think keeping your clinical variables in a separate variables pays off - you can carry this variable list between scripts and use it within other function when trying to isolate your clinical variables. 

### The distinct command is a neat filter
After our `select` function using the distinct command to identify unique EEGIDs is an easy way of filtering out the duplicates. Unlike our original table where each response variable was unique based on the region, this particular table is composed of duplicate clinical values for each eegid.

## Joining and saving our data for later
Finally, let's use the join command to combine the clinical variables with the response variables. We should already know ahead of time how many rows (75) and columns (total of 76 with 3 grouping variables + 60 response variables + 13 clinical variables) we should have. 

```r
# join clinical variables with response variables
df.corr <- df.wide.response %>% left_join(df.wide.clinical)
# save data into a csv for later use
df.corr %>% write_csv(file = "figshare/srcchirp_forCorr.csv")
```
```
# A tibble: 75 × 76
# Groups:   eegid, group, sex [75]
   eegid group sex   itc40_LF itc40_LO itc40_LT itc40_RF itc40_RO itc40_RT
   <fct> <chr> <chr>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>
 1 179   FXS   F      0.0257  0.00595  0.0145    0.0224   0.00480  0.0167 
 2 199   TDC   M      0.00932 0.000846 0.00273   0.00940  0.0110   0.00890
 3 221   TDC   M     -0.00270 0.0134   0.0181    0.00695  0.0112   0.0141 
 4 232   TDC   M      0.00976 0.0296   0.00798   0.0222   0.0136   0.0284 
```
## Wrapping up
The CSV file created is suitable for most correlation functions and still allows you to subgroup data by your grouping variables (i.e. correlations only within a specific diagnosis). 

At the end of writing an R script, I like to clear my workspace and run the file to make sure it runs correctly. I will also copy the final output to Figshare where I can then retrieve it via URL to keep my code portable.

## What's next?
In the next tutorial we will conduct our actual correlation analysis!

