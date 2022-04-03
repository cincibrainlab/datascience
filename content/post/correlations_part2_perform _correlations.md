---
title: Deep Dive in Wavelet Thresholding for EEG cleaning
date: 2022-04-02
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
# New Methods for EEG Artifact Rejection 

It's been a while since we have revised our artifact rejection methods in our pipeline. Our lab primarily uses a semi-automated pipeline with ICA (Extended Infomax) for artifact cleaning of selected components. For resting state data we have also applied artifact subspace reconstruction.

There are growing criticisms of the use of ICA for EEG cleaning, especially when used to analyze event related potentials. There are a number of newer methods that use variations of ICA and several that fully replace ICA artifact cleaning. 

HAPPE2: Addition of Wavelet Thresholding
Recently the authors of the popular HAPPE pipeline have implemented wavelet thresholding as an ICA alternative in their major v.2 release. This method is a replacement for the wavelet ICA used in previous iterations. A preprint containing details of this approach for event-related data is available at <https://www.biorxiv.org/content/10.1101/2021.07.02.450946v1.full>.


## Hands on with Wavelet Thresholding
From the publication, wavelet thresholding (WT) offers impressive data cleaning and performance. The PINE lab runs WT against so-called "gold" standard methods including a manual approach. We wanted to spend some time with the code and examine how it would work on some our datasets.

## Parameterization - WT biggest weakness?
Though every EEG preprocessing step is parameterized, WT has a large number of parameters that can fundementally shape the final output. So an important part of this investigation is to consider different permutations of parameters to understand the effect on the final data.

# Datasets
For this initial post, I will be working out our testing methods using a strip of resting state data. Our current preprocessing pipeline is split into 4 stages:
1. import, filter, bad channels, average reference
2. continous cleaning / bad epoch removal
3. ICA
4. Component removal +/- final epoch check with amplitude thresholding

For our initial comparisons, I will be running WT on Pre-ICA data (after step 2). This will allow us the closest comparision to ICA cleaned vs. WT. To reduce file size and computation time, I will start with a 32-channel resting EEG from a trial I ran about 5 years ago. 

Dataset Link:
