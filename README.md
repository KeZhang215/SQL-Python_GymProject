# Gym Member Churn Analysis

End-to-end churn analysis of a fitness-club membership base, built as a four-layer analytical pipeline — **Descriptive → Diagnostic → Predictive → Decision** — using MySQL for SQL analysis and Python for modeling.

> **Data note:** This project uses a public benchmark dataset (Adrian Vinueza "Gym customers features and churn"), a curated teaching dataset of 4,000 members. It is used to demonstrate an end-to-end analytical methodology, **not** to claim real-world findings. The near-perfect model performance (ROC-AUC ≈ 0.97) reflects the curated nature of the data; real-world churn models typically reach 0.75–0.85.

---

## Objective

Identify the behavioral and contractual drivers of member churn (overall churn rate **26.5%**) and translate them into a prioritized, actionable retention strategy.

## Tech Stack

| Layer | Tools |
|---|---|
| Data storage & querying | MySQL (aggregation, `CASE` bucketing, window functions: `NTILE`, `LAG`, `SUM() OVER ()`) |
| EDA & modeling | Python · pandas · scikit-learn · statsmodels |
| Visualization | matplotlib · seaborn |

## Dataset

4,000 members × 14 features, 0 nulls / 0 duplicates. Key fields:

| Field | Description |
|---|---|
| `Churn` | Target — cancelled in the current month (1) or retained (0) |
| `Lifetime` | Months since the member first joined |
| `Contract_period` | Contract length in months (1 = month-to-month, 6, 12) |
| `Month_to_end_contract` | Months remaining on current contract |
| `Group_visits` | Whether the member attends group classes |
| `Avg_class_frequency_current_month` | Avg. class attendance frequency in the most recent month |
| `Avg_class_frequency_total` | Avg. class attendance frequency over full membership |
| `Avg_additional_charges_total` | Total spend on ancillary services (café, PT, etc.) |
| `Age`, `gender`, `Near_Location`, `Partner`, `Promo_friends`, `Phone` | Demographic / acquisition attributes |

*All feature values describe the previous month; `Churn` is measured in the current month, giving a clean predict-ahead setup. Class-frequency units are not specified by the source; value ranges (0–6) suggest classes per week. `gender` encoding direction (which value is which) is not documented.*

---

## Repository Structure

```
.
├── sql/
│   ├── Descriptive_stats.sql          # Layer 1: feature profiles grouped by churn
│   ├── Tenure_class_freqSegment.sql   # Layer 2: tenure cohorts + NTILE(5) engagement quintiles
│   ├── ContractType_groupVisits.sql   # Layer 2: contract × group-visit cross-analysis
│   └── ageBand_contractType.sql       # Layer 2: age band × contract type cross-analysis
├── notebooks/
│   └── Gym_SQL.ipynb                  # Layers 3–4: EDA, logistic regression, threshold tuning
├── outputs/                           # Query result CSVs
├── data/
│   └── gym_churn_us.csv               # Source dataset
└── report/
    └── Gym_Churn_Analysis_Report.md   # One-page findings summary
```

---

## The Four-Layer Pipeline

**1. Descriptive (SQL)** — Baseline profiles of retained vs. churned members. Churned members average 1.0 months tenure (vs. 4.7), 1.5 classes (vs. 2.0), and 1.7 months left on contract (vs. 5.3).

**2. Diagnostic (SQL window functions)** — Segmentation to locate *where* churn concentrates:
- **Tenure cohorts:** first-month churn **82.8%** → 0.3% beyond 7 months.
- **Engagement quintiles (`NTILE(5)`):** monotonic gradient, 54.0% (lowest) → 3.3% (highest).
- **Cross-analyses:** month-to-month + no group classes = **47.5%** churn (36% of the base); 18–25 + month-to-month = **78.2%**.

**3. Predictive (Python)** — EDA (distributions, churn-grouped boxplots, correlation heatmap, VIF), multicollinearity handling (dropped `Month_to_end_contract` and `Avg_class_frequency_total`, each ~0.95+ correlated with a retained feature), then a standardized logistic regression. **Test ROC-AUC = 0.967.**

**4. Decision** — Standardized coefficients ranked as business drivers (`Lifetime` dominant at −3.81; demographics near zero); classification threshold tuned 0.50 → 0.35 to raise churn recall 0.82 → 0.88, reflecting that a missed churner costs more than a false alarm.

---

## Key Takeaways

- Churn is an **early-lifecycle** problem — the first 90 days dominate.
- **Contract length** and **recent class engagement** are the strongest levers; **demographics barely matter.**
- The **26–30 month-to-month** segment (29% of base, 46.4% churn) is the single largest convertible opportunity.

Full findings and recommendations: [`Gym_Churn_Analysis_Report.md`](Gym_Churn_Analysis_Report.md)


*Dataset source: Adrian Vinueza "Gym customers features and churn" dataset (publicly redistributed on Kaggle).
 https://www.kaggle.com/datasets/adrianvinueza/gym-customers-features-and-churn/data*
