---
title: "Easy Visualization of Correlation Results with R: Publication-Ready!"
subtitle: " R Shiny in 3 Levels: Basic, Publish, and Share"
date: 2021-12-28T14:54:31.885Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
# Easy Visualization of Correlation Results with R Shiny in 3 Levels: Basic, Publish, and Share
## The next level: Publish
In the last lesson, we built a basic functional version of our correlation viewer application. In this application, you can view correlations in a large dataset, and when you select a row, a scatter plot of the data is displayed. This was accomplished with only a half-page of code, which shows how efficient Shiny can be for developing modern data applications.
To a scientist, "publication-ready" is a loaded term.  Publication-ready results require attention to every detail. 
The goals for this next level:
* curate data specific to the manuscript
* place correlation and age-adjusted correlations side by side
* total and precise control of formatting
* high-quality export for  figure panels
## Before you start
- external data file
- “Basic” application code
## Data Curation
There are more than 48,000 rows in the dataset, each representing a correlation result. There is only one row per observation (or result) of the data, so it is organized in a "tidy" manner. In other words, for the same subject, age-corrected correlations and bivariate Spearman correlations appear in separate rows. For data wrangling, the "tidy" format offers significant advantages, and it is relatively easy to "pivot" to a wide format.
Raw data, on the other hand, is presented as a rectangular "wide" table. There are separate columns for each result. A correlation calculation is generally done using this form of data. It is also an intuitive form of data for scatter plots.
### Step 1: Filter data
The long result table contains the results of several main groups of correlation analyses. Importantly, the p-values are adjusted for multiple comparisons for each main analysis and subgroup.
- *Major Analyses: Spectral Power, Peak Alpha Frequency, and Amplitude-Amplitude Coupling (AAC)
- *Cortical Node arrangement: Regional or Resting-State networks
- *Spectral Band: 7 frequency bands (delta, theta, alpha1,alpha2,gamma1,gamma2) for spectral power, not applicable for peak alpha frequency, and the lower frequency band (theta, alpha1, and alpha2) for gamma1 coupling for AAC
- *Groups: All Fragile X Syndrome (FXS)participants or Full-mutation, non-mosaic males with FXS only*
#### Create selector for main analyses
**Create radio buttons**
We will use radio button selectors to filter the main results. Let’s add the radio button elements first to the UI section to filter by main analysis, cortical node arrangement, and participant group.
```r
# Define UI for an application
ui <- fluidPage(
  # UI code here
  radioButtons("selectMain", h3("Select Main EEG Analysis"),
               choices = list("Spectral Power" = 1, 
                              "Peak Alpha Frequency" = 2,
                              "AAC" = 3),selected = 1),
  radioButtons("selectCortex", h3("Select Cortical Nodes"),
               choices = list("Regional" = 1, 
                              "RSN" = 2),selected = 1),
  radioButtons("selectGroup", h3("Select Subject Group"),
               choices = list("All FXS" = 1, 
                              "Males Only" = 2),
               selected = 1),
  DT::DTOutput("corrResults"),   # for result table
  plotOutput("corrPlot")         # for scatter plot
)
```
**Link radio buttons to data filter**
The next step is simplified if you consider each radio button a switch to toggle a single filter on and off. Every "switch" is represented by an expression that can be strung together to form a filter statement. I believe that this makes the code very readable and easily extensible for other UI objects in the future.
```r
    # specify data subset
    filter_sel_main <- switch(input$selectMain,
                              "pow" = quo(corrtype == 'pow'),
                              "paf" = quo(corrtype == 'paf'),
                              "aac" = quo(corrtype == 'aac'))
    
    filter_sel_corrtype <- switch(input$selectCortex,
                                  "region" = quo(type == 'region'),
                                  "RSN" = quo(type == 'RSN'))
    
    filter_sel_group <- switch(input$selectGroup,
                               "FXS" = quo(group == 'FXS'),
                               "M1" = quo(group == 'M1'))
    
    filter_sel_age <- switch(input$selectAge,
                             "simple" = quo(agecorr == FALSE),
                             "partial" = quo(agecorr == TRUE))   
    
    filter_sel_p <- switch(input$selectAlpha, 
                           "p5" = quo(p <= .05),
                           "p10" = quo(p <= .10), 
                           "fdr5" = quo(adjp <= .05),
                           "fdr10" = quo(adjp <= .10))  
```
##### The quo operator
Notice the use of the "quo" operator from the rlang library. When a function argument is "quoted", R doesn't return its value like it normally would but it returns the R expression describing how to make the value. This approach offers a high level of readability and transparency to the underlying filter operation.
#### Create a View Dataframe
Whenever you work with multiple datasets or change the number of rows in an original dataset, you have to be extremely careful not to misindex data. The Basic version of the application used the entire `corr.result` dataset to index a row and then create a lookup query for the raw data.
We are only displaying a subset of results in the Publish version, so the numerical row index will not match the original dataset. Likewise, any formatting changes to the filtered or original dataset (i.e., full labels for variable names or removing columns) will not produce identical lookup queries.
This problem can be solved by creating two derivative datasets from your original dataset. To set the number of rows correctly, first create a filtered data frame. Then, create a formatted version of the filtered table for visualization. 

