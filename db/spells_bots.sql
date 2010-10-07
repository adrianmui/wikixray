create table revs_bots as select year(rev_timestamp) theyear, month(rev_timestamp) themonth, count(*) num_revs from revision where rev_user!=0 and rev_user in (select ug_user from user_groups where ug_group='bot') group by year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp);

create table revs_logged as select year(rev_timestamp) theyear, month(rev_timestamp) themonth, count(*) num_revs from revision where rev_user!=0 group by year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp);

create table revs_all as select year(rev_timestamp) theyear, month(rev_timestamp) themonth, count(*) num_revs from revision  group by year(rev_timestamp), month(rev_timestamp) order by year(rev_timestamp), month(rev_timestamp);

select bot.theyear, bot.themonth, (bot.num_revs/tot.num_revs)*100 perc_revs from revs_bots as bot, revs_all as tot where bot.theyear=tot.theyear and bot.themonth=tot.themonth;

select bot.theyear, bot.themonth, (bot.num_revs/logged.num_revs)*100 perc_logged_revs from revs_bots as bot, revs_logged as logged where bot.theyear=logged.theyear and bot.themonth=logged.themonth;