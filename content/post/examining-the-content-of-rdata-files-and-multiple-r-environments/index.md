---
title: Examining the content of RData Files (and multiple R environments)
date: 2021-11-01T01:28:41.346Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## Want to see the contents of an RData file without modifying your current environment?

We've discussed the usefulness and efficiency of the RData structure in previous posts. Unlike a CSV file, the RData structure allows you to store multiple multidimensional variables in a single file. But what if you want to view the contents of these files later? 

Loading an RData file will add variables to your current R environment. In an existing project, you might want to just view the contents, but not load the variables which may overwrite other current environmental variables.

### R Environments

The solution? Open the RData file into a new "environment" within your current R environment. A R environment consists of all the objects (function, variables, etc.) which represents a virtual space. The environment that is loaded when you start and R project is known as the "Global" environment. You can check what environment you are in by running the `environment()` command.

### Loading the RData structure into a new environment

```ags
RDataFile <- "your_data_file.RData"

# Load RData file into new environemtn
load(file.path(RDataFile), new_environment <- new.env() )
  
 # List all of the variable names in RData:
ls(new_environment)


```

The new environment variable, new_environment, is essentially an object that contains all the structures within your RData file and can be accessed via typical R commands (i.e. $).

This code could easily be adapted into a GUI application for quick viewing of RData structures.