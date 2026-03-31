********************************************************************************
** Project: Impact of GenAI Dependence on Academic Performance
** Date: March 27, 2026
** Purpose: Data Cleaning, Descriptive Statistics, Group Difference Testing, and Regression Analysis (Ologit & OLS)
********************************************************************************
/*----------------------------------------------------------------------------*
  PART 1: DATA PRE-PROCESSING & VARIABLE STANDARDIZATION
*----------------------------------------------------------------------------*/
** Variable Coding
* Demographics (gender，origin_of_student，only_child，annual_household_income，major_field，source_of_the_institution) and core independent variables are recoded into factor levels or dummy variables.

/*----------------------------------------------------------------------------*
  PART 2: DESCRIPTIVE STATISTICS
*----------------------------------------------------------------------------*/
** 2.1 Sample Demographics (gender，origin_of_student，only_child，annual_household_income，major_field，source_of_the_institution)
tab gender
tab origin_of_student
tab only_child
tab annual_household_income
tab major_field
tab source_of_the_institution

**2.2 Core Scale Items (GenAI Dependence Scale)
tab d1
tab d2
tab d3
tab d4
tab d5
tab d6
tab d7
tab d8
tab d

**2.3 Descriptive analysis using frequency
tab sc2

**2.4 Multiple Response Analysis
* Run if not already installed
ssc install mrtab
* Using 'mrtab' to handle multi-response questions for higher statistical accuracy.
mrtab sc3_1 sc3_2 sc3_3 sc3_4 sc3_5 sc3_6 sc3_7 sc3_8 sc3_9 sc3_10 sc3_11
mrtab sc4_1 sc4_2 sc4_3 sc4_4 sc4_5 sc4_6 sc4_7 sc4_8 sc4_9 sc4_10
mrtab sc7_1 sc7_2 sc7_3 sc7_4 sc7_5 sc7_6 sc7_7 sc7_8 sc7_9

/*----------------------------------------------------------------------------*
  PART 3: ORDERED LOGIT MODEL & PROPORTIONAL ODDS TEST
*----------------------------------------------------------------------------*/
** Rationale: Academic performance is an ordinal variable; thus, Ordered Logit is used, contingent on the Parallel Odds Assumption.

** 3.1 Generating New Variable
gen self_rating_dependence=sc6

** 3.2 Installing Package for Parallel Odds Assumption Test
ssc install oparallel
/* Note: P > 0.05 indicates the model does not violate the proportional odds assumption, confirming Ologit is the appropriate estimator. */

** 3.3 Impact of Self-Rated Dependence on Performance with Control Variables
ologit self_rated_academic_performance self_rating_dependence gender origin_of_student only_child annual_household_income major_field
* Test for Parallelism (Likelihood Ratio Test)
oparallel

** 3.4 Impact of Objective Scale Score (new_d) on Performance with Control Variables
ologit self_rated_academic_performance d gender origin_of_student only_child annual_household_income major_field
oparallel

/*----------------------------------------------------------------------------*
  PART 4: GROUP DIFFERENCE TESTS (HETEROGENEITY ANALYSIS)
*----------------------------------------------------------------------------*/
** 4.1 Grouped Summary Statistics
tabstat d, stats(mean sd)
tabstat d, by(gender) stats(mean sd) columns(statistics)
tabstat d, by(origin_of_student) stats(mean sd) columns(statistics)
tabstat d, by(only_child) stats(mean sd) columns(statistics)
tabstat d, by(annual_household_income) stats(mean sd) columns(statistics)
tabstat d, by(source_of_the_institution) stats(mean sd) columns(statistics)
tabstat d, by(major_field) stats(mean sd) columns(statistics)
tabstat d, by(self_rated_academic_performance) stats(mean sd) columns(statistics)

** 4.2 Independent Samples t-test (Binary Groups)
* Testing GenAI dependence across Gender, Origin, etc.
ttest d, by(gender) 
ttest d, by(origin_of_student)
ttest d, by(only_child)
ttest d, by(major_field)
ttest d, by(source_of_the_institution)

** 4.3 One-way ANOVA (Multi-category Groups)
* Testing differences across income levels and academic performance tiers.
oneway d annual_household_income, tabulate
oneway d self_rated_academic_performance, tabulate

/*----------------------------------------------------------------------------*
  PART 5: INTER-INSTITUTION COMPARISON
*----------------------------------------------------------------------------*/
** 5.1 Descriptive Comparison of Core Dimensions (PE, EE, SE, etc.)
tabstat  pe ee se ct ap fc si, by(source_of_the_institution) stats(mean sd n) columns(statistics)

** 5.2 Significance Testing for Institutional Differences
* T-tests for core factors
ttest pe , by(source_of_the_institution)
ttest ee , by(source_of_the_institution)
ttest se , by(source_of_the_institution)
ttest ct , by(source_of_the_institution)
ttest ap , by(source_of_the_institution)
ttest fc , by(source_of_the_institution)
ttest si , by(source_of_the_institution)

/*----------------------------------------------------------------------------*
  PART 6: MULTIVARIATE REGRESSION & DIAGNOSTICS
*----------------------------------------------------------------------------*/
** 6.1 Full Sample Regression (OLS)
* Exporting results via 'asdoc' and calculating VIF for Multicollinearity checks.
asdoc reg d pe ee se ct ap fc si i.gender i.origin_of_student i.only_child i.annual_household_income i.major_field
asdoc vif
/* Note: VIF < 5 is used as the threshold to ensure no severe multicollinearity. */


** 6.2 Sub-sample Heterogeneity Analysis (By Institution)
* Institution A (source == 0)
asdoc reg d pe ee se ct ap fc si i.gender i.origin_of_student i.only_child i.annual_household_income i.major_field	 if source_of_the_institution==0
* Institution B (source == 1)
asdoc reg d pe ee se ct ap fc si i.gender i.origin_of_student i.only_child i.annual_household_income i.major_field	 if source_of_the_institution==1






