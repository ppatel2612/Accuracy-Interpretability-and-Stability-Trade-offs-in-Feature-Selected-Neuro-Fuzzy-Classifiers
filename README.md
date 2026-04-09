# Neuro-Fuzzy Feature Selection Project

This project evaluates feature-selection-enhanced neuro-fuzzy classification on four high-dimensional benchmark datasets:

- Arcene
- Madelon
- Gisette
- Dorothea

The pipeline compares three approaches:

1. **Baseline ANFIS**
2. **ReliefF → ANFIS**
3. **LASSO → ANFIS**

The experiments are run using **10-fold cross-validation** in MATLAB, and the outputs include:

- classification performance tables
- model complexity tables
- feature stability tables
- tradeoff plots and comparison figures

---

## Project Goal

The purpose of this project is to study whether feature selection can improve the practicality of neuro-fuzzy classification on high-dimensional datasets by improving:

- predictive performance
- model compactness
- interpretability
- stability across folds

---

## Repository Structure

```text
project_root/
│
├── data/
│   ├── raw/
│   │   ├── arcene/
│   │   ├── madelon/
│   │   ├── gisette/
│   │   └── dorothea/
│   └── processed/
│
├── folds/
│
├── results/
│   ├── fold_results/
│   ├── summary_tables/
│   └── plots/
│
├── scripts/
│   ├── 01_prepare_datasets.m
│   ├── 02_create_folds.m
│   ├── 03_run_experiments.m
│   ├── 04_summarize_results.m
│   └── 05_make_plots.m
│
├── src/
│   ├── data/
│   ├── preprocess/
│   ├── fs/
│   ├── models/
│   └── eval/
│
└── startup.m
```

---

## Requirements

### Software
- MATLAB
- Fuzzy Logic Toolbox
- Statistics and Machine Learning Toolbox

### MATLAB functions used
The implementation relies on functions such as:

- `anfis`
- `genfis2`
- `relieff`
- `lassoglm`
- `cvpartition`
- `perfcurve`

---

## Datasets

This project uses the following benchmark datasets:

- Arcene
- Madelon
- Gisette
- Dorothea

Each dataset should be placed in its own folder under:

```text
data/raw/
```

Expected structure:

```text
data/raw/arcene/
data/raw/madelon/
data/raw/gisette/
data/raw/dorothea/
```

For each dataset, the raw folder should contain the original challenge files, including the train/validation data and labels.

Example:

```text
data/raw/madelon/madelon_train.data
data/raw/madelon/madelon_train.labels
data/raw/madelon/madelon_valid.data
data/raw/madelon/madelon_valid.labels
```

---

## Important Experimental Note

The original datasets are extremely high-dimensional. To make ANFIS training computationally feasible, the pipeline applies a **fold-internal candidate feature reduction step** before the final feature-selection and ANFIS training stages.

This means:

- preprocessing is done using the training fold only
- candidate features are selected using the training fold only
- normalization parameters are learned from the training fold only
- the test fold is never used during preprocessing or feature selection

This avoids data leakage while keeping the ANFIS models trainable.

---

## How to Replicate the Results

Run the following scripts in order from MATLAB.

### Step 1: Initialize the project path

```matlab
startup
```

This adds the project folders to the MATLAB path and initializes the random seed.

---

### Step 2: Prepare the datasets

```matlab
scripts/01_prepare_datasets
```

This script:

- loads each dataset from `data/raw/`
- combines the labelled training and validation splits
- converts labels into binary form
- saves processed `.mat` files into `data/processed/`

Output files:

```text
data/processed/arcene.mat
data/processed/madelon.mat
data/processed/gisette.mat
data/processed/dorothea.mat
```

---

### Step 3: Create 10-fold cross-validation splits

```matlab
scripts/02_create_folds
```

This script creates stratified 10-fold partitions and saves them into the `folds/` directory.

Output files:

```text
folds/arcene_folds.mat
folds/madelon_folds.mat
folds/gisette_folds.mat
folds/dorothea_folds.mat
```

