---
title: "Easy Visualization of Massive Correlation Results with R: Basic Version"
subtitle: "R Shiny in 3 Levels: Basic, Publish, and Share"
date: 2021-12-28T14:52:32.383Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
# Easy Visualization of Correlation Results with R Shiny in 3 Levels: Basic, Publish, and Share
## Introduction: Basic, Publish, and Share Method
It isn't all that difficult to code R shiny applications if you already know how to program in R. My goal is to create an interactive application to organize and display a large collection of clinical correlations. 

My new format for these tutorials is dividing them into "basic", "publish", and "share" quality levels. Software tutorials are too easy to complicate. 
"Basic" - the minimal code to have a fully operational solution
"Publish" - modifications for publication-quality 
"Share" - modifications for other software developers or researchers to use
## Dataset
The tutorials I have seen online are examples but do not reflect the results professional scientists deal with on a daily basis. We will examine thousands of correlations between clinical variables and EEG measures in the dataset provided. The results are corrected for multiple comparisons (within their subgroups) and include age-corrected partial correlations. 
## Requirements
External Data (link here)
R environment
## Learning R Shiny
If you haven’t used R-Shiny before, run over the first few tutorial lessons from the official Shiny team. 
[https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/](https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/ "R Shiny Tutorials in Seven Steps")
## “Basic” Version
The application must 1) display correlation results and 2) plot a selected correlation result. 
### Summary of program UI and architectures
This project's variables are stored in a single RDATA file. The Shiny architecture has a “UI” for input and display and a “server” that performs any functions.
### Load data
```r
load("model_ClinicalCorrelations_revised.RData")
```
Let’s look at our key variables:
corr.rawdata - raw data for correlations in wide format (1 colunm per variable)
corr.results - master table of correlation results 
### Starting Code
```r
library(shiny)
library(DT)
library(tidyverse)

load("model_ClinicalCorrelations_revise.RData")
# Define UI for an application
ui <- fluidPage(
	# UI code here
)
# Define server logic
server <- function(input, output, session) {
	# Server code here
}
# Run the application 
shinyApp(ui = ui, server = server)
```
The DT package incorporates special Shiny components include an interactive data table object. 
### Display correlation results
To display the correlation table, add a dataTableOutput (not tableOutput) to the UI section of the code:
```r
ui <- fluidPage(
  # UI code here
  DT::DTOutput("corrResults")
)
```
To connect the data to the table, update the server code:
```r
server <- function(input, output, session) {
  # Server code here
  output$corrResults <- DT::renderDT({corr.results
  })
}
```
Click “Run App” to run the application in the web browser  to show the correlation results.
![](CleanShot%202021-12-26%20at%2012.50.59@2x.png)

### Enable user interaction to select a data row
Now that we have a visual representation of the data, we want to be able to select a row and plot the results. Each row contains the keys necessary to locate and pull the raw data to create a simple scatter plot.
First, add `selection='single'` to the renderDT expression so only one row is selected when the user clicks.
```r
server <- function(input, output, session) {
  # Server code here
  output$corrResults <- DT::renderDT({corr.results, selection='single'
  })
}
```
Second, add an `observe` block to monitor the user selection and gather the data from the row to prepare for a query from the raw data table (corr.rawdata). We will also add a print function to check if the row selection works.
```r
server <- function(input, output, session) {
  # Server code here
  output$corrResults <- DT::renderDT({datatable(corr.results, selection='single')})
  observe({
    req(input$corrResults_rows_selected)
    print(input$corrResults_rows_selected)})
}
```
Now, run the code and select a row. The row will be highlighted and in the R console, you will see the selected row number.
### Plot selected result
In the first step, we loaded and displayed a data table of the correlation results. Selecting a row of the data table will make that data available to your server. Each row contains the keys necessary to locate and pull the raw data to create a simple scatter plot.
#### Create a dataframe containing raw data for plotting
We were able to obtain the selected row of correlation results in the last step. To plot data, we need to make keys from each column. These keys can be used to filter and select raw data from the second table, `corr.rawdata`. Let’s update our SERVER code:
```r
 server <- function(input, output, session) {
    # Server code here
    output$corrResults <- DT::renderDT({datatable(corr.results, selection='single')})
    observe({
      req(input$corrResults_rows_selected)
      print(input$corrResults_rows_selected)
    
    selected_row_index = input$corrResults_rows_selected  
      
    # query matched raw data
    querydf <- corr.results %>% slice(selected_row_index)
    corrtype_sel  <- querydf$corrtype
    bandname_sel  <- querydf$bandname
    type_sel      <- querydf$type
    label_sel     <- querydf$label
    measure_sel      <- querydf$measure
    
    query_string <- str_c(c(corrtype_sel, bandname_sel, label_sel, type_sel) , collapse = "_")
    
    scatterdf <- corr.rawdata %>% select(all_of(measure_sel), all_of(query_string))
    })
  }
```

