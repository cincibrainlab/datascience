---
title: Long EEG Results from 3D Matrices Using MATLAB and Melt
date: 2021-09-15T12:12:24.451Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## How do you take spectral power in a subject by frequency by channel array and make it into a long dataframe (spreadsheet) for analysis? 

Let me show you an easy and efficient method using R.

For years I have made CSV (or Excel) files from data structures the hard way. This usually involves creating a nested for loop, taking a 3d structure, and manually forming a "tidy" or long datatable. In a "tidy" output, only a single observation can exist on a row.