---
title: Topographic Plotting of EEG data in R
date: 2021-10-03T18:38:03.667Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## Have you wanted to plot 2D EEG topography in R? [Thanks to github user craddm you can!](https://github.com/craddm/eegUtils/)

To date, most of our publications topography figures have been created in MATLAB. The topographic images are either created with EEGLAB function (the venerable topoplot), Brainstorm, Cohen's modification of the topoplot, or for 3D views, Brainnet Viewer. 

With our recent interest in using MATLAB primarily for computation and R for visualization, I was happy to see great progress on EEG visualizations in R. What are the advantages? For one, having topographic features in dataframes allows for easy group averaging or modeling with other R functions. 

Today, we are going to do a brief tutorial on plotting an EEG measure on topography using the functions from the eegUtils package.

Overview of steps:

1. Have an example EEG file available for channel configuation (EEGLAB set preferred)
2. Have your data arranged into two columns: channel and value
3.