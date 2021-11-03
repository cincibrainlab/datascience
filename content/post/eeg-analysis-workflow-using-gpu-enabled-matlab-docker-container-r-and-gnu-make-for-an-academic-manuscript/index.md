---
title: EEG Analysis Workflow using GPU-enabled Matlab Docker Container, R, and
  GNU Make for an Academic Manuscript
date: 2021-11-02T13:09:00.505Z
draft: false
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