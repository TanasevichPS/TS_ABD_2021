-- task1
select v.tariff as tarif,
       uniqExact(v.idhash_view) as views,
       countIf(ord.idhash_order, ord.idhash_order > 0) as orders,
       count(ord.da_dttm) as da_dttm,
       count(ord.rfc_dttm) as rfc_dttm,
       count(ord.cc_dttm) as cc_dttm,
       countIf(ord.status, ord.status = 'CP' ) as status
from data_analysis.orders as ord
right join data_analysis.views as v on ord.idhash_order = v.idhash_order
--where ord.finish_dttm != 0
group by tarif;

--task2
select  v.idhash_client as client,
        --v.tariff,
        max(v.tariff) as top_tarif,
        uniqExact(v.tariff) as sum_kind_tarifs
FROM data_analysis.views as v
--where  v.idhash_client = 2890041150
group by client
order by top_tarif desc;

--task3
-- гексагоны h3
SELECT h3,
       utro,
       night,
       --order_dttm,
       count(h3) as num_orders
from (
select ord.order_dttm,
       multiIf( toHour(ord.order_dttm) = 7 or toHour(ord.order_dttm) = 8 or
                toHour(ord.order_dttm) = 9 or toHour(ord.order_dttm) = 10,
                'utro', 'ne utro') as utro,
       multiIf( toHour(ord.order_dttm) = 18 or toHour(ord.order_dttm) = 19 or
                toHour(ord.order_dttm) = 20,'night', 'ne night') as night,
      geoToH3(v.longitude, v.latitude, 7) as h3
from data_analysis.orders as ord
right join data_analysis.views as v on ord.idhash_order = v.idhash_order
group by ord.order_dttm, utro, h3
)
where utro = 'utro' or night = 'night'
group by h3, utro, night
order by num_orders desc
limit 10;

--task4
select median(diff_s) as median_sec,
       --max(diff_s) as mx,
       --quantileIf(0.95)(diff_s,diff_s > 0) as perc_95,
       plus(
            intDiv(quantileIf(0.95)(diff_s,diff_s > 0),60),
            divide(
            round(modulo(quantileIf(0.95)(diff_s,diff_s > 0),60)),
            10)) as perc_95_min

from(
select toDate(order_dttm) as date_1,
       toDate(da_dttm) as date_2,
              -- idhash_order as id,
        order_dttm,da_dttm,
        dateDiff('second', order_dttm, da_dttm) as diff_s
        from data_analysis.orders
        where status = 'CP' and date_1 = date_2
        group by order_dttm,da_dttm
        --order by diff_s desc
         );