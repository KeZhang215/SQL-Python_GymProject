#Segment by membership tenure, order by churn rate DESC
#按会员在籍时常分组，计算各组的会员数量，平均年龄，流失率
SELECT 
    CASE 
		WHEN lifetime = 0 THEN '1_month<'
        WHEN lifetime BETWEEN 1 AND 3 THEN '1-3month'
        WHEN lifetime BETWEEN 4 AND 6 THEN '4-6month'
        ELSE '7month+' END AS tenure_cohort,
	COUNT(*) AS members,
	ROUND(AVG(age),2) AS avg_age_cohort,
    ROUND(AVG(churn),3) AS churn_rate_cohort
FROM gym_churn_us
GROUP BY tenure_cohort
ORDER BY churn_rate_cohort DESC; 
#新会员尤其是未满一个月的流失率最高（82.8%），流失率与在籍时常成反比关系--在籍时长越少流失率越高；
#流失率与会员平均年龄成反比关系--平均来看越年轻的会员流失率越高；
#70%的会员在籍时常集中在1～6个月，新会员占比12%，大于七个月的老会员占比17%

#NTILE window function segments current month's Avg_class_frequency by 5 layers
#Avg_class_freq x churn_rate
#上课频率和流失是不是单调关系？梯度有多陡？
WITH ranked AS(
SELECT 
	*,
	NTILE(5) OVER(ORDER BY Avg_class_frequency_current_month) AS freq_rnk
FROM gym_churn_us
)
SELECT 
	freq_rnk,
	COUNT(*) AS members,
    ROUND(MAX(Avg_class_frequency_current_month),2) AS max_freq,
    ROUND(MIN(Avg_class_frequency_current_month),2) AS min_freq,
    ROUND(AVG(churn),3) AS churn_rate
FROM ranked
GROUP BY freq_rnk
ORDER BY freq_rnk;
#月度平均上课频率越低，客户流失率越高，将频率由低到高排序并分为五档，前两档的流失率最高