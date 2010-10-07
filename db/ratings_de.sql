DROP TABLE IF EXISTS rating_eb;

CREATE TABLE rating_eb AS (SELECT a.rev_page, (SUM(b.rep_eb)/COUNT(*)) AS rat_eb FROM revision_articles AS a, reputation_eb AS b WHERE a.rev_user=b.rev_user GROUP BY rev_page);

CREATE OR REPLACE VIEW page_author AS (SELECT rev_page, rev_user FROM revision_articles GROUP BY rev_page, rev_user);

DROP TABLE IF EXISTS rating_ab;

CREATE TABLE rating_ab AS (SELECT a.rev_page, (SUM(b.rep_pb)/COUNT(*)) AS rat_ab FROM page_author AS a, reputation_pb AS b WHERE a.rev_user=b.rev_user GROUP BY rev_page);