```r
  # Combine radio box filters into a single command
    # This dataset (and # of rows) is used for operations
    filt.results <- corr.results %>% 
      filter( !!(filter_sel_main) & 
                !!(filter_sel_group) & 
                !!(filter_sel_corrtype) &
                !!(filter_sel_age) & 
                !!(filter_sel_p))
    # formatting of filtered data frame into a "view" dataframe
    view.results <- filt.results %>% select(measure, corrtype, bandname, label, n,r,p, adjp ) %>% 
      mutate(r = weights::rd(r,2),  # rounding
             p = pvl(p,3),
             adjp = pvl(adjp,3),
             measure = recode(measure, !!!(CLINICAL_LABELS)),
             bandname = ifelse(corrtype == "aac",
                               str_remove_all(bandname, "(relative-)|(absolute-)|(-gamma1)"), bandname)) %>%  # replace with labels
      select(-corrtype)  
    
    # Visualization refers to formatted "view" data frame
    output$corrResults <- DT::renderDT({datatable(view.results, selection='single')})
    
```
### Creating a residual plot to visualize partial correlations
Here, we have both simple correlations and age-corrected partial correlations. While simple correlations are straightforward to visualize (x vs. y), partial correlations require additional computation. Partial correlation between X and Y with respect to some other variable (Z) is the correlation of rX with rY, where rX and rY are residuals from two separate regression equations predicting X from Z and predicting Y from Z. The plot of these residuals allows us to visualize the relationship between X and Y. Since the plots are no longer in the original units, they are difficult to intuitively understand and are not commonly used in publications. Having an interactive method to compare the two scatter plots side-by-side, simple and corrected for age, can help reconcile these correlations.
Reference:
Moya-Laraño, Jordi, and Guadalupe Corcobado. "Plotting partial correlation and regression in ecological studies." Web Ecology 8.1 (2008): 35-46.
#### Adding partial correlation plot functionality
##### Creating a plot placeholder
Prior to adding any additional calculations, let’s create a space for this new plot by duplicating the current plot.  
Let’s add it first to the UI by creating two rows (`fluidRow()`). The first row contains the correlation result table. The second row is split 50/50 (`splitLayout()`) to display scatter plots side by side. We have also renamed the plots (`corrPlot_simple` and `corrPlot_partial`) to assign separate outputs. 
```r
    mainPanel(
      fluidRow( DT::DTOutput("corrResults") ),   # for result table
      fluidRow( splitLayout(cellWidths = c("50%", "50%"),
                            plotOutput("corrPlot_simple"),
                            plotOutput("corrPlot_partial"))
      )
```
Let’s update the server code to have two `ggplot()` objects assigned to each plot that we attach to the partial correlation in the next step.

