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

## Step 1: Edit a common Matlab file that stores shared paths, variables, and functions. 

Functional programming languages like Matlab can be a joy and pain to work with. In particular, Matlab is highly dependent on specifying particular paths to the files you want to include in your project. In addition, given Matlab's relatively enormous overhead, you want to reduce the duplication of code as much as possible.

We have included a file matlab_00_common.m to serve as a common include file in each of your Malab scripts. Why the odd name? Matlab has very[ specific naming conventions](https://www.mathworks.com/help/simulink/mdl_gd/hi/naming-considerations.html) for files! If you name your file something different, just update the beginning of each of your scripts. In fact, in a complex analysis having more than one possible include file may increase your flexibility and increase the efficiency of your code.

Also, remember that we will be using Matlab both through the GUI for development and also running it from the command line for efficiency.  This forces us to write code that is both compatible by running line by line but also can run the entire file at once. Different users have various advice on how to accomplish this, but in our research we have one method that seems to work well in almost every situation.

The template is to create an Matlab script file ("m") that contains the code to create your environment as well as a main function of your analysis in the same file. We will have plenty of examples of this below for clarification. Each **Model** file should output a **MAT file** which contains variables of interest to be used by other analysis. In some cases, creating a CSV file or [Parquet ](https://www.mathworks.com/help/matlab/parquet-files.html)file may be more appropriate. 

Let's open matlab_00_common.m and update our variables to reflect our current system needs. Notice that we add two commands to ensure that the entire Matlab environment is wiped clean (including resetting default paths) prior to any operations. This is essential to making sure that your results can be replicated on new systems. Finally, the `IsBatchMode `is a logical variable that will either be `TRUE `if running from the command line (such as through Makefile) or through the interactive GUI (as during development).

```
%=========================================================================%
%                     CREATE REPRODUCIBLE ENVIRONMENT                     %
%=========================================================================%

clear all;
restoredefaultpath();
IsBatchMode = batchStartupOptionUsed;
```

Next we add variables that represent pathnames to common software toolboxes that will be used by our analysis. Since we wipe the Matlab path clean on each run, this is essential to reassigning paths on each script run. The HTP path refers to our internal tool box which contains RepMake scripts and other useful EEG functions. 

```
%=========================================================================%
%                           TOOLBOX CONFIGURATION                         %
% eeglab: https://sccn.ucsd.edu/eeglab/download.php                       %
% high throughput pipline: github.com/cincibrainlab/htp_minimum.git       %
% fieldtrip: https://www.fieldtriptoolbox.org/download/                   %
% brainstorm: https://www.fieldtriptoolbox.org/download/                  %
%=========================================================================%

EEGLAB_PATH             = 'E:/Research Software/eeglab2021';
HTP_PATH                = 'C:/Users/ernie/Dropbox/htp_minimum';
BRAINSTORM_PATH         = 'E:/Research Software/brainstorm3';
FIELDTRIP_PATH          = 'E:/Research Software/fieldtrip-master';
```