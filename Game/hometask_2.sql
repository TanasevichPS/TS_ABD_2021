--в каких матчах выйграли силы Тьмы
select m.match_id
from match m
where radiant_win = 'False';

--игроки, учавствовавшие в этих матчах
select pl.account_id
from players pl
    left outer join match m on pl.match_id = m.match_id
where pl.account_id !=0 and m.radiant_win = 'False';

--топ 3 игроков по выигришам в рассматриваемых матчах и их уровень
with rating1 as(
    --сколько раз игроки выиграли в матчах "сил Тьмы"
    select m.match_id,
           pl.account_id as player,
           pl.level,
           --max level = 25
           sum(rat.total_wins) over(partition by pl.account_id) as sum_of_wins
    from match m
        left join players pl on pl.match_id = m.match_id
        left join player_ratings rat on rat.account_id = pl.account_id
    where rat.total_wins !=0 and pl.account_id != 0 and m.radiant_win = 'False'
),
rating2 as (
    select *,
           dense_rank() over (order by sum_of_wins desc) as wins_rating
    from rating1
)
select *,
       lag(sum_of_wins) over (order by sum_of_wins desc) - sum_of_wins as wins_diff
from rating2
where wins_rating between 1 and 3;

--используемые герои
select hm.localized_name
from hero_names hm
    left outer join players pl on pl.hero_id = hm.hero_id
    left outer join match m on pl.match_id = m.match_id
where pl.account_id !=0 and m.radiant_win = 'False';

--каких героев используют игроки,
-- какие их способности и сколько раз применялась способность
select distinct m.match_id,
       pl.account_id as player,
       hm.localized_name as hero_name,
       aid.ability_name,
       count(aid.ability_name) over(partition by aid.ability_name) as ability_used
from match m
    left join ability_upgrades au on au.match_id = m.match_id
    left join ability_ids aid on aid.ability_id = au.ability
    left join players pl on m.match_id = pl.match_id
    left join hero_names hm on hm.hero_id = pl.hero_id
where pl.account_id !=0 and m.radiant_win = 'False'
limit(10);

--урон
select pl.match_id,
       percentile_cont(0.10) within group ( order by pl.hero_damage asc )as damage_10,
       percentile_cont(0.90) within group ( order by pl.hero_damage asc ) as damage_90
from players pl
    left outer join match m on pl.match_id = m.match_id
where pl.account_id !=0 and m.radiant_win = 'False'
group by pl.match_id;

--в работе использованы: cte, over, partition by, dense_rank, lag, percentile_cont

--топ 5 игроков собравших золота с разрушения зданий и убийства др героев
with cte1 as(
    select m.match_id,
           pl.account_id as player,
           pl.gold_destroying_structure as gds,
           pl.gold_killing_heros as gdh
    from match m
        left join players pl on pl.match_id = m.match_id
    where pl.account_id != 0 and m.radiant_win = 'False'
),
cte2 as (
    select *,
           (gds + gdh) as gold
    from cte1
),
cte3 as (
    select *,
           row_number() over (order by gold desc) as gold_rating
    from cte2
)
select player,
       gold_rating
from cte3
where gold_rating between 1 and 5;