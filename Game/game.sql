--task_1
select count(*) as matchs
from match
where first_blood_time > 60 and first_blood_time < 180;

--task_2
select pl.account_id
from players pl
    left outer join match m on pl.match_id = m.match_id
where pl.account_id !=0 and m.positive_votes > m.negative_votes
  and m.radiant_win = 'True';

--task_3
select pl.account_id,
       avg(m.duration) as average_match_duration
from players pl
    left outer join match m on pl.match_id = m.match_id
group by pl.account_id;

--task_4
select sum(pl.gold_spent) as gold_spent,
       count(distinct pl.hero_id) as number_of_heroes,
       round(avg(m.duration),0) as average_match_duration
from players pl
    left outer join match m on pl.match_id = m.match_id
where pl.account_id =0;

--task_5
select hm.localized_name,
       count(pl.match_id) as matchs,
       avg(pl.kills) as kills,
       min(pl.deaths) as min_deaths,
       max(pl.gold_spent) as max_gold_spent,
       sum(m.positive_votes) as sum_positive_votes,
       sum(m.negative_votes) as sum_negative_votes
from hero_names hm
    left outer join players pl on pl.hero_id = hm.hero_id
    left outer join match m on pl.match_id = m.match_id
group by hm.localized_name;

--task_6
select distinct m.match_id
from match m
    left outer join purchase_log pur on pur.match_id = m.match_id
    left outer join item_ids it on it.item_id= pur.item_id
where it.item_id = 42 and (m.start_time + pur.time) > 100;

--task_7
select *
from match m
    left outer join purchase_log pur on m.match_id= pur.match_id
FETCH FIRST 20 ROWS ONLY;
