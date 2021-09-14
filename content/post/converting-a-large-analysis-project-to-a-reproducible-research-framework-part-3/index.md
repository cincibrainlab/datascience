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