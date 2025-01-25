# Optimal Concrete Production: Regression Analysis

## Project Overview
This project investigates the factors that influence the compressive strength of concrete using regression analysis. The aim was to identify the most critical controllable variables in concrete production and assess the effect of curing time (age) on the material's strength. The analysis is based on a publicly available dataset and conducted using R.

## Objectives
The objectives of this project were:
1. Identify which controllable factors (e.g., cement, water) influence concrete compressive strength.
2. Analyze the effect of curing time (age) on compressive strength.
3. Develop a regression model to provide actionable insights for optimizing concrete production.

## Problem Statement
Concrete is a globally essential material, and optimizing its production can lead to stronger, more durable structures. However, understanding the relationship between its components and strength is complex. This project aimed to simplify this complexity by applying regression analysis to identify key variables and quantify their impacts.

## Methodology
### Dataset
The dataset includes information on:
- **Input Variables**: Quantities of cement, blast furnace slag, fly ash, water, superplasticizer, coarse aggregate, fine aggregate, and curing time (age in days).
- **Target Variable**: Compressive strength (measured in MPa).

### Data Analysis
1. **Exploratory Analysis**:
   - Plotted input variables against compressive strength to check for transformations.
   - No obvious transformations were required initially.

2. **Model Development**:
   - Conducted multiple linear regression (MLR) analysis in R.
   - Checked MLR assumptions, including multicollinearity, zero conditional mean, and heteroskedasticity.
   - Adjusted the model by applying logarithmic and quadratic transformations for cement and age, respectively, to improve specification.

3. **Statistical Tests**:
   - Performed t-tests to check individual variable significance.
   - Conducted F-tests to evaluate joint insignificance of variables.
   - Used the Breusch-Pagan test to identify heteroskedasticity and applied robust estimators.

### Final Model
The final model equation:

Concrete Strength = -87.63 + 28.21 * log(Cement) + 0.085 * Slag + 0.059 * Fly Ash - 0.233 * Water + 0.152 * Superplasticizer - 0.007 * Coarse Aggregate - 0.008 * Fine Aggregate + 0.353 * Age - 0.00082 * Age²

## Results
1. **Key Factors**:
   - Significant controllable variables: Cement, slag, fly ash, water, and age.
   - Cement had the largest positive impact on strength, while water had a negative impact.
2. **Age Effect**:
   - Strength increases with age but begins to diminish after 215 days due to a quadratic relationship.
3. **Model Performance**:
   - Adjusted \( R^2 \): 0.7416
   - All significant variables met MLR assumptions after adjustments.

## Conclusions
- **Insights**:
  - Optimizing cement content and reducing water improves concrete strength.
  - The curing process is critical, with diminishing returns after 215 days.
- **Implications**:
  - Manufacturers can use these findings to design cost-effective and high-strength concrete mixes.
- **Limitations**:
  - The dataset lacks environmental factors (e.g., temperature, humidity) that could impact results.

## Deliverables
- Poster summarizing findings and methodology.
- R code for analysis and model specification.
- Dataset used for regression analysis.