##### Define a function to calculate residuals
Before the `fluidPage()` is defined, add a new function that runs a regression analysis and outputs residuals for each variable. It is a good idea to use the names of variables X, Y, and Z for readability. However, this requires renaming variable names in the input dataset. 
```r
regress <- function( df.partial ){
  df.partial %>% print()
  df.partial <- df.partial %>% drop_na()
  regress.XZ <- lm(X~Z, data=df.partial)
  regress.YZ <- lm(Y~Z, data=df.partial)
  
  residuals.XZ <- residuals(regress.XZ)
  residuals.YZ <- residuals(regress.YZ)
  
  df.residuals <- data.frame(residuals.XZ, residuals.YZ)
}
```
##### Calculating residuals to create partial correlation plot
The input data for the partial correlation includes the two variables of interest (X and Y) and a third controlling variable (Z).  In the server block, we create a new data frame that contains X, Y, Z and calls the function to perform the regression. The residuals that result from this calculation can be plotted . 
There is a conditional wrapper around this section to avoid and error when the user picks a correlation that includes visitage as the simple correlation. 
```r
    output$corrPlot_partial <- renderPlot({ })
    
	if(measure_sel != "visitage"){
      
      # pull data for partial correlation / residual plot
      regressdf <- corr.rawdata %>% 
        select(group, mgroup, visitage, all_of(measure_sel), all_of(query_string)) %>% 
        filter( !!(filter_sel) )  %>%  
        rename(X := !!query_string, Y := !!measure_sel, Z = visitage)
      
      # get residuals for plotting
      df.residuals <- regress(regressdf)
      
      output$corrPlot_partial <- renderPlot({ 
        df.residuals %>% ggplot(aes(x=residuals.XZ, y=residuals.YZ)) + 
          geom_point() +
          stat_quantile(quantiles =0.5) +
          ylab(measure_sel_label) + xlab(query_string) + theme_minimal() +
          theme(aspect.ratio = 1)
      })
    }
```

### Wrapping up the Publish version of the code
The key features of this version of the application are about complete. Our final focus will be on formatting and export functions. Let’s work through these final details.

#### Adding a title element
Let’s add an application title right after the start of the UI element:
```r
ui <- fluidPage(
  # UI code here
  # Application title  
  titlePanel("EEG Clinical Correlation Review"),
  p("Neocortical Localization and Thalamocortical Modulation of Neuronal Hyperexcitability in Fragile X Syndrome"),
```
#### Format Results Table
##### Format p-valuess
Let’s add a helper function, `pvl()` to format p-values at the beginning of the code modified from dmarginean/aqua package.
```r
# P formatting https://rdrr.io/github/dmarginean/aqua/src/R/general.R
pvl <- function(x, signif = 4) {
  ifelse(abs(x) < 10^(0 - signif),
         paste0("<0.", paste0(rep("0", signif - 1), collapse = ""), 1, collapse = ""),
         sub(x = format(round(x, signif), scientific = FALSE),
             pattern = "0+$", replacement = ""))}


```
##### Rename column headings
After adding the p-value format function, let’s also format the column names on the main result table added to the `view.results` code block in the server section.
##### Clean-up irrelevant headings (string editing)
We also removed "relative" and "absolute" from the `bandname` field as well as "gamma1" for AAC results for a cleaner look.  `stringR::str_remove_all` function, which uses regular expressions (regex), makes this simple. A conditional statement is used to only perform this operation on the AAC correlation type. In order to hide the `corrtype` variable from view, it is removed following the operation.
Here is the updated code for the results table:
```r
    # formatting of filtered data frame into a "view" dataframe
    view.results <- filt.results %>% select(measure, corrtype, bandname, label, n,r,p, adjp ) %>% 
      mutate(r = weights::rd(r,2),  # rounding
             p = pvl(p,3),
             adjp = pvl(adjp,3),
             measure = recode(measure, !!!(CLINICAL_LABELS)),
             bandname = ifelse(corrtype == "aac",
                               str_remove_all(bandname, "(relative-)|(absolute-)|(-gamma1)"), bandname)) %>%  # replace with labels
      select(-corrtype) %>% rename(Measure=measure, Frequency=bandname, Location=label, adj.p=adjp) 
```

