drop view if exists revision_FAs;
drop table if exists revision_FAs;
CREATE table revision_FAs AS (SELECT * FROM revision WHERE rev_page IN (SELECT page_id FROM page_FAs));
alter table revision_FAs add primary key (rev_id);
alter table revision_FAs add key (rev_user);
alter table revision_FAs add key (rev_timestamp);