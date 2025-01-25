library(wooldridge)
library(readxl)
library(ggplot2)
library(car)
library(lmtest)
library(sandwich)
library(fpp3)
#library(pagedown)

# Questions: 1) Which controllable factors influence the Concrete compressive strength?
#            2) What is the effect of an additional day in the Concrete compressive strength?

concrete <- read_excel('data_group_D.xls')
View(concrete)

nrow(concrete)
# 1030 observations

colnames(concrete)

summary(concrete)
# No missisng values

cor(concrete,concrete)
# No perfect multicollinearity
                    
# Plot scatterplots to evaluate relationships between
# the target and each independent variable
## Cement variable

ggplot(concrete,aes(x=`Cement (component 1)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Blast Furnace Slag variable

ggplot(concrete,aes(x=`Blast Furnace Slag (component 2)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Fly ash

ggplot(concrete,aes(x=`Fly Ash (component 3)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Water

ggplot(concrete,aes(x=`Water  (component 4)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Superplasticizer

ggplot(concrete,aes(x=`Superplasticizer (component 5)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Coarse Aggregate

ggplot(concrete,aes(x=`Coarse Aggregate  (component 6)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Fine Aggregate

ggplot(concrete,aes(x=`Fine Aggregate (component 7)(kg in a m^3 mixture)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

## Age

ggplot(concrete,aes(x=`Age (day)`,
                    y=`Concrete compressive strength(MPa, megapascals)`)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()

# No clear relationships that would require transformations, we will
# now proceed with model specification

# Asumptions: 1) Linearity of parameters
#             2) Data comes from random sampling
#             3) Variables are not perfectly correlated
#             4) We include all relevant factors in our study, the ones left (like temperature and humidity) aren't
#                correlated with the rest of our variables
#             5) We will test and deal with heteroskedasticity along the process
#             6) Assymptotic normality of residuals and estimators since we have a large sample (1030 observations)


# Initial model

reg_ur <- lm(`Concrete compressive strength(MPa, megapascals)` ~ `Cement (component 1)(kg in a m^3 mixture)` +           
          `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
          `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
          `Water  (component 4)(kg in a m^3 mixture)` +           
          `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
          `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
          `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
          `Age (day)`, data=concrete)

summary(reg_ur)

# Heteroskedacity testing

bptest(reg_ur)

# We know that we have heteroskedacity in our model, so we will use the robust
# estimators for hypothesis testing from now on

# Hypothesis Testing

# T-tests: Initial Modelling 
coeftest(reg_ur, vcov=hccm)

# We can see that two of our variables are individually insignificant at a 5%
# significance level we will perform a F-test to see whether 
# they're jointly insignificant

# F-Test for `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` and
# Fine Aggregate (component 7)(kg in a m^3 mixture) variables
# h0: beta6 = beta7 = 0
# h1: beta6 != 0 or beta7 != 0

reg_r <- lm(`Concrete compressive strength(MPa, megapascals)` ~ `Cement (component 1)(kg in a m^3 mixture)` +   
               `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
               `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
               `Water  (component 4)(kg in a m^3 mixture)` +           
               `Superplasticizer (component 5)(kg in a m^3 mixture)` +
               `Age (day)`, data=concrete)

waldtest(reg_r, reg_ur, vcov = vcovHC(reg_ur, type="HC0"))

# We can conclude that these variables are not jointly significant at 5% significance level

cor(concrete,select(concrete, c('Fine Aggregate (component 7)(kg in a m^3 mixture)',
                                'Coarse Aggregate  (component 6)(kg in a m^3 mixture)')))

# But after seeing the correlation between those that are going to be removed with the rest
# of the explanatory variables, we see that they are slightly correlated, so we wont remove them
# to ensure that we have zero conditional mean, they will serve as control variables

# Testing whether the initial model is defined well, using a manual RESET test

reg_y <- lm(`Concrete compressive strength(MPa, megapascals)` ~ `Cement (component 1)(kg in a m^3 mixture)` +           
              `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
              `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
              `Water  (component 4)(kg in a m^3 mixture)` +           
              `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
              `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
              `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
              `Age (day)` + I(fitted(reg_ur)^2) + I(fitted(reg_ur)^3)
            , data=concrete)

waldtest(reg_ur, reg_y, vcov = vcovHC(reg_y, type="HC0"))
# 27.062, p-value = 3.537e-12 ***

# The model is not well specified, so we will apply some changes to the specification


# Modelling age as quadratic term 
# we tried this change because different literatures suggest that after a certain period of time the 
# Concrete compressive strength doesn't change in the same proportion
# We will also perform another RESET test

reg_ur <- lm(`Concrete compressive strength(MPa, megapascals)` ~ `Cement (component 1)(kg in a m^3 mixture)` +           
               `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
               `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
               `Water  (component 4)(kg in a m^3 mixture)` +           
               `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
               `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
               `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
               `Age (day)` + I(`Age (day)`^2), data=concrete) 

reg_y <- lm(`Concrete compressive strength(MPa, megapascals)` ~ `Cement (component 1)(kg in a m^3 mixture)` +           
              `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
              `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
              `Water  (component 4)(kg in a m^3 mixture)` +           
              `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
              `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
              `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
              `Age (day)` + I(`Age (day)`^2) + I(fitted(reg_ur)^2) + I(fitted(reg_ur)^3)
            , data=concrete)

waldtest(reg_ur, reg_y, vcov = vcovHC(reg_y, type="HC0"))
# 10.973 p-value = 1.927e-05 ***

# The model is still not well specified, so we will apply some more changes to the specification

# We will tried log transformations in our explanatory variables (cement and water) to have their interpretation
# in percentages instead of total values.

# Modeling age as quadratic term and Cement as a logarithm

reg_ur <- lm(`Concrete compressive strength(MPa, megapascals)` ~ log(`Cement (component 1)(kg in a m^3 mixture)`) +           
               `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
               `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
               `Water  (component 4)(kg in a m^3 mixture)` +           
               `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
               `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
               `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
               `Age (day)` + I(`Age (day)`^2), data=concrete) 

reg_y <- lm(`Concrete compressive strength(MPa, megapascals)` ~ log(`Cement (component 1)(kg in a m^3 mixture)`) +           
              `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
              `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
              `Water  (component 4)(kg in a m^3 mixture)` +           
              `Superplasticizer (component 5)(kg in a m^3 mixture)` + 
              `Coarse Aggregate  (component 6)(kg in a m^3 mixture)` +
              `Fine Aggregate (component 7)(kg in a m^3 mixture)` +
              `Age (day)` + I(`Age (day)`^2) + I(fitted(reg_ur)^2) + I(fitted(reg_ur)^3)
            , data=concrete)

waldtest(reg_ur, reg_y, vcov = vcovHC(reg_y, type="HC0"))
# 2.1379 p-value = 0.1184

# The model is now well specified with the log cement transformation so we wont try the log in water.

# Now we will answer the proposed questions

# 1) Which controllable factors influence the Concrete compressive strength?
reg_r <- lm(`Concrete compressive strength(MPa, megapascals)` ~ log(`Cement (component 1)(kg in a m^3 mixture)`) +           
              `Blast Furnace Slag (component 2)(kg in a m^3 mixture)` +
              `Fly Ash (component 3)(kg in a m^3 mixture)`  +         
              `Water  (component 4)(kg in a m^3 mixture)` +           
              `Age (day)` + I(`Age (day)`^2), data=concrete)

waldtest(reg_r, reg_ur, vcov = vcovHC(reg_ur, type="HC0"))

cor(concrete,select(concrete, c('Fine Aggregate (component 7)(kg in a m^3 mixture)',
                                'Coarse Aggregate  (component 6)(kg in a m^3 mixture)',
                                'Superplasticizer (component 5)(kg in a m^3 mixture)')))

# We can conclude that these variables are not jointly significant at 5% significance level
# So they are not relevant for the Concrete compressive strength (we don't remove them because
# we might have issues with the have zero conditional mean assumption since some are correlated with our explanatory variables)

# R: Cement, Blast Furnace Slag, Fly Ash, Water and Age are controllable factors that influence
# the compressive strength of concrete.

# 2) What is the effect of an additional day in the Concrete compressive strength?
summary(reg_ur)

coeftest(reg_ur, vcov=hccm)

# R: 0.35258 - 2 * 0.00081934 * days
# For an additional day the Concrete compressive strength will increase 0.35258 - 2 * 0.00081934 * days (ceteris paribus),
# it has a small negative quadratic effect, this means that after 215 days the return of age (in days) on concrete compressive 
# strength starts do decrease (the return of an extra day becomes negative).

# pagedown::chrome_print("script_group_D.html")
