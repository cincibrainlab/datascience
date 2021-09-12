---
title: Converting a Large Analysis Project to a Reproducible Research Framework
subtitle: ""
date: 2021-09-12T22:47:00.093Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
*How easy would it be to convert an existing large MATLAB/R project to using GNU Make?*

In these tutorials, we will find out together! 

## Why convert an existing analysis project?

We recently began a revise and resubmit of our [EEG source localization preprint](https://www.medrxiv.org/content/10.1101/2021.05.12.21256925v1) to Communications Biology. This revision required new analyses and substantial changes to the manuscript. 

Though our previous code and datasets were sharable, they required extensive hands-on operation to reproduce our results. In 2020, I felt this code base was amazingly modular. 

Today in late 2021, having designed the [repMake](https://github.com/cincibrainlab/repmake) framework what could compete with:

```shell
make manuscript
```

## Overview of the entire process

The focus of the process should be on the manuscript, not the analysis code itself. This is minor distinction but I feel makes a big difference in the execution of working with a large research project. It is far too easy to get caught up in the minutia *how* to write something rather than *what* is actually for. 

### Steps to create a REProducible MAKE Manuscript:

1. Split manuscript into individual sections
2. Identify data models, tables, and figures that need corresponding scripts
3. Create a common function file and a master caption file
4. Start with transition code to construct each data model
5. Write code for each table and figure
6. Compile manuscript using Make

This process will be overly difficult because of how we programmed our initial analysis. The MATLAB code required the use of a graphical user interface (GUI) and the R code similarly required an open R Studio session. In the revision, we will streamline this code to be entirely run from the command line. 

In our development process, the GUI still plays a crucial role. Using a GUI to recreate an analysis once it has been finalized, however, can lead to errors. In a GUI, settings or parameters must be entered manually. Alternatively, by converting your final code into a command line script, every parameter and modification must be recorded. This transparency is *[crucial to reproducibility](https://ropensci.github.io/reproducibility-guide/sections/introduction/)*. 

## Design Principals of the RepMake Conversion

Instead of having a single script for each manuscript asset, we coded our analysis by topic. At the time, this seemed efficient, but wading through the code nearly a year later has been challenging! When coding large, multipurpose scripts there are too many "what was I thinking when I wrote this" or "what else did this script do". Indeed, if the authors of the scripts feel this way, imagine how the public would feel!

In our revision:

1. One script = One manuscript asset
2. Each script should be able to run as a standalone command
3. MATLAB or R scripts should clearly list inputs and outputs
4. The main manuscript and supplement including all tables and figures should be able to be built from the source EEG files.

The last point may seem like a tall order, however, this is exactly what GNU Make was designed for. Remember, Make is only interested in the *filenames* and the *date/time* they were modified. In this way, Make is application agnostic - if you can build it, Make can use it!