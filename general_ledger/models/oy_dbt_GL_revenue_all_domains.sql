
select 		year
			, month
			, first_date
			, Client_ID
			, Client_Account_Name
			, business_domain
			, sum(Revenue_USD) as Revenue_USD
from 		{{ ref('oy_dbt_GL_top_10_kpi') }}
where 		1=1
			--AND Revenue_USD > 0
			AND GL_Accounting_Name_Group = 'income'
group by	1,2,3,4,5,6