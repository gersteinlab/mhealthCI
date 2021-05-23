# mhealthCI


## Usage Overview

```
Rscript mhealthCI.R -f <4 column data file> -i <time interval of data> -s <start of experiment> -e <end of experiment> 
-n <intervention date> -v <depedent variable> -d <diabetes flag [lower/target/upper]>
```

mhealthCI requires a specific file format in order to process the data and run the casual impact anaylsis. The file must be a four column file with the following order: "Date", "Time", "Variable" , "Value". This file must have all of the covariates and each covariate and variable must the same time-length. The output of this script will then be a figure and a summary of the casual impact anaylsis. 

The `-f` flag or `--file` is for the path and filename, which the file must adhere to the aformentioned criteria. The given path is in relation to the script location.

The `-i` flag or `--interval` will be the time interval in which the data must be aligned too. For example, 5 minutes. This allows for all of the data to be in the same time frame which is required for the anaylsis. 

The `-s` flag or `--startexpr` is the start date and time of the experiment. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-e` flag or `--endexpr` is the end date and time of the experiment. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-n` flag or `--interventiondate` is the intevervention date of the expirement. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-d` flag or `--diabetes` is the flag that requests specical processesing for diabetes specific data. Essentially the daibetes data is processed in terms of in target range, above target range, or below target range. Therefore, there are three options with this flag: lower, target, upper. The usage for this flag is as follows: `-d upper` |  `-d lower` |  `-d target`. If you want to process the data normally, leave this flag empty. 


## Dependencies

The script utilizes multiple libraries in R in order to complete the impact anaylsis. Therefore, we must download the required sofwtare in our R enviroment: "CausalImpact", "tidyverse", "lubridate", "data.table", "reshape2", "optparse". An example of how to do this in R: `install.packages("CasualImpact")`. You can confirm that these packages have downloaded by running: `library(CasualImpact)`.

The console should look something similar to this: 
```
library(CausalImpact)
Loading required package: bsts
Loading required package: BoomSpikeSlab
Loading required package: Boom
Loading required package: MASS
```

Once this is complete, the script should have the required packages to run. 

## Walkthrough

This will be a detailed step-by-step walkthrough of how to use mhealthCI for multiple examples, using the different flags. 

### Awair Data 

The Awair dataset is understanding the impact of arriving to work on carbon dioxide emmissions. Therefore we will understand the impact on one date: 2018-07-18. We will set the intervention at 4:30 AM as that is when individuals start to arrive to work. 

Execute this command in the terminal: 
```
Rscript mhealthCI.R -f AwairData.csv -i 5 -s "2018-07-18 00:00:00" -e "2018-07-18 23:55:00" -n "2018-07-18 04:30:00" -v CarbonDioxide
```

The results should resemble this: 

```
[1] "ALIGNING AND CLEANING DATA..."
[1] "ANALYZING CAUSAL IMPACT..."
=-=-=-=-= Iteration 0 Sun May 23 11:50:55 2021 =-=-=-=-=
=-=-=-=-= Iteration 100 Sun May 23 11:50:55 2021 =-=-=-=-=
=-=-=-=-= Iteration 200 Sun May 23 11:50:55 2021 =-=-=-=-=
=-=-=-=-= Iteration 300 Sun May 23 11:50:56 2021 =-=-=-=-=
=-=-=-=-= Iteration 400 Sun May 23 11:50:56 2021 =-=-=-=-=
=-=-=-=-= Iteration 500 Sun May 23 11:50:56 2021 =-=-=-=-=
=-=-=-=-= Iteration 600 Sun May 23 11:50:56 2021 =-=-=-=-=
=-=-=-=-= Iteration 700 Sun May 23 11:50:56 2021 =-=-=-=-=
=-=-=-=-= Iteration 800 Sun May 23 11:50:57 2021 =-=-=-=-=
=-=-=-=-= Iteration 900 Sun May 23 11:50:57 2021 =-=-=-=-=
[1] "SAVING ANALYSIS RESULTS TO DIRECTORY"
[1] "p-value: 0.0161104718066743"
```

Due to the nature of MCMC, slight variations in the p-value may occur.


### Diabetes Data 

#### Individual 1: MED07

We will now demonstrate a walkthrough for one of the individuals with diabetes, MED007. 

The study was over a 12-week period in which we train the model for the first two weeks and predict the remaning 10 weeks. We are attempting to understand the impact of excersise on blood glucose values. We will be running this data on the MED07 individual's data. If you need this data, it will be avaliable in the github repository for download. 

Execute this command in the terminal: 
```
Rscript mhealthCI.R -f MED007_Data.csv -i 5 -s "2020-01-03 00:00:00" -e "2020-03-21 00:00:00" -n "2020-01-17 00:00:00" -v Glucose -d target
```

There should be a figure named: "CasualImpact.pdf", a summary text named, "CasualImpactSummary.txt", and the console should print the p-value. The results should look similar to this below: 

```
[1] "ALIGNING AND CLEANING DATA..."
Warning message:
In align_data_function(combined.data, date1, date2, interval, vars) :
  NAs introduced by coercion
[1] "ANALYZING CAUSAL IMPACT..."
=-=-=-=-= Iteration 0 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 100 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 200 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 300 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 400 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 500 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 600 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 700 Sun May 23 11:59:27 2021 =-=-=-=-=
=-=-=-=-= Iteration 800 Sun May 23 11:59:28 2021 =-=-=-=-=
=-=-=-=-= Iteration 900 Sun May 23 11:59:28 2021 =-=-=-=-=
[1] "SAVING ANALYSIS RESULTS TO DIRECTORY"
[1] "p-value: 0.0648769574944072"
```
Due to the nature of MCMC, slight variations in the p-value may occur.

#### Individual 2: MED 14

We also have another individual from the same study, MED14, which we can also run. The data is also avaliable in the repository. To process this data execute the following command: 
```
Rscript mhealthCI.R -f MED014_DATA.csv -i 5 -s "2020-01-03 00:00:00" -e "2020-03-21 00:00:00" -n "2020-01-17 00:00:00" -v Glucose -d target
```

The results should be similar to this: 
```
[1] "ALIGNING AND CLEANING DATA..."
[1] "ANALYZING CAUSAL IMPACT..."
=-=-=-=-= Iteration 0 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 100 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 200 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 300 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 400 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 500 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 600 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 700 Sun May 23 12:02:22 2021 =-=-=-=-=
=-=-=-=-= Iteration 800 Sun May 23 12:02:23 2021 =-=-=-=-=
=-=-=-=-= Iteration 900 Sun May 23 12:02:23 2021 =-=-=-=-=
[1] "SAVING ANALYSIS RESULTS TO DIRECTORY"
[1] "p-value: 0.0110441767068273"
```

Due to the nature of MCMC, slight variations in the p-value may occur.

#### Extra
Some additional analysis can be found in the extra folder.
