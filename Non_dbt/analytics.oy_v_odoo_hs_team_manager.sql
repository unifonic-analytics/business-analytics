drop view if exists analytics.oy_v_odoo_hs_team_manager
;
create view analytics.oy_v_odoo_hs_team_manager as 
with base as
(
select 			count(hc.name) over (partition by hc.name, ht.name) as cnt,
				hc.id
				, case when hc.name = 'Mobile telecommunication Company Saudi arabia Zain KSA' then 5147 else hc.odoo_id end as odoo_id
				, hc.name
				, case when hc.name = 'Mobile telecommunication Company Saudi arabia Zain KSA' then 'KSA Enterprise - BFSI' else ht.name end as team
				, case when hc.name = 'Mobile telecommunication Company Saudi arabia Zain KSA' then 'Nawaf Alharbi' else ow.first_name||' '||ow.last_name end as manager
				, case when hc.name = 'Mobile telecommunication Company Saudi arabia Zain KSA' then 'nalharbi@unifonic.com' else ow.email end as email
				, hc.customer_support_manager
				, hc.tcsm_manager
				, hc.hubspot_team_id
				, hc.hubspot_owner_id
from 			(select * from raw.hubspot__companies) as hc
------
left join 		(select * from raw.hubspot__owners) as ow 
on 				hc.hubspot_owner_id = ow.id
------
left join 		(select * from raw.hubspot__owner_teams where is_primary = true order by name) as ht 
on				ow.id = ht.owner_id
------
where 			1=1
------
order by 		hc.name
)
select 		distinct 
			orp.id as odoo_id
			, orp.ref as hs_id
			, orp.name  as odoo_name
			, orp.email
			, coalesce(l1.name, l2.name) as hs_name
			, coalesce(l1.team, l2.team) as hs_team
			, coalesce(l1.manager, l2.manager) as hs_manager
			, coalesce(l1.email, l2.email) as hs_email
			, coalesce(l1.customer_support_manager, l2.customer_support_manager) as cs_manager
			, coalesce(l1.tcsm_manager, l2.tcsm_manager) as tcsm_manager
from 		(select * from raw.odoo__res_partner) as orp
left join 	(
			select * from base 
			where cnt=1 or odoo_id is not null order by cnt desc, name, team
			) as l1
on 			orp.id = l1.odoo_id
left join 	(
			select * from base
			where cnt=1 or odoo_id is not null order by cnt desc, name, team
			) as l2
on 			orp.ref = l2.id::VARCHAR
where 		1=1
			and orp.id not in ('5147', '3521', '5146', '10523') -- as per Chan's request https://unifonic.slack.com/archives/C04JKD4DZQR/p1685692826040129
			or (orp.id = 5147 and hs_name = 'Mobile telecommunication Company Saudi arabia Zain KSA') -- https://unifonic.slack.com/archives/C03EWMPSPNU/p1687441480709609?thread_ts=1687270549.177789&cid=C03EWMPSPNU
--			and concat(hs_name,hs_team)  in 
--											(
--											select 		distinct concat(name, team)
--											from		(
--														select 		distinct name, team, manager
--																	, rank() over (partition by name, team order by manager, team) as rnk 
--														from 		base where cnt>1 
--														order by 	name
--														)x
--											where		rnk>1
--										 	)
;