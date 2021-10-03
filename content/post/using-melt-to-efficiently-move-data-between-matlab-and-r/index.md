---
title: Using Melt to Efficiently Move Data Between MATLAB and R
subtitle: "Part I: Bulk Export of Data Variables from MATLAB to R"
date: 2021-10-01T17:03:31.858Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
MATLAB is increasingly used as a data-processing engine. The compiled code is fast, and it is relatively easy to use GPUs, parallel processing, and cluster computing.  MATLAB is certainly capable of many other tasks but its statistical and visualization capabilities are outdated (MATLAB plots? ), or require additional toolkits. It takes far more effort to wrangle data, model it, and visualize it in MATLAB than in R (or other statistical programs). MATLAB is rarely used by professional biostatisticians, as well.

Using MATLAB on a "headless" cluster also adds additional constraints. You may not have access to a graphical user interface or may have limited computing time or resources. Complex MATLAB code, such as hard-coding tables or specifying groups, results in more for-loops and less efficient code.

This is why our lab generally takes the approach of putting data into MATLAB and getting raw results as quickly as possible. 

Here we demonstrate an extremely rapid method to capture high-dimensional data in MATLAB and export it for use in R. This is of course possible since most data formats, including MATLAB formats, are interchangeable through the open-source community.

## An overview of the process

* overall analysis loop with data file export to R
* peak into the individual analysis function to see how variables are captured for export
* a look at the mixed-type data structure to import into R

### Script 1: MATLAB analysis loop across 135 subjects

#### Concise analysis code

Lines 1-6 represent the entire group-level analysis code. An array of data objects (1) is looped (2, using parallel processing) through an analysis function (3). The file is then saved in an R project folder (5-6). As we will see, the output structure contains seven result arrays. In a typical script, creating export templates and formatting export templates would dominate the code.

The export variable portion of this code is extremely simple. In the main loop, we store the entire results of the analysis function (for each subject) into a single cell array. This avoids any unnecessary complexity which can lead to errors during parallel for-loops.

```matlab
% MATLAB Analysis Loop
nsub = numel(p.sub); 
parfor si = 1 : nsub  
    mvarResArr(si) = fx_mvar_cfc( sub( si ), 10, syspath );
end
target_file = fullfile(syspath.RBuild, 'model_cfcparfor.mat');
save(target_file, 'mvarResArr');
```

#### Focus on code for data export to R

MATLAB structures appear to be the easiest to import into R. This is primarily because MATLAB structures can hold any type of data and the names of the fields will translate directly into R. 

In the main structure *output* I include both a *key* and a *data* field. The *key* contains a variable name that describes the variables stored in *data* field (line 2 and 3).

I create an export file with the same prefix as my analysis script but with a ".mat" extension. Important: For now, you must include the '-v6' to save the MAT file in a format that is readable by the R package R.matlab. Finally, we save the mat file with the structure output into the R build folder.

```matlab
% Data export for R
output.key = {'eegid','mvarpac1','mvarpac2','pli1','pli2', ...
    'evecs','evals','sFiltMap','netMaps', 'frex', 'chans',...
    'tfP','tfT'};
output.data = mvarResArr;
target_file = fullfile(syspath.RBuild, 'model_cfcparfor4.mat');
save(target_file, 'output', '-v6');
```

### Script 2: MATLAB analysis function for single subject

#### Bulk storing of analysis variables

The script below is the tail end of a multivariate cross frequency coupling (CFC) function ([based on Cohen's gedCFC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5262375/)). I wanted to capture several different variables to later explore in R. The computational time is significant and trying to parse out how to format and save individual outputs is not trivial, especially when optimizing parallel processing (*parfor*) loops.

Here we capture a total of 13 variables of different types (character, vector, matrix, cell array). I have found it easier to disentangle the results in R if a few conventions are followed:

1. **Key variables:** include a key variable, in this case it is my blinded ID of the EEG file (5)
2. **Separate distinct results**: Separate distinct results at this stage since row or column naming numerical matrices is not straightforward in either R or MATLAB (see lines 6 and 7). In this case, we had a combined 2 row x 70 column result array but each row represents a different measure (i.e., peak versus trough CFC). 
3. **Store label vectors:** Add label variables for any numerical vectors or arrays which you can join later in R
4. **Data redundancy:** Duplicating data (i.e. storing an identical label array with each subject (i.e. frequency vector) may seem inefficient, but due to built-in compression with the MATLAB mat file there is no size penalty and may help if you split your data at a later stage. 

```matlab
% for
% ... analysis steps
% end
resultCell{1} = s.subj_basename;
resultCell{2} = mvarpac(1,:);
resultCell{3} = mvarpac(2,:);
resultCell{4} = sync(1,:);
resultCell{5} = sync(2,:);
resultCell{6} = evecs;
resultCell{7} = evals;
resultCell{8} = sFiltMap';
resultCell{9} = maps;
resultCell{10} = frex;
resultCell{11} = {EEG.chanlocs.labels};
resultCell{12} = tfP;
resultCell{13} = tfT;
mvar = {resultCell};
```

### A look into the output structure at mixed data

Inspecting the output data structure, we find that it contains all different types of data. It was previously necessary to create a specific output for each variable type in MATLAB. Now, you can see that many types of variables, including 3D arrays, coexist harmoniously. Compared to long data tables, this is one of the most efficient methods for storing multidimensional data.

```
output.data{1}
ans =
  1×13 cell array
    {'D0079_rest'}    {1×70 double}    {1×70 double}    {1×70 double}    {1×70 double}    {108×108 double}    {108×108 double}    {1×108 double}    {108×108 double}    {1×70 double}    {1×108 cell}    {2×70×121 double}    {2×70×121 double}
```