---

### Step 4: Run the experiments

```matlab
scripts/03_run_experiments
```

This script performs the full experiment for each dataset and each fold.

For every fold, it runs:

- Baseline ANFIS
- ReliefF → ANFIS
- LASSO → ANFIS

It computes fold-level:

- Accuracy
- Macro-F1
- AUC
- selected feature counts
- rule counts
- membership function counts

Output files:

```text
results/fold_results/arcene_results.mat
results/fold_results/madelon_results.mat
results/fold_results/gisette_results.mat
results/fold_results/dorothea_results.mat
```

---

### Step 5: Summarize the fold-level results

```matlab
scripts/04_summarize_results
```

This script aggregates the 10-fold outputs into summary tables.

Generated tables include:

- performance summary tables
- complexity summary tables
- stability summary tables

Output files:

```text
results/summary_tables/arcene_results_table.csv
results/summary_tables/arcene_complexity_table.csv
results/summary_tables/arcene_stability_table.csv
...
```

---

### Step 6: Generate plots and figures

```matlab
scripts/05_make_plots
```

This script generates the figures used for analysis and reporting.

Generated plots include:

- Accuracy vs Selected Features
- Accuracy vs Rules
- Macro-F1 vs Selected Features
- AUC vs Rules
- performance comparison bar charts
- complexity comparison bar charts
- stability bar charts
- fold-level boxplots

Output folders:

```text
results/plots/arcene/
results/plots/madelon/
results/plots/gisette/
results/plots/dorothea/
```

---

## Running a Single Dataset

To run only one dataset at a time, edit the `datasets` variable inside the scripts.

For example, to run only Madelon:

```matlab
datasets = {'madelon'};
```

You can make this change in:

- `scripts/01_prepare_datasets.m`
- `scripts/02_create_folds.m`
- `scripts/03_run_experiments.m`
- `scripts/04_summarize_results.m`
- `scripts/05_make_plots.m`

Then rerun the pipeline scripts in order.

---

## Main Methods Evaluated

### 1. Baseline ANFIS
A neuro-fuzzy classifier trained directly on a reduced candidate feature subset.

### 2. ReliefF → ANFIS
ReliefF ranks candidate features, and the top-ranked subset is used to train ANFIS.

### 3. LASSO → ANFIS
LASSO logistic regression selects a sparse subset of candidate features, which is then used to train ANFIS.

---

## Evaluation Metrics

The project evaluates each method using:

- **Accuracy**
- **Macro-F1**
- **AUC**

It also measures model complexity using:

- number of selected features
- number of fuzzy rules
- number of membership functions

Feature-selection stability is measured using average pairwise **Jaccard overlap** across folds.

---

## Typical Workflow Summary

From a clean setup, the complete reproduction flow is:

```matlab
startup
scripts/01_prepare_datasets
scripts/02_create_folds
scripts/03_run_experiments
scripts/04_summarize_results
scripts/05_make_plots
```

---

## Notes on Reproducibility

- The project uses a fixed random seed in `startup.m`.
- Cross-validation is stratified.
- Preprocessing and feature selection are performed inside each training fold only.
- Dorothea is handled as a sparse dataset until dimensionality is reduced.

---

## Expected Final Outputs

After running the full pipeline, you should have:

### Processed datasets
```text
data/processed/
```

### Cross-validation folds
```text
folds/
```

### Fold-level experiment outputs
```text
results/fold_results/
```

### Final summary tables
```text
results/summary_tables/
```

### Final figures
```text
results/plots/
```

---

## Troubleshooting

### ANFIS training is too slow
Reduce:
- number of final selected features
- number of candidate features
- ANFIS epochs

### Rule counts become too large
Increase the subtractive clustering radius or reduce the number of selected features.

### Dorothea uses too much memory
Keep the data sparse until candidate feature reduction is complete.

### A method is missing from a plot
Check that method labels in the summary tables match the expected naming format.

---

## License / Usage

This repository is intended for academic and research use.
