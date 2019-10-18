# mkduration
Stata command to create duration variable with binary cross-sectional time series data

## Description
`mkduration` is a Stata command to generate a duration variable for duration/event history data where the data are xtset and in long format. In other words, given CSTS-style data for i units observed over t time periods, and where there is some dichotomous variable (where "1" indicates the instance of an event, and "0" indicates an absence):

| Unit | Time | Event |
|------|------|-------|
| 1    | 1    | 0     |
| 1    | 2    | 0     |
| 1    | 3    | 1     |
| 1    | 4    | 0     |
| 1    | 5    | 1     |
| 2    | 1    | 0     |
| 2    | 2    | 1     |
| 2    | 3    | 0     |
| 2    | 4    | 0     |
| 2    | 5    | 0     |

`mkduration` will generate a duration variable:

| Unit | Time | Event | Duration |
|------|------|-------|----------|
| 1 | 1 | 0 | 1 |
| 1 | 2 | 0 | 2 |
| 1 | 3 | 1 | 3 |
| 1 | 4 | 0 | 1 |
| 1 | 5 | 1 | 2 |
| 2 | 1 | 0 | 1 |
| 2 | 2 | 1 | 2 |
| 2 | 3 | 0 | 1 |
| 2 | 4 | 0 | 2 |
| 2 | 5 | 0 | 3 |

More information is available in the help file.

## Install

You can install `mkduration` directly from GitHub if you're connected to the internet:
```
capture ado uninstall mkduration
net install mkduration, from(https://github.com/andyphilips/mkduration/raw/master/src/)
```
Alternatively, you can download the files from the source folder and either call directly to the .ado files or place them in your "ado/plus/" folder.

## Version
Version 1.0.1, October 18, 2019
