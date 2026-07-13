# Gym Member Churn Analysis

**Objective:** Identify the behavioral and contractual drivers of member churn and translate them into a prioritized retention strategy.<br> 
**Stack:** MySQL (descriptive & diagnostic analysis, window functions) · Python / scikit-learn (EDA, logistic regression) · matplotlib / seaborn (visualization)<br>
**Data:** “Gym customers features and churn” By Adrian Vinueza - *Behavior features of customers to predict churn and determine churn rate* https://www.kaggle.com/datasets/adrianvinueza/gym-customers-features-and-churn

---

## Approach

I structured the analysis as a four-layer pipeline that mirrors the analytics maturity model — **Descriptive → Diagnostic → Predictive → Decision**:

1. **Descriptive (MySQL Aggregation):** Aggregated all features grouped by churn status to establish baseline profiles of retained vs. churned members.
2. **Diagnostic (MySQL window functions):** Built tenure cohorts, quintile-segmented engagement with `NTILE(5)`, and ran two-way cross-analyses (contract type × group participation; age band × contract type) using `LAG()` and `SUM() OVER ()` to quantify segment risk and size.
3. **Predictive (Python):** Performed EDA (distributions, churn-grouped boxplots, correlation heatmap, VIF), addressed multicollinearity, and trained a standardized logistic regression.
4. **Decision:** Interpreted standardized coefficients as business drivers and tuned the classification threshold around the cost asymmetry of retention errors.

---

## Key Findings

**1. Tenure is the single dominant driver.** Churn is overwhelmingly an early-lifecycle problem: members in their first month churn at 82.8%, dropping to 4.0% at 4–6 months and 0.3% beyond 7 months. Lifetime carried the largest standardized logistic coefficient by a wide margin (−3.81).

**2. Contract length and engagement compound.** Cross-analysis showed month-to-month members who skip group classes churn at 47.5% — and this group is also the largest single segment at 36% of the base, making it both the highest-risk and highest-priority pool. At the opposite end, annual members who attend group classes churn at just 1.5%. Longer contracts and group participation each independently reduce churn across every tier.

**3. Age and contract type interact sharply.** The worst micro-segment is 18–25 year-old month-to-month members at 78.2% churn, versus 0% for members 36+ on longer-term contracts. Notably, 26–30 year-old month-to-month members (29% of the base, 46.4% churn) represent the largest convertible opportunity.

**4. Recent engagement is a monotonic leading indicator.** Segmenting current-month class frequency into quintiles produced a clean gradient — from 54.0% churn in the lowest quintile to 3.3% in the highest.

**5. Demographics barely matter.** Gender, neighborhood proximity, partner-company affiliation, and phone-on-file all had near-zero logistic coefficients — retention is driven by behavior and commitment, not who the member is.

**Model performance:** The logistic regression achieved a test ROC-AUC of 0.967. AUC (not accuracy) was used as the primary metric because the 26.5% class imbalance makes accuracy misleading. Lowering the decision threshold from 0.50 to 0.35 raised churn-class recall from 0.82 to 0.88 (false negatives 38 → 26), reflecting that missing an at-risk member (no intervention) is costlier than a false alarm (wasted retention spend).

---

## Recommendations

- **Own the first 90 days.** Concentrate onboarding and check-in touchpoints in months 0–3, where nearly all churn occurs.
- **Convert the 26–30 month-to-month segment.** It is the largest at-risk pool; incentivizing 6- or 12-month contracts here yields the highest absolute retention gain.
- **Drive group-class adoption**, which lowers churn within every contract tier.
- **Deploy an early-warning risk score** combining low tenure, low recent class frequency, proximity to contract end, and month-to-month status to flag members for proactive outreach.

---

*Methodology note:* The near-perfect AUC reflects the curated nature of the benchmark dataset; The value of this project lies in the reproducible analytical workflow — schema design, SQL diagnostics, multicollinearity handling, model evaluation, and threshold-based decision-making.
