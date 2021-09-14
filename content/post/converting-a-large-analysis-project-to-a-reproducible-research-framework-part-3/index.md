---
title: Converting a Large Analysis Project to a Reproducible Research Framework Part 3
date: 2021-09-14T00:09:53.623Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## *How easy would it be to convert an existing large MATLAB/R project to using GNU Make?*

In these tutorials, we will find out together!

After Part 1 and Part 2, we have **Make** to automate both the creation of a manuscript and a MATLAB data model. In this lesson, we will continue to generate MATLAB code to expand our analysis.

I have an additional bonus for any neuroscientists out there. Through [Brainstorm](https://neuroimage.usc.edu/brainstorm/Introduction), we will automate the process of estimating the minimal norm estimate of scalp EEG data. We previously worked out the particular details of the analysis using the graphical interface; however, we can now replicate the analysis via a command line counterpart, permanently. This is a good example that many programs, even those with graphical interfaces, can be ultimately run through command line tools.

### Recounting what MATLAB assets we have available

* `matlab_00_common.m` which is common resource file
* `model_loadDataset.m` which creates a MAT file that includes information of EEG datasets
* **Makefile** with instructions to create `model_loadDataset.mat`

## Using a proxy target file in place of multiple targets

Tracking multiple target files from a single source file is strongly discouraged when using **Make**. Instead, a proxy file representing the target files has several advantages.

In the next section we will load 141 scalp EEG tracings and convert the data from 2-second regular epochs to continuous data. Rather than having 141 target files representing each conversion, it is much more efficient to generate a single file which confirms the code was a success.

A spreadsheet representing the path to each continuous file would be ideal, for example, if the conversion was successful. On the other hand if the process was unsuccessful, no file should be produced which tells **Make** something is wrong.

## Building our second data model

Let's create a second data model which will reshape the trial dimension of our EEG datasets and form continuous data suitable for import into brainstorm. 

Let's simplify this process by first creating a copy of model_loadDataset.m and opening it in the editor. Let's go through the necessary steps:

1. change the basename to 'toContinuous'
2. specify 'model_loadFile.mat' as a datafile to import