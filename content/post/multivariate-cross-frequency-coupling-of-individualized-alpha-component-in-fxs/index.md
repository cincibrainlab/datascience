---
title: Multivariate Cross Frequency Coupling of Individualized Alpha Component in FXS
subtitle: "Part 1: Rationale and Overview"
date: 2021-09-21T14:54:59.274Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## Introduction to gedCFC

The multivariate approach to cross frequency coupling offers several advantages to univariate (channel by channel) phase amplitude coupling especially on empirical data. See the method in the original publication developed by Michael X Cohen [here](https://elifesciences.org/articles/21792).

## Scientific Rationale

We decided to implement this method to answer several scientific questions to complete a manuscript. Cohen's other multivariate EEG technique, gedBounds, allowed us to identify coherent spatiotemporal components in a dataset of Fragile X patients (with matched controls). 

FXS is a single gene disorder and the most common form of inherited intellectual disability. FXS has a well-recognized EEG phenotype including decreased alpha power and increased gamma activity. We were interested in understanding how alpha activity varies in FXS from controls. Alpha is a key oscillatory rhythm and as it widely propagates through the brain it is thought to play a role in many physiological processes including attention, sensory gating, and cognition. 

### Altered spatiotemporal properties of alpha activity in FXS

We were able to identify an individualized alpha component (clustered around 10 Hz) for each subject. The mean extent of this component was similar to the canonical alpha band between groups, however, the distribution of these boundaries was altered in FXS. In males with FXS, who have minimal to no protein production, the alpha band lacked a distinctive "start" and "stop" rather than was inconsistent between individuals. Control males, on the other hand, had a distinctly marked alpha band with many individuals having "start" and "stop" points around 7 Hz and 12 hz respectively. In a separate finding, the average topography of this component, especially in males with FXS who have minimal protein production, has a significantly more anterior distribution than in controls. The power of the alpha component was shown to be significantly correlated with auditory attention, which is a neurosensory task studied in FXS.

### Incorporating gedCFC to examine functional connectivity of individualized alpha component in FXS

To complete this story, we were interested in examining cross frequency coupling (CFC) between the individualized alpha component and gamma activity. We hypothesized that anterior alpha activity would demonstrate altered CFC compared to controls. Given that multivariate analysis can incorporate spatial and temporal information, we wondered if an anterior focus of alpha activity would also change the focus of PAC. At a global level, PAC may represent functional connectivity of the brain and changes in the strength or distribution of PAC may affect behavior.

## Overview of GEDCFC

Before wading to the implementation of the GEDCFC technique, we will create some pseudocode and discuss a high level overview of the process. The history of phase amplitude coupling in EEG has a long and storied history and is not without it's [controversy](https://www.frontiersin.org/articles/10.3389/fncom.2016.00087/full). Many of the modern univariate techniques were derived from application from single channel ex vivo or invasive recording data and adapted to EEG data. 

### Broken assumptions about Neural Oscillations

One criticism, in particular, coincides with a [more nuanced view of neural oscillations](https://www.sciencedirect.com/science/article/abs/pii/S0959438816300769?via%3Dihub). It is becoming increasingly challenged that brain oscillations are in nature sinusoids with a stable frequency. Though I do not feel any neuroscientist ever considered this to be true, the use of sinusoidal narrowband filters in EEG processing introduced a potential bias to how we interpret data and code our analysis. The alternative view of viewing oscillatory activity as having value in the non-averaged form and examining spectral events, for example, has led to some breakthroughs in understanding biophysical processes such as [tactile discrimination](https://elifesciences.org/articles/29086). 

### Moving forward with novel techniques, slowly.

For high-resolution EEG, multivariate analysis affords an opportunity to leverage spatiotemporal data from multiple channels to increase signal to noise and disentangle source projections. To some degree, these techniques have been well validated in simulations and small empirical datasets. Clinical applications on large datasets, such as our intent here, will be needed to truly being to incorporate these techniques into diagnostic and therapeutic pipelines.

## Highest level overview of GEDCFC

Cohen describes his variation on gedCFC as follows: "Method 1 is designed for a situation in which the activity of one network fluctuates as a function of the phase of a lower-frequency network."

Reading between the lines:

> "Method 1 ..."

Cohen's insistence on transparency has been an exemplar to the field. He has provided his full methods with data (thus, [repex](https://swi-prolog.discourse.group/t/minimal-and-reproducible-working-examples/2447)) [here](mikexcohen.com/data).

> "...is designed for a situation..."

It is not trivial to really consider the underlying assumptions of this approach and support the use within a dataset.

> "...in which the activity of one network..."

The use of "network" here instead of channel is intentional. In a multivariate analysis the network consists of the pattern of activity simultaneously at all channels. 

> "fluctuates as a function of the phase of a lower-frequency network."

To tie together the previous point, a special case of a network is what Cohen's refers to as a component. The component is "formed by the weighted sum of all electrodes, that optimize the ratio between a user-specified minimization and maximization criteria [via GED}." 

### Compared to univariate PAC analysis

In a typical execution of a phase amplitude algorithm the input would be a pair of single channel time series. After extracting the phase series and amplitude envelope, the algorithm quantifies the relationship between the two. In this situation, the algorithm remains unaware that any more than two channels exist.

In contrast, the gedCFC method computes the phase/amplitude relationship between two defined networks which involves the totality of the activity at all channel pairs. But how?

## Introduction to the Channel Covariate Matrix

The key data structure that allows for this type of multivariate analysis is the channel covariance matrix. My first introduction to channel covariance matrix was overcomplicated, so let me present the shorthand in four logical steps:

1. A Pearson's correlation computes the linear relationship between two vectors of values between the bounds of 0 to 1.
2. EEG data is a series of channels each consisting of a vector of amplitude data. This data may be raw, filtered, or cleaned. 
3. A correlation matrix of EEG data would consist of a square matrix (channel by channel) and each cell would contain the Pearson's correlation with the linear relationship between the pair of channel amplitudes. 
4. A covariance matrix is identical to the correlation matrix, but measure variance which is unbounded.

In this case, [googling](https://letmegooglethat.com/?q=how+to+create+an+EEG+channel+covariate+matrix%3F) how to create an EEG channel covariance matrix can lead to a road of pain. Instead, let me walk you through a repEx in MATLAB.

```
% Goal create an EEG channel covariance matrix
% Generate fake EEG data
  no_channels = 64;
  no_samples = 10000;
  alices_EEG = rand(no_channels, no_samples);

% examine the size of the fake EEG data
  size(alices_EEG) % 64 x 1000
  
% 

```