#### Create correlation result label
For each plot, we will create a string that will show the Spearman’s rank correlation. 
Per APA formatting:
- Round the p-value to three decimal places.
- Round the value for r to two decimal places.
- Drop the leading 0 for the p-value and r (e.g. use .77, not 0.77)
- The degrees of freedom (df) is calculated as N – 2.
We will also create a plot title that takes the information we previously used as the lookup query for the raw data.
```r
    # Create APA style label for correlation results (r(23) = .57, p = .039)
    corr_simple_apa <- paste0("r(",querydf$n-2,") = ", weights::rd(querydf$r,2),", p = ", pvl(querydf$p,3))
    corr_simple_apa %>%  print()
    corr_partial_apa <- "N/A"
```
And for the partial correlation (if result is not age):
```r
    if(measure_sel != "visitage"){
      
      # Get age-corrected correlation result
      querydf.age <- corr.results %>% 
        filter( group == group_sel & agecorr == TRUE & corrtype == corrtype_sel &
                  bandname == bandname_sel & label == label_sel & type == type_sel &
                  measure == measure_sel)
      corr_simple_partial <- paste0("partial r(",querydf.age$n-2,") = ", weights::rd(querydf.age$r,2),", p = ", pvl(querydf.age$p,3))
      corr_simple_partial %>%  print()
```
#### Create chart titles
Let’s create dynamic axis labels for simple and partial plots:
```r
# Dynamic Axis Labels (Simple)
corr_x_lab <- switch(corrtype_sel, "pow"="Relative Power",
                         "paf" = "Frequency (Hz)",
                         "aac" = "AAC Coefficent")
    
corr_y_label <- measure_sel_label
    
if(measure_sel != "visitage"){
      
# Dynamic Axis Labels (Partial)
corr_x_lab_age <- switch(corrtype_sel, 
  "pow"="Relative Power | Age (Residuals)",
  "paf" = "Frequency (Hz) | Age (Residuals)",
  "aac" = "AAC Coefficent | Age (Residuals)")
corr_y_lab_age <- paste(corr_y_label,"| Age (Residuals)")
```
#### Update scatter plots with labels
```r
# Simple correlation plot  
p.simple <-  scatterdf %>% ggplot(aes(x=get(query_string), y=get(measure_sel))) + 
      geom_point(size=3) +
      stat_quantile(quantiles =0.5) +
      ylab(corr_y_label) + xlab(corr_x_lab) + 
      ggtitle(corr_simple_apa) +
      theme_Publication() +
      theme(aspect.ratio = 1)
# Partial correlation plot
p.partial <- df.residuals %>% ggplot(aes(x=residuals.XZ, y=residuals.YZ)) + 
        geom_point(size=3) +
        stat_quantile(quantiles =0.5) + 
        ggtitle(corr_simple_apa) +
        ylab(corr_y_lab_age) + xlab(corr_x_lab_age) + theme_Publication() +
        theme(aspect.ratio = 1)
      
```
#### Add theme to plots
I am a fan of minimal decoration on my graphs. I used to use the minimal theme, but the [https://github.com/koundy/ggplot\_theme\_Publication](https://github.com/koundy/ggplot_theme_Publication) Koundy’s `theme_Publication`is excellent as a base. 

#### Remove age-correction UI component
The age-correction selector is no longer necessary since we plot the results side by side. So let’s change that to a simple toggle to view age correlations or not. This is a good example how writing the code flexibly by using the `quo` expressions can really make large changes like this pretty simple. Here is the entire completed code:
```r
library(shiny)
library(DT)
library(tidyverse)
library(rsconnect)
library(ggthemes)

load("model_ClinicalCorrelations_revise.RData")

# Publication Theme
# https://github.com/koundy/ggplot_theme_Publication
source("https://bit.ly/3lgsJ4e") # theme publication

# P formatting https://rdrr.io/github/dmarginean/aqua/src/R/general.R
pvl <- function(x, signif = 4) {
  ifelse(abs(x) < 10^(0 - signif),
         paste0("<0.", paste0(rep("0", signif - 1), collapse = ""), 1, collapse = ""),
         sub(x = format(round(x, signif), scientific = FALSE),
             pattern = "0+$", replacement = ""))}

regress <- function( df.partial ){
  #df.partial %>% print()
  df.partial <- df.partial %>% drop_na()
  regress.XZ <- lm(X~Z, data=df.partial)
  regress.YZ <- lm(Y~Z, data=df.partial)
  
  residuals.XZ <- residuals(regress.XZ)
  residuals.YZ <- residuals(regress.YZ)
  
  df.residuals <- data.frame(residuals.XZ, residuals.YZ)
  
}

# Define UI for an application
ui <- fluidPage(
  # UI code here
  # Application title
  titlePanel("EEG Clinical Correlation Review"),
  h5("Neocortical Localization and Thalamocortical Modulation of Neuronal Hyperexcitability in Fragile X Syndrome"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("selectMain", h3("Main EEG Analysis"),
                   choices = list("Spectral Power" = "pow", 
                                  "Peak Alpha Frequency" = "paf",
                                  "AAC Gamma1 (Relative)" = "aac_rel",
                                  "AAC Gamma1 (Absolute)" = "aac_abs"), selected = "pow"),
      radioButtons("selectCortex", h3("Select Cortical Nodes"),
                   choices = list("Regional" = "region", 
                                  "RSN" = "RSN"), selected = "region"),
      radioButtons("selectGroup", h3("Select Subject Group"),
                   choices = list("All FXS" = "FXS", 
                                  "Full Mutation (Non-mosaic) Males Only" = 'M1'),
                   selected = "FXS"),
      # radioButtons("selectAge", h3("Age-corrected"),
      #              choices = list("False" = "simple", 
      #                             "True" = 'partial'),
      #              selected = "simple"),
      radioButtons("selectAgeView", h3("View age correlations?"),
                   choices = list("False" = "HideAge",
                                  "True" = 'ShowAge'),
                   selected = "HideAge"),
      radioButtons("selectAlpha", h3("Statistics"),
                   choices = list("p <= .05" = "p5", 
                                  "p <= .10" = 'p10',
                                  "FDR p < .05" = "fdr5", 
                                  "FDR p < .10" = 'fdr10'),
                   selected = "fdr5"),
      downloadButton('downloadPlot','Download Plot')),
    mainPanel(
      fluidRow( DT::DTOutput("corrResults") ),   # for result table
      fluidRow( splitLayout(cellWidths = c("50%", "50%"),
                            plotOutput("corrPlot_simple"),
                            plotOutput("corrPlot_partial"))
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Server code here
  
  view.results <- corr.results
  # select(group, corrtype, measure, bandname, label, type, r, p, adjp, n)
  

  observe({
    # specify data subset
    filter_sel_main <- switch(input$selectMain,
                              "pow" = quo(corrtype == 'pow'),
                              "paf" = quo(corrtype == 'paf'),
                              "aac_rel" = quo(corrtype == 'aac' & str_detect(bandname, "relative")),
                              "aac_abs" = quo(corrtype == 'aac' & str_detect(bandname, "absolute")))
    
    filter_sel_corrtype <- switch(input$selectCortex,
                                  "region" = quo(type == 'region'),
                                  "RSN" = quo(type == 'RSN'))
    
    filter_sel_group <- switch(input$selectGroup,
                               "FXS" = quo(group == 'FXS'),
                               "M1" = quo(group == 'M1'))
    filter_sel_age    <- switch(input$selectAgeView,
                               "ShowAge" = quo(agecorr == FALSE),
                               "HideAge" = quo(agecorr == FALSE & measure != 'visitage'))
    
    # filter_sel_age <- switch(input$selectAge,
    #                          "simple" = quo(agecorr == FALSE),
    #                          "partial" = quo(agecorr == TRUE))
    
    filter_sel_p <- switch(input$selectAlpha, 
                           "p5" = quo(p <= .05),
                           "p10" = quo(p <= .10), 
                           "fdr5" = quo(adjp <= .05),
                           "fdr10" = quo(adjp <= .10))   

    # Combine radio box filters into a single command
    # This dataset (and # of rows) is used for operations
    filt.results <- corr.results %>% 
      filter( !!(filter_sel_main) & 
                !!(filter_sel_group) & 
                !!(filter_sel_corrtype) &
                !!(filter_sel_age) & 
                !!(filter_sel_p))
    
    # formatting of filtered data frame into a "view" dataframe
    view.results <- filt.results %>% select(measure, corrtype, bandname, label, n,r,p, adjp ) %>% 
      mutate(r = weights::rd(r,2),  # rounding
             p = pvl(p,3),
             adjp = pvl(adjp,3),
             measure = recode(measure, !!!(CLINICAL_LABELS)),
             bandname = ifelse(corrtype == "aac",
                               str_remove_all(bandname, "(relative-)|(absolute-)|(-gamma1)"), bandname)) %>%  # replace with labels
      select(-corrtype) %>% rename(Measure=measure, Frequency=bandname, Location=label, adj.p=adjp) 
    
    # Visualization refers to formatted "view" data frame
    output$corrResults <- DT::renderDT({datatable(view.results, selection='single')})
    
    req(input$corrResults_rows_selected)
    
    selected_row_index = input$corrResults_rows_selected  
    
    # query matched raw data
    querydf <- filt.results %>% slice(selected_row_index)
    corrtype_sel  <- querydf$corrtype
    bandname_sel  <- querydf$bandname
    type_sel      <- querydf$type
    label_sel     <- querydf$label
    measure_sel      <- querydf$measure
    group_sel         <- querydf$group
    
    query_string <- str_c(c(corrtype_sel, bandname_sel, label_sel, type_sel) , collapse = "_")
    
    # Create APA style label for correlation results (r(23) = .57, p = .039)
    corr_simple_apa <- paste0("r(",querydf$n-2,") = ", weights::rd(querydf$r,2),", p = ", pvl(querydf$p,3))
    corr_simple_apa %>%  print()
    corr_partial_apa <- "N/A"
    
    # specify data subset
    filter_sel <- switch(group_sel,
                         "FXS" = quo(group == 'FXS'),
                         "M1"  = quo(group == 'FXS' & mgroup == "M1"))
    
    # pull data for scatter plot
    scatterdf <- corr.rawdata %>% 
      select(group, subgroup, mgroup, all_of(measure_sel), all_of(query_string)) %>% 
      filter( !!(filter_sel) )

      #df.residuals %>% head() %>% print()
    
    # add labels
    measure_sel_label <-  recode(measure_sel, !!!(CLINICAL_LABELS))
    
    # Dynamic Axis Labels (Simple)
    corr_x_lab <- switch(corrtype_sel, "pow"=paste("Relative",bandname_sel %>% str_to_title(),label_sel,"Power"),
                         "paf" = paste0("Peak Alpha Frequency (Hz) of", label_sel),
                         "aac" = paste(bandname_sel, label_sel, "AAC Coefficent"))
    corr_y_label <- measure_sel_label
    
    #query_string %>% print()
    
    p.simple <-  scatterdf %>% ggplot(aes(x=get(query_string), y=get(measure_sel))) +
      stat_quantile(aes(x=get(query_string), y=get(measure_sel)), quantiles =0.5) +
      geom_point(size=5, fill="darkgray",color="black", shape=21) +
      ylab(corr_y_label) + xlab(corr_x_lab) +
      ggtitle(corr_simple_apa) +
      theme_Publication() +
      theme(aspect.ratio = 1)
    
    p.combine <- ggpubr::ggarrange(p.simple, ncol=1)
    
    output$corrPlot_partial <- renderPlot({ })
    measure_sel %>% print()
    if(measure_sel != "visitage"){
      
      # Dynamic Axis Labels (Partial)
      corr_x_lab_age <- switch(corrtype_sel, 
                               "pow"=paste("Relative",bandname_sel %>% str_to_title(),label_sel,"| Age (Residuals)"),
                               "paf" = paste0("Peak Alpha Frequency (Hz) of", label_sel,  " | Age (Residuals)"),
                               "aac" = paste(bandname_sel, label_sel, "AAC Coefficent | Age (Residuals)"))
      corr_y_lab_age <- paste(corr_y_label,"| Age (Residuals)")
      
      # Get age-corrected correlation result
      querydf.age <- corr.results %>% 
        filter( group == group_sel & agecorr == TRUE & corrtype == corrtype_sel &
                  bandname == bandname_sel & label == label_sel & type == type_sel &
                  measure == measure_sel)
      corr_partial_apa <- paste0("partial r(",querydf.age$n-2,") = ", 
                                    weights::rd(querydf.age$r,2),", p = ", 
                                    pvl(querydf.age$p,3))
      
      # pull data for partial correlation / residual plot
      regressdf <- corr.rawdata %>% 
        select(group, subgroup, mgroup, visitage, all_of(measure_sel), all_of(query_string)) %>% 
        filter( !!(filter_sel) )  %>%  
        rename(X := !!query_string, Y := !!measure_sel, Z = visitage)
      
      # regressdf %>% print()
      
      # get residuals for plotting
      df.residuals <- regress(regressdf)
      #corr_partial_apa %>% print()
      # df.residuals %>%  names()
      
      p.partial <- df.residuals %>% ggplot(aes(x=residuals.XZ, y=residuals.YZ)) +
        geom_point(size=5, fill="darkgray",color="black", shape=21) +
        stat_quantile(quantiles =0.5) +
        ggtitle(corr_partial_apa) +
        ylab(corr_y_lab_age) + xlab(corr_x_lab_age) + theme_Publication() +
        theme(aspect.ratio = 1)

      output$corrPlot_partial <- renderPlot({ p.partial })
      
      p.combine <- ggpubr::ggarrange(p.simple, p.partial, ncol=2)
    }
    
    p.combine <- p.combine +
      theme(text = element_text(size=18),
            axis.text = element_text(size=18))
    
    output$corrPlot_simple <- renderPlot({ p.simple })
    
    output$downloadPlot <- downloadHandler(
      filename = function(){paste0(measure_sel," ",query_string,'.pdf',sep='')},
      content = function(file){
        ggsave(file,plot=p.combine)
      })
    
    
    
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
```

Stay tune for Part III on edits to share the code including creating a combined partial-simple correlation table and deployment to the web.
