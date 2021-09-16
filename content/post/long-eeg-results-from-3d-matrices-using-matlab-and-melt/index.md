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

I have always made CSV (or Excel) files by hand from data structures. Usually, this involves creating a nested for loop, taking a 3D structure, and manually forming a "tidy" or long datatable. In a tidy output, each row can contain only one observation. 

There are merits to this approach. You can, for example, create a CSV in whichever way you like and combine datasets more easily. In contrast, this freedom also makes it difficult to reuse the code, often adding an additional step of data manipulation.

MATLAB and R can both be used independently to accomplish this approach 100%. Scientists tend, however, to generate data using MATLAB/Octave and then export those data to a statistical program. Even if you don't use R for statistics, the platform is highly flexible. You might be surprised to learn that I write this blog in RStudio? Or that you can easily create Word and Powerpoint files from scratch? Or that RStudio has a great visual Markdown editor?

In this tutorial I want to demonstrate how to take 3-dimensional EEG analysis results and efficiently convert the data to a long table. In this case, I will be exporting a table from MATLAB from the commonly used open source EEG software Brainstorm and then completing the process in R and forming a "tidy" table. 