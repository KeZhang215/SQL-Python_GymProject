#Cross-analysis: age band × contract type
#会员年龄段与合同类型的交叉分析
#分析年龄段与合同类型组合对流失率的影响
#结果显示，18～25岁的月度会员流失率高达78.2%，对比36+月度会员流失率仅2.5%；
#同年龄段内，长期合同客户的流失率大幅减少，且随着年龄段增长趋于明显：
#18～25年龄段长期相比月度流失率降低约66%， 26～30约降低83%，31～35约91%，36+长期合同会员的流失率为0
#Insights：相比年轻用户，中年用户粘性更强，长期合同在各年龄段可以大幅降低流失率并随着年龄段增长而更加明显。
SELECT age, COUNT(*) AS age_cnt; #会员年纪范围[18,41]
WITH df AS(
SELECT
  CASE WHEN Age <= 25 THEN '18-25'
       WHEN Age <= 30 THEN '26-30'
       WHEN Age <= 35 THEN '31-35'
       ELSE '36+' END AS age_band,
  CASE WHEN Contract_period = 1 THEN 'month-to-month'
       ELSE 'longer_term' END AS contract_type, 
  COUNT(*) AS members,
  ROUND(AVG(Churn), 3) AS churn_rate
FROM gym_churn_us
GROUP BY age_band, contract_type
ORDER BY age_band, churn_rate DESC)

#% share of total membership base 
#29%的客户集中在26～30年龄段+月度，且流失率高达46.4%，22%集中在26～30的长期客户，两者人数占总比51%
#说明该群体不仅规模最大，也是重要的流失风险来源，应优先转化为长期合同用户。
SELECT
  age_band,
  contract_type,
  members,
  churn_rate,
  CONCAT(ROUND(100.0 * members / SUM(members) OVER (), 0),'%') AS pct_of_base
FROM df
GROUP BY age_band, contract_type
ORDER BY churn_rate DESC