The correlation results were calculated within subgroups, whereas the raw data includes all participants. A participant may belong to more than one subgroup. In this data, we want all individuals with Fragile X Syndrome (group == “FXS”) but also male individuals with full mutation and no mosaicism with FXS (group == “FXS” AND mgroup == “M1”).  
To me, the most straightforward solution is to create a filter expression based on the group value and then use that expression when the scatterplot data is called. This requires a small modification:
```r
    # specify data subset
    filter_sel <- switch(group,
           "FXS" = quo(group == 'FXS'),
           "M1"  = quo(group == 'FXS' & mgroup == "M1"))
    
    # request data
    scatterdf <- corr.rawdata %>% 
      select(group, mgroup, all_of(measure_sel), all_of(query_string)) %>% 
      filter( !!(filter_sel) )
```
You might want to filter all FXS first and then use just the mgroup query, but this approach is much easier to read and troubleshoot. 
##### Code Hiighlights
* `quo` can be used to create an expression that can be evaluated in a `dplyr` function by the use of the “bang-bang” operator `!!`

#### Add a plot viewer 
Let’s update our UI code to include a plot object for our scatter plot as follows:
```r
# Define UI for application that draws a histogram
ui <- fluidPage(
  # UI code here
  DT::DTOutput("corrResults"),
  plotOutput("corrPlot")
)
```
Lets next create a simple scatter plot of the ywo colmns.
```r
 server <- function(input, output, session) {
    # Server code here
    output$corrResults <- DT::renderDT({datatable(corr.results, selection='single')})
    observe({
      req(input$corrResults_rows_selected)
      print(input$corrResults_rows_selected)
    
    selected_row_index = input$corrResults_rows_selected  
      
    # query matched raw data
    querydf <- corr.results %>% slice(selected_row_index)
    corrtype_sel  <- querydf$corrtype
    bandname_sel  <- querydf$bandname
    type_sel      <- querydf$type
    label_sel     <- querydf$label
    measure_sel      <- querydf$measure
    
    query_string <- str_c(c(corrtype_sel, bandname_sel, label_sel, type_sel) , collapse = "_")
    
    scatterdf <- corr.rawdata %>% select(all_of(measure_sel), all_of(query_string))
    
    output$corrPlot <- renderPlot({ 
      scatterdf %>% ggplot() + 
        geom_point(aes(x=get(measure_sel), y=get(query_string))) +
        ylab(measure_sel) + xlab(query_string) + theme_minimal() +
        theme(aspect.ratio = 1)
    })
    })
  }
```

##### Code highlights:
- the `stringR::str_c` function merges strings together with a delimiter (in this case underscore)
- `all_of()` allows the use of strings as variable names in filter
- `dplyr::get`function in the ggplot allows the use of strings as variable names in dplyr functions.
At this point, the key aspects of the basic application are complete. 
![](CleanShot%202021-12-26%20at%2015.11.42@2x.png)
To create a peer-reviewed manuscript-ready version of the code, we will modify it in the next tutorial.