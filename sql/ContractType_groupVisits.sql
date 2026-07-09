#CROSS ANALYSIS 交叉分析
#contract_type x group_visits 合同类型x团课参与
#观察客户合同类型（月度/半年/年度会员）与是否参加团课（0/1）对流失率的影响；
#结果得出“月付+不上团课”的流失率最严重为47.5%，“年卡+上团课”仅1.5%
#同样合同类型中，参与团课可以显著降低流失率；团课参与保持恒定，客户的合同时限越长流失率越低
#并且从churn_percentage_change看，流失率沿着“月付不上团课 → 月付上团课 → 半年 → 年付”的风险排序逐级大幅下降，
#说明更长合约和团课参与都与更低流失率明显相关；
#以降低客户流失率，推荐长期合约并推销团课是最优解。
WITH contType_group AS (
SELECT 
	CASE 
		WHEN contract_period = 1 THEN 'month-to-month'
        WHEN contract_period = 6 THEN 'semi-annualy'
        ELSE 'annually' END AS contract_type,
	CASE
		WHEN group_visits = 0 THEN 'no_group'
        ELSE 'with_group' END AS group_participation,
	COUNT(*) AS members_cnt,
    SUM(churn) AS churned,
    ROUND(AVG(churn),3) AS churn_rate
FROM gym_churn_us
GROUP BY contract_type, group_participation
ORDER BY churn_rate DESC
),
last_churn AS (
SELECT 
	*,
    LAG(churn_rate) OVER() AS last_rate
FROM contType_group
)
SELECT 
	contract_type,
    group_participation,
    members_cnt,
    churned,
    churn_rate,
    CONCAT(ROUND(100* (last_rate - churn_rate) / last_rate,2),'%') AS churn_percentage_change
FROM last_churn;

#Segment churn rate + share of total membership base
#合同类型与团课参与分组后的会员人数占比情况
#无团课月度的用户占比最高为36%，其次是无团课长期会员23%，团课参与度不足目前是导致高流失率的拖累因素之一
SELECT
  CASE WHEN Contract_period = 1 THEN 'month-to-month' ELSE 'longer_term' END AS contract_type,
  CASE WHEN Group_visits = 1 THEN 'attends_group' ELSE 'no_group' END AS group_participation,
  COUNT(*) AS members,
  ROUND(AVG(Churn), 3) AS churn_rate,
  CONCAT(ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 0), '%') AS pct_of_base
FROM gym_churn_us
GROUP BY contract_type, group_participation
ORDER BY churn_rate DESC
