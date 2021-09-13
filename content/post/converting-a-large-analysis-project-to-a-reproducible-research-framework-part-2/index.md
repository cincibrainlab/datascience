---
title: Converting a Large Analysis Project to a Reproducible Research Framework Part 2
date: 2021-09-13T18:40:55.994Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
## *How easy would it be to convert an existing large MATLAB/R project to using GNU Make?*

In these tutorials, we will find out together! 

Welcome to Part II where we will start converting individual MATLAB scripts into a series of scripts that can be automatically created using the **Make** utility.

In the last tutorial, we created a combined manuscript. This manuscript contains the roadmap for what assets to create (and their order) to create a reproducible research project.

## Automating MATLAB scripts

### It's all about targets and dependencies

The strategy for creating Make versions of MATLAB scripts remains similar to any other Make project. Focus on your target files and dependencies. Remember that each dependency must also be a target file unless it exists prior to your analysis.

For example, you might have a spreadsheet that contains clinical values and group assignments. This spreadsheet is an original asset that does not have a dependency. When you reference a Makefile, let's call it '`group_assignments.csv`', it must exist in your source folder to avoid getting an error. 

On the other hand, you might have to wrangle your group_assignments.csv to readable group labels and exclude certain subjects. In this case, you may opt to create a new file in the Build folder named "`validated_group_assigments.csv`'. Subsequent scripts will look for this file (rather than the original) so instructions on how to create ''`validated_group_assigments.csv`" from "`group_assigments.csv`" must be specified in the Makefile. It is also good practice as your original source files remain untouched.

### Start with data models, then move on to tables and figures

The number of figures and tables in any analysis is usually equal to or greater than the number of data models. We often present data models in many different ways to make our points clear.

It plays to the strength of the **Make** approach to create one or more data *models* and then use those models as dependencies in other data *models*, *figures*, and *tables*.