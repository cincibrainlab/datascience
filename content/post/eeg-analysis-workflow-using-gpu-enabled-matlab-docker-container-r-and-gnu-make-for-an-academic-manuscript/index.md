---
title: EEG Analysis Workflow using GPU-enabled Matlab Docker Container, R, and
  GNU Make for an Academic Manuscript
date: 2021-11-02T13:09:00.505+00:00
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
The "containerization" of software platforms has made quickly setting up a high-performance, reproducible research workflow more feasible.

In this tutorial, we will be putting together the pieces on a full research workflow that incorporates multiple analysis platforms, but importantly, tied to the goal of a reproducible academic manuscript.

## Starting with the Manuscript

It is far too easy to get swamped into the "how" and "what" of complex analysis, rather than "why". Keeping your focus on the manuscript and abstract is the easiest way out of endless side paths and orphan results.

What do I mean "start with the manuscript"? I think the manuscript itself should correspond to you analysis code. Ideally, this should be as simple as identifying a figure or table you are interested in and finding the corresponding code with the identical caption.

In practice, this is extremely difficult because there is no single piece of code that represents a figure, table, or model. In the past, there are many ways to try to make things easier: make separate files with common prefixes, use comments within code, try to create a subfolder of code for a particular analysis. I have tried many methods, but ultimately, when you return back to your code several months later you find yourself quite lost. In the last few years, as we have incorporated other software into our analysis pipeline - let's say specialized MATLAB toolboxes, R, python, and older proprietary analysis software (CED Signal) this has become even more challenging!

## Why GNU Make matters

This is why GNU Make was created. To be clear, this is not an analogous situation that we are trying to shoehorn Make into - this is exactly the types of complex problems programmers in the 1980s were running into.

At its core, GNU make manages outputs and the dependencies that create these outputs. It is agnostic to *what* and *how* these outputs are created. It only acts based on the *outputs* that are created by other programs.

GNU Make is the conductor of the orchestra and never plays any of the instruments.

## GNU Make: The conductor needs a piece to play

The conductor (Make) always requires a piece of music to orchestrate. This is what makes Make different between computer science and academic neuroscience. In this case, we will orchestrate a scientific manuscript rather than a software application.

By making this mental shift, GNU can begin to orchestrate your manuscripts just as it manages the building of the most complex software applications in the world.

## The simplicity of the Makefile

If you use this approach, the Makefile becomes the *most* important file of your entire publication.

The Makefile controls 1) what analyses are performed, 2) what order the analyses are performed, 2) what outputs are necessary for the project.

It doesn't matter to Make if you have a raw data file from a EGI EEG amplifier, a power analysis in MATLAB (or Octave), and want to use SAS rather than R to create a final figure. Or if down the road you decide to add another analysis or modify a dataset.

It only cares that each step you have a set of input files and a defined output file that can serves as the input for other steps. And it makes sure that these instructions are followed exactly each time.

## Manually composing a scientific manuscript

For the sake of simplicity, let's focus on a real world example. I am currently revising a manuscript looking at results of a source localization analysis of a large dataset of subjects with Fragile X Syndrome compared with typically developing controls.

Consider the complexities of a modern scientific manuscript:

* preprocessing of datasets and source analysis take a multitude of steps across multiple MATLAB custom scripts and toolboxes
* Extract values for creation of numerical datasets for statistics
* Create summarize tables and model data in R
* Create figures from MATLAB and R
* Sync results, captions, and statistics with manuscript text
* Get all results and visualization "publication" ready

This process is daunting even for experienced scientists and with many complex steps comes the ever present worry of making errors.

## Orchestrating a manuscript through Make

Make doesn't take away any of the difficulty of coding a complex analysis or speeding up any actual analysis steps. In fact, Make should add a tiny bit of time to your workflow.

However, most practicing academics know the majority of their time isn't in creating the analysis, it's spent on verifying, delegating, testing, and picking up day after day the workflow. I would estimate 70% of my time is spent on redundancy - trying to pick up where to begin on manuscript A while trying to debug code in manuscript B. Spending hours working on a single analysis, but not having a clear idea of what the output should be. These delays are almost expected in the creation of a high-quality manuscript, but this also where Make has the greatest impact.

## The true impact of Make on productivity

Consider the fundamental goal of a Makefile is to force the author to think about inputs and outputs rather than the "weeds" of the process to get there. The complexity of the analysis is only reflected in the number of steps it takes to get an output.

