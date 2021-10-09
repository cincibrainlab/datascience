---
title: "Checking your Ins and Outs: The underused MATLAB Input Parser"
date: 2021-10-09T17:20:55.045Z
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---
Did you know that MATLAB has a [built-in function for managing and validating inputs](https://www.mathworks.com/help/matlab/ref/inputparser.html)?

The MATLAB Input Parser allows you to validate inputs for accuracy and assign defaults to make your code easier to maintain. Let's jump in:

I am working on a new function to generate cross-frequency coupling relationships within an EEG data structure. In this case, I first define my function and my input. I want the user to input an [EEGLAB EEG SET structure](https://eeglab.org/tutorials/ConceptsGuide/Data_Structures.html) and some other parameters that I will define as I write the function. We specify the "other inputs" to MATLAB using the `varargin` command.

```matlab
function mvar = fx_gedcfc_base( EEG, varargin )
end
```

Next, we will create an inputParser object which we will call p.

```matlab
function mvar = fx_gedcfc_base( EEG, varargin )
   p = inputParser;
end
```

At this point, we now begin to use the inputParser for common tasks that usually would take many more lines of code to add manually.

1. Let's make EEG a required input and make sure it is a structure:

addRequired(p,'EEG',@isstruct);

2. Let's also check for a phase or amplitude optional value that can act as a parameter. If a user does not supply a 'phase' or 'amplitude' then set default values:

```matlab
function mvar = fx_gedcfc_base( EEG, varargin)

    defaultPhase = 10;
    defaultAmplitude = 30;
    
    ip = inputParser;
    addRequired(ip,'EEG',@isstruct);
    addOptional(ip,'phase',defaultPhase, @isinteger);
    addOptional(ip,'amplitude',defaultAmplitude, @isinteger);
    parse(ip,EEG,varargin{:})
    
    fprintf('fx_gedcfc_base function: Phase %d, Amplitude %d\n', ip.Results.phase, ip.Results.amplitude);

    mvar = EEG;
    
end
```

Here is our completed function. When we call it from our test file the output from:
`mvar = fx_gedcfc_base(EEG);`

```
>> mvar = fx_gedcfc_base(EEG);
fx_gedcfc_base function: Phase 10, Amplitude 30
```

That's it for the basic use of inputParser. The class itself is much more powerful and has many uses.