# Replication Package for Ramos and Berrington (2026) Social Science Research

**Paper:** *[Employment Stability and Social Origin: Cumulative Advantages in Young Adults' Homeownership and Financial Asset Accumulation](https://doi.org/10.1016/j.ssresearch.2026.103369)*  
**Authors:** Vincent Jerald Ramos and Ann Berrington  
**Replication package date:** May 2026


This package contains Stata and R code to construct the analytical dataset, derive school-to-work activity histories and sequence clusters, and reproduce the main tables and figures from the article.

## Package contents

| File | Purpose | Main outputs |
|---|---|---|
| `1_wrangling.do` | Builds the master respondent-level dataset from Next Steps/LSYPE1 source files and derives key variables for housing, assets, income, socio-demographic characteristics, and parental background. | `output/tables/master.dta`; intermediate weight/main-interview files |
| `2_histories.do` | Builds monthly activity histories, reshapes them to wide format, and merges valid histories into the master dataset. | `output/tables/activity_merged.dta`; `output/tables/activity_merged_all.dta`; history files |
| `3_sequence.R` | Runs sequence analysis on monthly activity histories and creates optimal-matching cluster assignments. | `output/tables/activity_clusters.dta` after path harmonisation; sequence plots if graphics export is added |
| `4_analysis.do` | Merges cluster assignments back into the analytical file and reproduces main descriptive tables, models, and figures. | `output/tables/activity_clusters_wide.dta`; `output/figures/*.png`; `output/figures/clusterfrequency.xlsx` |

## Data availability

The raw data are not included in this replication package. The scripts expect Stata-format Next Steps / LSYPE1 files under a UK Data Service-style folder structure, including folders named:

```text
data/UKDA-5545-stata/stata/stata13/safeguarded_eul/
data/UKDA-5545-stata/stata/stata13/activity_histories/
data/UKDA-5545-stata/stata/stata13/household_grids/
```

Users must obtain the required data through the appropriate UK Data Service access route and place the files in the expected folders, or edit the paths in the scripts.

## Recommended folder structure

```text
project-root/
├── README.md
├── 1_wrangling.do
├── 2_histories.do
├── 3_sequence.R
├── 4_analysis.do
├── data/
│   └── UKDA-5545-stata/
│       └── stata/stata13/
│           ├── safeguarded_eul/
│           ├── activity_histories/
│           └── household_grids/
└── output/
    ├── tables/
    └── figures/
```

The Stata scripts create `output/`, `output/tables/`, and `output/figures/` if they do not already exist.

## Software requirements

The package uses both Stata and R. Record the exact software versions used when depositing the final replication package.

### Stata

Recommended: Stata 18 or later, because `4_analysis.do` uses `dtable`. If running on earlier Stata versions, replace `dtable` with equivalent table code.

The scripts also use or reference user-written Stata commands. Install and record versions for at least the following before running:

```stata
ssc install estout, replace     // provides eststo
ssc install coefplot, replace
ssc install outreg2, replace
ssc install unique, replace
ssc install khb, replace
```

The scripts also call `grc1leg2` and `mplotoffset`; install these from their original Stata sources and document the installation source/version. If these commands are not installed, `4_analysis.do` will stop when it reaches the relevant graph commands.

### R

Recommended: R 4.x. The current R script uses these packages:

```r
install.packages(c(
  "TraMineR", "TraMineRextras", "cluster", "WeightedCluster",
  "FactoMineR", "ade4", "RColorBrewer", "questionr", "descriptio",
  "dplyr", "purrr", "ggplot2", "descr", "haven", "reshape2", "here"
))
```

The script also loads `seqhandbook`. Install it from the appropriate source used by the authors and record that source in the final package.

For stronger reproducibility, create and include an `renv.lock` file:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

## Important setup before running

1. In each Stata do-file, replace:

```stata
global PROJDIR "[PATH_TO_PROJECT_FOLDER]"
```

with the absolute path to `project-root`.

2. Use forward slashes in paths where possible. The Stata scripts currently use Windows-style backslashes in many file paths; forward slashes are more portable across Windows, macOS, and Linux.


## Reproduction order

Run the scripts in this order from the project root.

### 1. Build master respondent file

```stata
do 1_wrangling.do
```

Expected key output:

```text
output/tables/master.dta
```

### 2. Build and merge activity histories

```stata
do 2_histories.do
```

Expected key outputs:

```text
output/tables/activity_histories_wide.dta
output/tables/activity_merged.dta
output/tables/activity_merged_all.dta
```

### 3. Run sequence analysis in R

After harmonising paths as described above:

```r
source("3_sequence.R")
```

Expected key output:

```text
output/tables/activity_clusters.dta
```

### 4. Run analysis and generate tables/figures

```stata
do 4_analysis.do
```

Some appendix tables and figures are currently commented out in `4_analysis.do`. Uncomment those blocks to reproduce the corresponding appendix materials.

## Citation and licence

Please cite the associated article when using this replication package. 

Ramos, V. J., & Berrington, A. (2026). Employment stability and social origin: Cumulative advantages in young adults’ homeownership and financial asset accumulation. *Social Science Research, 137*, 103369.

