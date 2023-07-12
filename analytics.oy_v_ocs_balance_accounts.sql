drop view if exists analytics.oy_v_ocs_balance_accounts
;
create view analytics.oy_v_ocs_balance_accounts as
select 			a.*
				, b.account_id as charging_id 
				, da.pd_user_account_name, da.pd_user_user_name
				, lm.Master_Account_Name, lm.Master_Account_ID, da.pd_user_id 
				, ca.units as YTD_units_23, ca.charge as YTD_charge_23, round(ca.cdr_revenue,2) as YTD_revenue_23
from 			(select* from raw.ocs__balance) as a
left join		raw.ocs__account as b
on 				a.account_id = b.id
---
left join 		(select * from standard.dim_accounts) as da
on 				b.account_id = da.charging_id::VARCHAR2 
---
left join 		(select * from analytics.lm_v_master_account_mapping) as lm
on 				b.account_id = lm.Charging_ID_L0::VARCHAR2 
---
left join 		(
				select 		ca.account_id as charging_id
							--, ca.bundle_name
							, case 	when split_part(trim(ca.bundle_name), '_', 2)='mb' then 1 else 2 end as bundle_type
							, sum(units) as units, sum(charge) as charge
							, sum(revenue) as cdr_revenue
				from 		aggregate.fact_sms_consumption_aggregate as ca
				left join 	standard.dim_accounts as da
				on 			ca.account_id = da.charging_id
				where 		ca.event_type = 'default.sms'
							and date(hour_nk) >= '2023-01-01'
				group by	1,2
				order by 	ca.account_id
			) as ca 
on 			b.account_id = ca.charging_id and a.balance_type = ca.bundle_type
;