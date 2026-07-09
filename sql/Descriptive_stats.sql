#Descriptive Statistics Group By Churn 0/1
#描述性统计初步分析
SELECT 
	Churn,
	SUM(gender) AS male_cnt,
	COUNT(gender) - SUM(gender) AS female_cnt,
    SUM(Near_Location) AS near,
    COUNT(Near_Location) - SUM(Near_Location) AS not_near,
    ROUND(SUM(Near_Location)/COUNT(Near_Location),2) AS near_rate,
    SUM(Partner) AS with_ptn,
    COUNT(Partner) - SUM(Partner) AS no_ptn,
    ROUND(SUM(Partner)/COUNT(Partner),2) AS with_ptn_rate,
    SUM(Promo_friends) AS promo,
    COUNT(Promo_friends) - SUM(Promo_friends) AS no_promo,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age),2) AS avg_age,
    ROUND(AVG(Avg_additional_charges_total),2) AS avg_Add_charge,
    ROUND(AVG(Month_to_end_contract),2) AS avg_months_left,
    ROUND(AVG(lifetime),2) AS avg_lifetime,
    ROUND(AVG(Avg_class_frequency_total),2) AS avg_classes
FROM gym_churn_us
GROUP BY Churn; 

