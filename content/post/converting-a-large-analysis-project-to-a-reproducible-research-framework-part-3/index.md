---
title: Converting a Large Analysis Project to a Reproducible Research Framework Part
  3
date: 2021-09-14T00:09:53.623+00:00
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false

---
## _How easy would it be to convert an existing large MATLAB/R project to using GNU Make?_

In these tutorials, we will find out together!

After Part 1 and Part 2, we have **Make** to automate both the creation of a manuscript and a MATLAB data model. In this lesson, we will continue to generate MATLAB code to expand our analysis.

### Recounting what MATLAB assets we have available

* `matlab_00_common.m` which is common resource file
* `model_loadDataset.m` which creates a MAT file that includes information of EEG datasets
* **Makefile** with instructions to create `model_loadDataset.mat`

## Using a proxy target file in place of multiple targets

Tracking multiple target files from a single source file is strongly discouraged when using **Make**. Instead, a proxy file representing the target files has several advantages.

In the next section we will load 141 scalp EEG tracings and convert the data from 2-second regular epochs to continuous data. Rather than having 141 target files representing each conversion, it is much more efficient to generate a single file which confirms the code was a success.

A spreadsheet representing the path to each continuous file would be ideal, for example, if the conversion was successful. On the other hand if the process was unsuccessful, no file should be produced which tells **Make** something is wrong.

## Starting with the Makefile

On this round, why don't we start by editing the **Makefile** first?

One of the greatest advantages of having a Makefile is that you no longer have to worry about which files in your source directory really matter or are most up to date. The Makefile establishes which files are actively used in your building your assets. By starting with the Makefile you actually are setting a template which will make the remainder of the code easier to conceptualize and write.

For example, let's create a second data model which will reshape the trial dimension of our EEG datasets and form continuous data suitable for import into Brainstorm.

Let's define the name of the function we want to write:

`model_contDataset.m`

Let's define the dependency that this function requires:

`model_loadDataset.mat`  (the data model from our last tutorial)

And finally let's identify what data model or target we want **Make** to build:

`model_contDataset.mat`  (notice how our model naming mirrors our script)

#### Let's create our **Make** command in "long hand":

    E:/data/CommBioEEGRev/MatlabBuild/model_contDataset.mat: \
    model_contDataset.m model_loadDataset.mat
      matlab /minimize /nosplash /nodesktop /batch \
      'target_file=model_contDataset.mat;, run model_contDataset.m'

#### A few observations about this Make command for review:

* By placing model_loadDataset.mat onto the dependency side (right) we force **Make** to require the file be present before executing the command below.
* Remember that \\ specifies a line break when you want to make things clearer
* Any dependency on the right will get the **Make** "treatment", which means **Make** will keep track of when and if the file is updated. That is why it is crucial that both the script name and the input data files be added. Now when either of those files changes, **Make** will automatically update the target.
* Even though the shorthand of **Make** may appear confusing, you can see why it exists with this simple command. The command is too long to fit on a single line. In addition, commands in Make often use the target and dependency in the command itself. The shorthand can make it easier to read and reduces typo errors.

#### Let's now rewrite the command in Make shorthand:

* $(MB) is shorthand for the MATLAB Build directory
* $(Matlab) is defined at the beginning of the Makefile
* $@ refers to the target file (left)
* $< is distinct from $^. In this case, $< refers only to the first dependency

    # Data Model: Convert to continuous EEG
    $(MB)model_contDataset.mat: model_contDataset.m model_loadDataset.mat
        $(Matlab) "target_file=$@;, run $<"

Let's copy and paste this into our Makefile right under our last data model.

    #==============================================================================#
    # MATLAB RECIPIES                                                              #
    #==============================================================================#
    
    # Data Model: Load scalp EEG dataset
    $(MB)model_loadDataset.mat: model_loadDataset.m
        $(Matlab) "target_file='$@';, run $^"
    
    # Data Model: Convert to continuous EEG
    $(MB)model_contDataset.mat: model_contDataset.m model_loadDataset.mat
        $(Matlab) "target_file=$@;, run $<"

## A dubious design decision

Here, we chose to set the import datafile name in the MATLAB script rather than as an argument. Similar to the target file, we could have easily added a second variable: "`data_file = model_importDataset.mat;`". **Make** enables a great deal of flexibility when reusing code since the input and output filenames are specified within the Makefile. By hardcoding the import model into the continuous model MATLAB code, I have limited the use of the continuous model code to the import model code.

Telling Make about our new target file

Finally, add our new target file to the MATLAB build shortcut in the combined recipes section of the Makefile. If you wanted to skip this step, you could have Make run the target directly by specifying `Make target_name`. However, in this case, we want to use Make to build and track all our MATLAB scripts.

    #==============================================================================#
    #                                  RECIPES                                     #
    #==============================================================================#
    # COMBINED         ============================================================#
    # "RECIPES"        combination recipes create groups of assets such as all     #
    #                  tables or figures.                                          #
    #                  definition: recipe_name: asset1 asset2                      #
    #                  usage: make recipe_name                                     #
    #==============================================================================#
    
    all: matlab
    
    matlab: $(MB)model_loadDataset.mat $(MB)model_contDataset.mat

## Building our second data model

Setting up the Makefile first can make the development of the final script more efficient. When a pre-existing project is being converted, much of the Makefile can be planned by working backwards from the manuscript assets (i.e., tables and figures).

### Creating the second data model: reshaping data

Let's create a second data model which will reshape the trial dimension of our EEG datasets and form continuous data suitable for import into brainstorm. Narrowing in on the scope of this script, we want to load our previous target, perform our conversion operation, and save a new MAT file with the updated data model.

Let's rapidly prototype our script by:

* create copy and open `model_loadDataset.m`
* change `basename = 'loadDataset'`to `basename=`'`contDataset'`
* modify the import data to `data_file = 'model_loadDataset.mat'`
* no change to the `output_file_extension = 'MAT'`

Next we will add our code for converting our data to continuous data.

    try
        p.bst_prepareContinuousData;
        status = 'Epoch2ContinuousData: Success.';
    catch
        status = "Epoch2ContinuousData: Fail.";
    end

#### Sidebar: Try-Catch blocks to Track Errors

Try-Catch blocks are simple ways to try code and understand what happens when there is a failure without abruptly existing your code. In this case, we "try" the function to convert our data. If the "try" succeeds or fails the variable status will be updated. The "try" block will keep MATLAB from crashing if something within the bracket causes an error. It will literally "catch" the error and allow the script to continue.

### Saving and running the second data model

At this point, the template code will save a MAT of the updated EEG structure. Since we have already updated the Makefile, feel free to now run the command `make matlab`.

If everything is working correctly, **Make** will recognize the first data model has already been built and will move on to the new data model you just created. Following completion you should have two Build products in your MATLAB Build directory.

    Directory: E:\data\CommBioEEGRev\MatlabBuild
    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a----         9/14/2021  10:11 AM       52423067 model_contDataset.mat
    -a----         9/14/2021  10:05 AM       52118136 model_loadDataset.mat

## Conclusion of Part 3

At this point we have become familiar with how to create data models in Matlab using an automated build process with **Make**. In Part 4 we will accelerate further by diving into automating the generation of an EEG source model. Finally.