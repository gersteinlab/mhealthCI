# mhealthCI


## Usage Overview

```
Rscript mhealthCI.R -f <4 column data file> -i <time interval of data> -s <start of experiment> -e <end of experiment> 
-n <intervention date> -v <depedent variable> -d <diabetes flag [lower/target/upper]>
```

mhealthCI requires a specific file format in order to process the data and run the casual impact anaylsis. The file must be a four column file with the following order: "Date", "Time", "Variable" , "Value". This file must have all of the covariates and each covariate and variable must the same time-length. The output of this script will then be a figure and a summary of the casual impact anaylsis. 

The `-i` flag or `--file` is for the filename, which the file must adhere to the aformentioned criteria. 

The `-i` flag or `--interval` will be the time interval in which the data must be aligned too. For example, 5 minutes. This allows for all of the data to be in the same time frame which is required for the anaylsis. 

The `-s` flag or `--startexpr` is the start date and time of the experiment. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-e` flag or `--endexpr` is the end date and time of the experiment. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-n` flag or `--interventiondate` is the intevervention date of the expirement. This must be formatted in the following format: "%YYYY-%MM-%DD %HH%MM%SS"

The `-d` flag or `--diabetes` is the flag that requests specical processesing for diabetes specific data. Essentially the daibetes data is processed in terms of in target range, above target range, or below target range. Therefore, there are three options with this flag: lower, target, upper. The usage for this flag is as follows: `-d upper` |  `-d lower` |  `-d target`. If you want to process the data normally, leave this flag empty. 


## Walkthrough

### Awair Data 

The awair dataset is a dataset that is attempting to understand the impact of lunchtime on carbon dixiode. First, we must download the required software in our R enviroment: "CausalImpact", "tidyverse", "lubridate", "data.table", "reshape2", "optparse". An example of how to do this in R: `install.packages("CasualImpact")`. You can confirm that these packages have downloaded by running: `library(CasualImpact)`.

The console should look something similar to this: 
```
library(CausalImpact)
Loading required package: bsts
Loading required package: BoomSpikeSlab
Loading required package: Boom
Loading required package: MASS
```

Now, set the working directory to where the output should be placed. We will be running this script on the Awair  data. If you need this data, it will be avaliable in the github repository for download. 

Execute this command in the terminal: 
```
Rscript mhealthCI.R -f AwairData.csv -i 5 -s "2018-07-14 15:00:00" -e "2018-08-14 11:35:00" -n "2018-07-22 17:00:00" -v CarbonDioxide
```

The results should be in the directory you are currenly in. 

### Diabetes Data 

We will now demonstrate a walkthrough for one of the diabetes patients, MED007. This will be a detailed step-by-step walkthrough of how to use mhealthCI. 

First, we must download the required software in our R enviroment: "CausalImpact", "tidyverse", "lubridate", "data.table", "reshape2", "optparse". An example of how to do this in R: `install.packages("CasualImpact")`. You can confirm that these packages have downloaded by running: `library(CasualImpact)`.

The console should look something similar to this: 
```
library(CausalImpact)
Loading required package: bsts
Loading required package: BoomSpikeSlab
Loading required package: Boom
Loading required package: MASS
```

Now, set the working directory to where the output should be placed. We will be running this data on the MED07 patient data. If you need this data, it will be avaliable in the github repository for download. 

Execute this command in the terminal: 
```
Rscript mhealthCI.R -f MED07_Data.csv -i 5 -s 2020-01-03 00:00:00 -e 2020-03-21 00:00:00 -n 2020-01-17 00:00:00 -v Glucose -d target
```

There should be a figure named: "CasualImpact.pdf", a summary text named, "CasualImpactSummary.txt", and the console should print the p-value. 

You can also execute the command without the diabetes formatting: 
```
Rscript mheathCI.R -f MED07_DATA.csv -i 5 -s 2020-01-03 00:00:00 -e 2020-03-21 00:00:00 -n 2020-01-17 00:00:00 -v Glucose
```
#### Other Diabetes Data

We also have another patient, MED14, which we can also run. The data is also avaliable in the repository. To process this data execute the following command: 
```
Rscript mheathCI.R -f MED14_DATA.csv -i 5 -s 2020-01-03 00:00:00 -e 2020-03-21 00:00:00 -n 2020-01-17 00:00:00 -v Glucose -d target
```

 
 
