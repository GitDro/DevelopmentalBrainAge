# Developmental Brain Age

This repository contains an early release of the model developed for predicting brain age in individuals ages 9-19, used in:

> Deviations from typical brain development are associated with adversity, depression, and poor functional outcomes in at-risk youth (Drobinin, nd)


![Prediction example](https://github.com/GitDro/DevelopmentalBrainAge/blob/master/figures/brainAge_forbow_bubble_MAE.pdf)


## Model description and requirements

* The model requires FreeSurfer processed data, exported to tabulated HCP-wide style format. One individual per row, with brain features as separate columns. See `feature_list.txt` for feature list and naming convention.

* Machine learning was performed within the [tidymodels](https://www.tidymodels.org/) framework in R, using [xgboost](https://xgboost.ai/) as the engine. Model preparation and cross-validation is described in `model-prep.R`, model tuning and fit is described in `train-fit-model.R`. __XGboost version 1.0.0.2__ tested, installation process described below:

```{r}
packageUrl <- "https://cran.r-project.org/src/contrib/Archive/xgboost/xgboost_1.0.0.2.tar.gz"
# You then install this version of the package using
install.packages(packageUrl, repos = NULL, type = 'source')
```

## Making predictions on new data

1. Load your tabulated data compliant with `feature_list` naming scheme. See above.
2. Load the model `xgboost_9to19_brain_age_mod.rds`

```{r}
library(here) # OS agnostic relative paths (relative to project dir)
library(tidyverse) # data wrangling tools and pipes
library(tidymodels) # machine learning metaverse
library(xgboost) # main engine, needs version 1.0.0.2, see above

xgb_mod <- readRDS(
  file = here::here(
    "model",
    "xgboost_9to19_brain_age_mod.rds"))
```

3. Predict brain age in your data

```{r}
brain_age_df <-
  xgb_mod %>%
  predict(new_data = your_df) %>%
  mutate(
    # provide the chronological age at time of scan
    truth = your_df$scan_age
  ) %>%
  # compute the brain age gap by subtracting chronological age from prediction
  mutate(gap = .pred - truth)
```

4. Evaluate brain age prediction accuracy

```{r}
# compute common performance metrics: mae, rsq, rmse

brain_age_df %>%
  metrics(truth = truth, estimate = .pred)
```


5. (Optional) For improved visualization, bias correct brain age prediction using slope and intercept determined from prior independent validation.

```{r}
# bias prediction method, steps in comments,
# previously determined values hardcoded.
# xgb_bias_mod <- lm(.pred ~ truth, data = xgb_validate)

# extract intercept and slope
bias_intercept <- 6.41 # xgb_bias_mod$coefficients[["(Intercept)"]]
bias_slope <-  0.55 # xgb_bias_mod$coefficients[["truth"]]

# create bias correct data frame
brain_age_corrected_df <- brain_age_df %>%
  mutate(
    # corrected brain age prediction
    corrected_pred =  (.pred - bias_intercept) / bias_slope
  ) %>%
  # corrected corrected brain age gap
  mutate(corrected_gap = corrected_pred - truth)
```
