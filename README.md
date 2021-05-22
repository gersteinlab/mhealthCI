# mhealthCI


## Usage Overview

```
Rscript mhealthCI.R -f <4 column data file> -i <time interval of data> -s <start of experiment> -e <end of experiment> 
-n <intervention date> -v <depedent variable> -d <diabetes flag [lower/target/upper]>
```

mhealthCI requires a specific file format in order to process the data and run the casual impact anaylsis. The file must be a four column file with the following order: "Date", "Time", "Variable" , "Value". This file must have all of the covariates and each covariate and variable must the same time-length. The output of this script will then be a figure and a summary of the casual impact anaylsis. 

The `-i` flag or `--file` is for the filename, which the file must adhere to the aformentioned criteria. 

The `-i` flag or `--interval` will be the time interval in which the data must be aligned too. For example, 5 minutes. This allows for all of the data to be in the same time frame which is required for the anaylsis. 

The `-s` flag or `--startexpr` is the start date and time of the experiment. This must be formatted in the following format: %YYYY-%MM-%DD %HH%MM%SS

The `-e` flag or `--endexpr` is the end date and time of the experiment. This must be formatted in the following format: %YYYY-%MM-%DD %HH%MM%SS

The `-n` flag or `--interventiondate` is the intevervention date of the expirement. This must be formatted in the following format: %YYYY-%MM-%DD %HH%MM%SS

The `-d` flag or `--diabetes` is the flag that requests specical processesing for diabetes specific data. Essentially the daibetes data is processed in terms of in target range, above target range, or below target range. Therefore, there are three options with this flag: lower, target, upper. The usage for this flag is as follows: `-d upper` |  `-d lower` |  `-d target`. If you want to process the data normally, leave this flag empty. 








 
 
