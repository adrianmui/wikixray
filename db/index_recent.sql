drop table if exists time_range_articles;
CREATE TABLE time_range_articles AS (select rev_page, min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') and year(rev_timestamp)<2008 group by rev_page);
alter table time_range_articles add primary key (rev_page);
drop table if exists range_authors;
create table range_authors as (select rev_user, min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from rev_main_nored where year(rev_timestamp)<2008 and rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') group by rev_user);
alter table range_authors add primary key (rev_user);

