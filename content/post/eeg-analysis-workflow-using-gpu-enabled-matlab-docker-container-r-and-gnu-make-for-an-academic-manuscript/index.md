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

## Orchestrating a scientific manuscript

For the sake of simplicity, let's focus on developing a Makefile for the