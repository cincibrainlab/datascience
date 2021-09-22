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

The key data structure that allows for this type of multivariate analysis is the channel covariance matrix. It seems like a contradiction that we will be using sinusoidal filters on our data given our above criticism. In this case, however, our coupling measure will be calculated from the channel covariance matrix, not on the underlying waveform.

My first introduction to channel covariance matrix was overcomplicated, so let me present the shorthand in four logical steps:

1. A Pearson's correlation computes the linear relationship between two vectors of values between the bounds of 0 to 1.
2. EEG data is a series of channels each consisting of a vector of amplitude data. This data may be raw, filtered, or cleaned. 
3. A correlation matrix of EEG data would consist of a square matrix (channel by channel) and each table cell would contain the Pearson's correlation with the linear relationship between the pair of channel amplitudes. 
4. A covariance matrix is identical to the correlation matrix, but measure variance which is unbounded.

### Creating a covariance matrix in MATLAB

In this case, [googling](https://letmegooglethat.com/?q=how+to+create+an+EEG+channel+covariate+matrix%3F) how to create an EEG channel covariance matrix can lead to a road of pain. I would specifically refer you to Cohen's [general tutorial on GED](https://arxiv.org/pdf/2104.12356.pdf) and this blog post from [Towards Data Science](https://towardsdatascience.com/x%E1%B5%80x-covariance-correlation-and-cosine-matrices-d2230997fb7). Instead, let me walk you through an example in MATLAB.

```
% === Exploring channel covariance matrices ==================
% A channel covariance matrix encodes the linear relationship
% between all pairs of channels. The resulting matrix is a
% square matrix with a height/width of the number of channels.
% A covariance, unlike a correlation, is unbounded. Larger
% covariance values indicate the signal varies together.

% First, generate simulated EEG data
  no_channels = 4;  no_samples = 1000;
  myEEG = rand(no_channels, no_samples);

% Second, manually create a channel covariance matrix
  cov_mat = (myEEG*myEEG')/(no_samples-1);
  
% --- Interpreting the Output -------------------------------
% cov_mat =
%     0.3343    0.2530    0.2542    0.2475
%     0.2530    0.3407    0.2541    0.2515
%     0.2542    0.2541    0.3413    0.2493
%     0.2475    0.2515    0.2493    0.3285
```

### Interpreting the Output

`cov_mat =
    0.3343    0.2530    0.2542    0.2475
    0.2530    0.3407    0.2541    0.2515
    0.2542    0.2541    0.3413    0.2493
    0.2475    0.2515    0.2493    0.3285`

Confirm that the covariance matrix is exactly a no_channels x no_channels square matrix. Each cell of this matrix contains a volume which represents the linear relationship of two channels.The covariance between the same variables equals variance, so, the diagonal shows the variance of each variable. If you want know more about the difference between variance and correlation check out this [link](https://www.countbayesie.com/blog/2015/2/21/variance-co-variance-and-correlation).

### Built-in cov() function in MATLAB 

MATLAB's built-in function cov() will generate a mean-centered covariance matrix. In many applications, a mean-centered covariance matrix is preferred since the original units may vary between features. The EEG data we have in this case is all measured in microvolts. Cohen extends this discussion [here](https://arxiv.org/pdf/2104.12356.pdf) following equation 8.

MATLAB's cov() function does not have an option to turn off mean-centering. However, it is trivial to modify the Mathworks function so that you gain a deeper understanding of how it works. 

```edit cov```

Spend a moment to enjoy a piece of professional code and jump down to approximately line 154:

```xc = x - sum(x,1)./m;  % Remove mean
c = (xc' * xc) ./ denom;```

Most of the Mathworks teams' code consists of contingency checks, but the basic algorithm is identical. 



Select all (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V) into a new Document (Ctrl-N). Save the new function ("cov2.m") with the mean centering line commented out. Once the function is run, you will see the output matches the original square matrix.Most of the Mathworks teams' code consists of contingency checks, but the basic algorithm is identical. Select all (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V) into a new Document (Ctrl-N). Save the new function ("cov2.m") with the mean centering line commented out. Once the function is run, you will see the output matches the original square matrix.



I'm personally surprised that 

\--- ---------------------
Running the cov function in Matlab may be initially
discouraging. The input of the cov function should be a
matrix with the observations in rows and the channels
as columns. Therefore in MATLAB the transpose of the EEG signal (i.e.,
amplitude X channel) should be used in the cov() function.
The output of cov() is the correct dimension, channel no x channel_no,
however, the values have been normalized by subtracting th mean.'

Minor notes #1: The denominator is usually designated as
n for a population and n-1 for a sample. In practice, for
EEG data in which greater than 10,000 samples are routine the
difference between the two mathmatically is neglible. You could
likely make a scientific argument either way, but I, like Cohen
prefer just n.

Minor note #2: It is crucial to check and double check the orientation
of your matrix to avoid "silent" errors. In the MATLAB function
the expectation is that columns are "feature" being measured and the
rows represent the observations. EEG lab formated data is usually 
the opposite, columns represent the observations from the time series.