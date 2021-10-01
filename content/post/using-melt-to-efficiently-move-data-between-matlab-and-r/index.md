---
title: Using Melt to Efficiently Move Data Between MATLAB and R
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

Lines 1-6 represent the entire group-level analysis code. An array of data objects (1) is looped (2, using parallel processing) through an analysis function (3). The file is then saved in an R project folder (5-6). As we will see, the output structure contains seven result arrays. In a typical script, creating export templates and formatting export templates would dominate the code.

```matlab
nsub = numel(p.sub); 
parfor si = 1 : nsub  
    mvarResArr(si) = fx_mvar_cfc( sub( si ), 10, syspath );
end
target_file = fullfile(syspath.RBuild, 'model_cfcparfor.mat');
save(target_file, 'mvarResArr');
```

Let's take a brief peek into the guts of the analysis function. The multivariate cross frequency coupling function ([based on Cohen's gedCFC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5262375/)) described here produces many useful outcomes. In R, these outputs can be explored and understood more quickly if they are readily available.

```
% for
% ... analysis steps
% end
resultCell{1} = s.subj_basename;
resultCell{2} = mvarpac;
resultCell{3} = sync;
resultCell{4} = evecs;
resultCell{5} = evals;
resultCell{6} = sFiltMap;
resultCell{7} = maps;
mvar = {resultCell};
```

```
mvarResArr =

  136×1 cell array

    {1×7 cell}
    {1×7 cell}
    {1×7 cell}
    {1×7 cell}
    {1×7 cell}
    {1×7 cell}
    ...

mvarResArr(si)
ans = {1×7 cell}

mvarResArr{si}
ans = {'D0199_rest'}    {2×70 double}    {2×70 double}    {108×108 double}    {108×108 double}    {108×1 double}    {108×108 double}
```