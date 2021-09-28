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

### Creating CSV files are a time-honored art

I have always made CSV (or Excel) files by hand from data structures. Usually, this involves creating a nested for loop, taking a 3D structure, and manually forming a "tidy" or long datatable. In a tidy output, each row can contain only one observation. 

There are merits to this approach. You can, for example, create a CSV in whichever way you like and combine datasets more easily. In contrast, this freedom also makes it difficult to reuse the code, often adding an additional step of data manipulation.

## Do you separate data generation from statistics?

MATLAB and R can both be used independently to accomplish this approach. Scientists tend, however, to generate data using MATLAB/Octave and then export those data to a statistical program. Even if you don't use R for statistics, the platform is highly flexible. You might be surprised to learn that I write this blog in RStudio. Or that you can easily create Word and Powerpoint files from scratch. Or that RStudio has a great visual Markdown editor.

### What will we accomplish in this tutorial?

In this tutorial I want to demonstrate how to take 3-dimensional EEG analysis results and efficiently convert the data to a long table. In this case, I will be exporting a table from MATLAB from the commonly used open source EEG software Brainstorm and then completing the process in R and forming a "tidy" table.

### Would this be a good approach for you? File size!

If avoiding writing custom code is not enough of a positive for you, consider file size. Even after saving my EEG power results in a v6 mat file (R does not support v7.3) look at the file size difference with continuous FFT-style spectral power results:

#### First our humble CSV file:

> model_spectPowAbsFFT.csv
> 141 subjects, 128 channels, 500 frequency steps (0-250 Hz at .5 Hz steps)
> ~ 9 million observations with 4 variables
> 502 MB

#### Let's look at the original MAT:

> model_spectPowAbsFFT.mat
> contains 3D matrix of 141 subjects x 128 channels x 500 frequency steps
> row vector for subject labels
> row vector for channel labels
> row vector for frequency step labels
> 69 MB

### Let's compare the Apache Parquet format:

> model_spectPowAbsFFT.parquet
> direct save of dataframe/tibble of model_spectPowAbsFFT.csv
> 69 MB

#### Finally, maybe the most efficient format of all - the RData format:

> model_spectPowAbsFFT.RData
> direct save of dataframe/tibble of model_spectPowAbsFFT.csv
> 65 MB

### So the RData, MAT format or Parquet format takes up approximately less than 15% of size of the CSV table.

## Choosing the best data format for an efficient, reproducible workflow

For this use, I selected the MAT format given it's comparable efficiency, but also given the simplicity in terms of transferring data to R from MATLAB. The importance of simplicity in your code cannot be understated until you let your code "ripen" for several months and try to return to work.

### R.matlab package can import MAT files into R

The [R.matlab Package](https://github.com/HenrikBengtsson/R.matlab) is not regularly maintained but in this sense it is a finished product. It can easily important multidimensional MAT files into R. The one caveat is that you must save your MAT file on the MATLAB side using the '-v6' tag to make sure the format is compatible. There appears to be [complicating factors](https://github.com/HenrikBengtsson/R.matlab/issues/20) in updating the package to use the more modern '7.3' MAT format.