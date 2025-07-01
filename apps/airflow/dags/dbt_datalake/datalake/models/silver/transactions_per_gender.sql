with transactions_per_gender as (
    select gender, count(*) as qntd
    from "objectstore"."datalake_bronze"."users" as u
    left join "objectstore"."datalake_bronze"."transactions" as t on u.userid = t.user_id
    group by gender
)
select * from transactions_per_gender
