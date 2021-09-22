---
title: Generating EEG Channel Covariance Matrices
date: 2021-09-22T12:31:03.027Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
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

% Fix random generator
  rng(1,'twister');

% First, generate simulated EEG data
  no_channels = 4;  no_samples = 1000;
  myEEG = rand(no_channels, no_samples);

% Second, manually create a channel covariance matrix
  cov_mat = (myEEG*myEEG')/(no_samples-1);

% The more commonly used mean-normalized covariance matrix
  myEEG_mc = myEEG - (sum(myEEG,2) / no_samples);
  cov_mat_mc = (myEEG_mc*myEEG_mc')/(no_samples-1);
  
% Compare with built-in MATLAB Function
  cov(myEEG_mc')
```

### Interpreting the Output

#### Mean-offset covariance matrix

```matlab
cov_mat =
    0.3343    0.2530    0.2542    0.2475
    0.2530    0.3407    0.2541    0.2515
    0.2542    0.2541    0.3413    0.2493
    0.2475    0.2515    0.2493    0.3285
```

#### Mean-centered covariance matrix

```matlab
cov_mat_mc =
    0.0838   -0.0005    0.0016   -0.0007
   -0.0005    0.0841   -0.0016    0.0004
    0.0016   -0.0016    0.0867   -0.0009
   -0.0007    0.0004   -0.0009    0.0827
```

Confirm that the covariance matrix is exactly a no_channels x no_channels square matrix. Each cell of this matrix contains a volume which represents the linear relationship of two channels.The covariance between the same variables equals variance, so, the diagonal shows the variance of each variable. If you want know more about the difference between variance and correlation check out this [link](https://www.countbayesie.com/blog/2015/2/21/variance-co-variance-and-correlation).

### Built-in cov() function in MATLAB

MATLAB's built-in function cov() will generate a mean-centered covariance matrix. In many applications, a mean-centered covariance matrix is preferred since the original units may vary between features. The EEG data we have in this case is all measured in microvolts. Cohen extends this discussion [here](https://arxiv.org/pdf/2104.12356.pdf) following equation 8.

MATLAB's cov() function does not have an option to turn off mean-centering. However, it is trivial to modify the Mathworks function so that you gain a deeper understanding of how it works. 

`edit cov`

Spend a moment to enjoy a piece of professional code and jump down to approximately line 154:
`xc
c = (xc' * xc) ./ denom;`

Most of the Mathworks teams' code consists of contingency checks, but the basic algorithm is identical. Select all (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V) into a new Document (Ctrl-N). Save the new function ("cov2.m") with the mean centering line commented out. Once the function is run, you will see the output matches the original square matrix.Most of the Mathworks teams' code consists of contingency checks, but the basic algorithm is identical. Select all (Ctrl-A), Copy (Ctrl-C), and Paste (Ctrl-V) into a new Document (Ctrl-N). Save the new function ("cov2.m") with the mean centering line commented out. Once the function is run, you will see the output matches the original square matrix.

`data = data-mean(data,2); % mean-center
S = data*data’ / (size(data,2)-1);`

> Minor notes #1: The denominator is usually designated as
> n for a population and n-1 for a sample. In practice, for
> EEG data in which greater than 10,000 samples are routine the
> difference between the two mathmatically is neglible. You could
> likely make a scientific argument either way, but I, like Cohen
> prefer just n.
>
> Minor note #2: It is crucial to check and double check the orientation
> of your matrix to avoid "silent" errors. In the MATLAB function
> the expectation is that columns are "feature" being measured and the
> rows represent the observations. EEG lab formated data is usually 
> the opposite, columns represent the observations from the time series.