---
title: Importance of Double Precision on Manipulations of EEG Data
date: 2021-09-30T23:52:37.620Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## Silent type conversion of double data into single data may lead to data errors.

Single precision numbers range from 2^(-126) to 2^(+127). Double precision numbers range from a whopping 2^(-1022) to 2^(+1023). Though it is true you may never explicitly use this precision in calculations, internal calculations by algorithms may lead to subtle rounding.

In multivariate analysis using[ generalized eigenvalue decomposition (GED)](https://arxiv.org/pdf/2104.12356) the wrong precision can lead to unpredictable results.

A single precision EEG data matrix may result in complex numbers after GED. 

```
 [evecs,evals] = eig(cov(sFilt',1),cov(tmpdat',1));
  0.0039840 + 0.0000000i -0.0042783 + 0.0000000i -0.0056073 + 0.0000000i
 -0.0411496 + 0.0000000i  0.0410591 + 0.0000000i  0.0542667 + 0.0000000i
 -0.0729072 + 0.0000000i  0.0734129 + 0.0000000i  0.0926257 + 0.0000000i
 class(evecs)
 ans =

    'single'
```

This particular output is even more perplexing as the class of the variable is single, not complex but the display shows a complex portion. Later, during a topographic plotting function the script will crash.

## Stealth transformation of double data into single data by common housekeeping functions

Most readers of this blog will no doubt be familiar with the importance of double precision calculations, but what may surprise you is that many common EEG housekeeping functions may stealth return your data matrix back to single precision.

For example, after several hours of troubleshooting I identified two common EEGLAB housekeeping functions:

`eeg_checkset `and `eeg_select `returning a single precision EEG.data matrix after an input of a double precision data matrix.

```
>> EEG.data = double(EEG.data);
>> EEG = eeg_checkset(EEG);
>> class(EEG.data)
ans =
    'single'
```

These silent conversions led to downstream calculations that ultimately led to reduced precision in my channel covariance matrixes.

## Conclusion: Be wary when passing data through "shelf" functions when precision matters.

Consider when sharing code to include an assert statement, as below, prior to calculations that require double precision.

```
assert(strcmp(class(EEG.data), 'double'), 'Error: Computation requires double precision of EEG data matrix.')
Error: Computation requires double precision of EEG data matrix.

```