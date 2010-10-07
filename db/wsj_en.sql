create or replace view page_main_nored as (select page_id from page where page_namespace=0 and page_is_redirect=0);
create or replace view rev_main_nored as (select rev_id, rev_user, rev_page, rev_timestamp from revision where rev_page in (select page_id from page_main_nored));
create or replace view revision_logged as (select * from rev_main_nored where rev_user!=0 and rev_user not in (select ug_user from user_groups where ug_group='bot') );
create table time_range_users as (SELECT rev_user, min(rev_timestamp) min_ts, max(rev_timestamp) max_ts from revision_logged group by rev_user);
alter table time_range_users add primary key (rev_user);