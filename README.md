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

## Examples and Citing
You can see more details in the [Stata Journal article](https://journals.sagepub.com/doi/10.1177/1536867X20976322), or the [ungated version](https://github.com/andyphilips/mkduration/blob/master/Philips-2020-SJ.pdf).

If you use `mkduration` in your own work, I'd love it if you cited me: Philips, Andrew Q. 2020. "An easy way to create duration variables in binary cross-sectional time series data." The Stata Journal 20(4): 916-930.


## Install
The easiest way to install `mkduration` is by directly typing into Stata:
```
net install st0621
net get st0621
```

Alternatively, you can install `mkduration` directly from GitHub if you're connected to the internet:
```
capture ado uninstall mkduration
net install mkduration, from(https://github.com/andyphilips/mkduration/raw/master/src/)
```

Last, you can download the files from the source folder and either call directly to the .ado files or place them in your "ado/plus/" folder.

## Version
Version 1.0.4, April 27, 2020