### Simple Example: Demographics Table

Every clinical research manuscript has a summary different characteristics of participants. This is often the first Table. From a traditional view point, this workflow would include the raw clinical measure data, inclusion/exclusion, and summary variables.

The Makefile only needs the following information:

output: Table1_Demographics.docx

input: project_demographics_data.csv

recipe: R input output

Let's start by making a template of a block of Make instructions

```
# Sample Make Block Instructions
# Output
# Input
# Recipe
```

At the core, Make will repeat these blocks to create your final output.

### A more complex example: spectral power from neural sources

Let's start with the manuscript and construct in pseudocode our Make code blocks. From the manuscript:

> Researchers have previously observed disorder-specific distinct spatial patterns of abnormalities associated with TCD \[24]. Additionally, we hypothesized there would be differences across regional nodes in spectral power between FXS and TDC, and the in FXS the degree of these changes would be correlated with clinical measures of cognition, emotion, and sensory function.

Let's start with our final outputs first:

1. Figure: Correlation plot of node-based spectral power and clinical measures.
2. Table: Significant differences between FXS and controls in nodal spectral power.

Let's better understand the dependencies that these outputs rely on:

1. Data table containing spectral power for each subject by node and corresponding clinical measures for each subject.
2. A statistical model demonstrating overall effects of group on spectral power (by node) and associated lsmeans estimates to perform contrasts.

Let's continue our dependency tree to look for further inputs:

1. Spectral power involves a series of steps generated from current source density from the MNE model.
2. Clinical measures are obtained from a redcap database

Let's understand the "recipes" used to build these assets:

1. Matlab scripts to generate source model and generate spectral power data into a long table
2. R to import long data, calculate statistical model, and visualize results

Finally, let's put this together and "pencil" in our tentative plan to create our final assets. The Make file will help us orchestrate the plan into action!

To best represent these dependencies let's try to summarize in the following form:

```makefile
# Output File : Input Files
# Recipe (Commands)

# Generate source model and power from cleaned EEG data
Model_SourceEEGs.mat : Model_PostProcessEEGs.mat\
      MATLAB CreateSourceFromPostProcessEEGs.m

Model_PowerFromSourceEEGS.mat : Model_SourceEEGs.mat\
       Rscript CreatePowerFromSourceEEGs.m

# Spectral Power Statistical Comparison
Model_PowerComparison.RData : Model_PowerFromSourceEEGS.mat\
       Rscript ComparePowerFromSourceEEGs.m

Table_PowerComparision : Model_PowerComparison.RData
       Rscript Table_PowerComparision.R

Figure_PowerComparision : Model_PowerComparison.RData
       Rscript Figure_PowerComparision.R

# Spectral Power Clinical Correlations
Model_CorrelationPowerWithClinical.RData : Model_PowerFromSourceEEGS.mat Model_SubjectClinicalMeasures.csv\
       Rscript CorrelationPowerWithClinical.R

Figure_CorrelationPower.RData : Model_CorrelationPower.RData
       Rscript Figure_CorrelationPowerWithClinical.R

Table_CorrelationPower.RData : Model_CorrelationPower.RData
       Rscript Figure_CorrelationPowerWithClinical.R


```

The summary above is a blow-by-blow representation of each key step in the analysis. Notice that a single output from one step can be used by many other steps. These 30 lines of code are one of the single most efficient ways to communicate the process. Consider how many hundreds of lines of code these lines represent. Even if you were to excessively comment and document your process, what single file would you put the information? 

The convention of listing your output before you input is a Make convention. I think it is also helpful to think about the end goal of a number of inputs in this way. Notice that Make is truly agnostic to the underlying software or data structures. In the correlation section, we see a RData output and a MATLAB and CSV input. 

The instructions can be as simple as a running a preexisting script or any other command.

### Make keeps track of data and time of output and input files

The single most impressive and useful feature of Make is the ability to monitor when source files are updated and recreate ONLY the necessary outputs. Make always checks the time and date of your source (input) files to the expected output. If the input files are newer, it will re run the command. If the input files are older, it will generate a message tell you the outputs are "up to date". In general, there is one important difference from a real Make instruction file (called Makefile) and my summary above. In a true Makefile, you would place your recipe script as one of the inputs so Make would make sure to keep track of any updates.