CREATE OR REPLACE VIEW page_articles AS (SELECT page_id FROM page WHERE page_namespace=0);

CREATE OR REPLACE VIEW revision_articles AS (SELECT rev_id, rev_user, rev_page FROM revision WHERE rev_user!=0 AND rev_page IN (SELECT page_id FROM page_articles));

CREATE OR REPLACE VIEW revision_FAs AS (SELECT rev_id, rev_user, rev_page FROM revision WHERE rev_user!=0 AND rev_page IN (SELECT page_id FROM page_FAs));

CREATE OR REPLACE VIEW author_total_edits AS (SELECT rev_user, COUNT(*) AS total_edits FROM revision_articles GROUP BY rev_user);

CREATE OR REPLACE VIEW author_FAs_edits AS (SELECT rev_user, COUNT(*) AS FAs_edits FROM revision_FAs GROUP BY rev_user);

CREATE OR REPLACE VIEW author_total_pages AS (SELECT rev_user, COUNT(DISTINCT(rev_page)) AS total_pages FROM revision_articles GROUP BY rev_user);

CREATE OR REPLACE VIEW author_FAs_pages AS (SELECT rev_user, COUNT(DISTINCT(rev_page)) AS FAs_pages FROM revision_FAs GROUP BY rev_user);

DROP TABLE IF EXISTS reputation_eb;

CREATE TABLE reputation_eb AS (SELECT a.rev_user, (b.FAs_edits/a.total_edits) AS rep_eb FROM author_total_edits AS a, author_FAs_edits AS b WHERE a.rev_user=b.rev_user);

INSERT INTO reputation_eb (SELECT rev_user, 0 AS FAs_edits FROM author_total_edits WHERE rev_user NOT IN (SELECT rev_user FROM author_FAs_edits));

DROP TABLE IF EXISTS reputation_pb;

CREATE TABLE reputation_pb AS (SELECT a.rev_user, (b.FAs_pages/a.total_pages) AS rep_pb FROM author_total_pages AS a, author_FAs_pages AS b WHERE a.rev_user=b.rev_user);

INSERT INTO reputation_pb (SELECT rev_user, 0 as FAs_pages FROM author_total_pages WHERE rev_user NOT IN (SELECT rev_user FROM author_FAs_pages));

DROP TABLE IF EXISTS rating_eb;

CREATE TABLE rating_eb AS (SELECT a.rev_page, (SUM(b.rep_eb)/COUNT(*)) AS rat_eb FROM revision_articles AS a, reputation_eb AS b WHERE a.rev_user=b.rev_user GROUP BY rev_page);

CREATE OR REPLACE VIEW page_author AS (SELECT rev_page, rev_user FROM revision_articles GROUP BY rev_page, rev_user);

DROP TABLE IF EXISTS rating_ab;

CREATE TABLE rating_ab AS (SELECT a.rev_page, (SUM(b.rep_pb)/COUNT(*)) AS rat_ab FROM page_author AS a, reputation_pb AS b WHERE a.rev_user=b.rev_user GROUP BY rev_page);

