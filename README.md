# mhealthCI


## Usage Overview

```
Rscript mhealthCI.R -f <4 column data file> -i <time interval of data> -s <start of experiment> -e <end of experiment> 
-n <intervention date> -v <depedent variable> -d <diabetes flag [lower/target/upper]>
```

mhealthCI requires a specific file format in order to process the data and run the casual impact anaylsis. The file must be a four column file with the following order: "Date", "Time", "Variable" , "Value". This file must have all of the covariates and each covariate and variable must the same time-length. The output of this script will then be a figure and a summary of the casual impact anaylsis. 

The `-f` flag is for the filename, which the file must adhere to the aformentioned criteria. 
 
