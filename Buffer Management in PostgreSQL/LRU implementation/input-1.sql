-- This script assumes that the files are all in the same folder as the database itself.  You will need to change lines 4, 27-33
-- to fix this for your system.

\o proj2-sudhamshreddy.out

drop table teams;
drop table coaches_season;
drop table draft;
drop table players;
drop table player_rs_career;
drop table player_rs;


create table teams (tid varchar(30), location varchar(30), name varchar(30), league varchar(30), primary key (tid, league));

create table coaches_season (cid varchar(30), year int, yr_order int,
firstname varchar(30), lastname varchar(30), season_win int, season_loss int, playoff_win int, playoff_loss int, tid varchar(30), primary key (cid, year, yr_order));

create table draft (draft_year int, draft_round int, slection int, tid varchar(30), firstname varchar(30), lastname varchar(30), ilkid  varchar(30), draft_from varchar(100), league varchar(30));

create table players (ilkid varchar(30), firstname varchar(30), lastname varchar(30), position varchar(1), first_season int, last_season int, h_feet int, h_inches real, weight real, college varchar(100), birthday varchar(30), primary key (ilkid)); 

create table player_rs_career (ilkid varchar(30), firstname varchar(30), lastname varchar(30), league varchar(10), gp int, minutes int, pts int, dreb int, oreb int, reb int, asts int, stl int, blk int, turnover int, pf int, fga int, fgm int, fta int, ftm int, tpa int, tpm int);

create table player_rs (ilkid varchar(30), year int, firstname varchar(30), lastname varchar(30), tid varchar(30), league varchar(10), gp int, minutes int, pts int, dreb int, oreb int, reb int, asts int, stl int, blk int, turnover int, pf int, fga int, fgm int, fta int, ftm int, tpa int, tpm int, primary key(ilkid, year, tid));

-- 0. Under psql, load all the above tables with data obtained from the corresponding txt file. An example is : \copy teams from 'teams.txt' with delimiter ','
\copy teams from 'teams.txt' with delimiter ','
\copy coaches_season from 'coaches_season.txt' with delimiter ','
\copy players from 'players.txt' with delimiter ','
\copy player_rs from 'player_rs.txt' with delimiter ','
\copy player_rs_career from 'player_rs_career.txt' with delimiter ','
\copy draft from 'draft.txt' with delimiter ','


SELECT DISTINCT c.firstname,c.lastname,c.year FROM coaches_season c, player_rs p
WHERE c.firstname = p.firstname AND c.lastname = p.lastname AND c.year = p.year;


SELECT DISTINCT c.firstname,c.lastname,c.year FROM coaches_season c, player_rs p
WHERE c.firstname = p.firstname AND c.lastname = p.lastname 
AND c.year = p.year AND c.tid = p.tid ORDER BY c.lastname;



SELECT c.year, AVG(p.weight) FROM coaches_season c, player_rs prs, players p 
WHERE c.firstname = 'Phil' AND c.lastname = 'Jackson' AND c.year = prs.year 
AND prs.tid = c.tid AND p.ilkid = prs.ilkid
GROUP BY c.year ORDER BY c.year;


SELECT d.draft_from, COUNT(*) FROM draft d GROUP BY d.draft_from
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM draft d2 GROUP BY d2.draft_from);


SELECT c1.firstname, c1.lastname, SUM(CAST(c1.season_win AS FLOAT))/SUM(c1.season_win+c1.season_loss)
AS win_pct FROM coaches_season c1 GROUP BY c1.cid, c1.firstname, c1.lastname
ORDER BY win_pct desc LIMIT 1 OFFSET 1;



SELECT COUNT(*), AVG(p.weight) FROM players p, draft d
WHERE d.ilkid = p.ilkid AND d.draft_year = '2001';


SELECT DISTINCT c.firstname, c.lastname FROM coaches_season c
WHERE NOT EXISTS ((SELECT t.league FROM teams t) EXCEPT
(SELECT t1.league FROM teams t1 WHERE t1.tid = c.tid));


SELECT DISTINCT c.firstname, c.lastname FROM coaches_season c, teams t 
WHERE c.tid = t.tid GROUP BY c.cid, c.firstname, c.lastname
HAVING COUNT(DISTINCT t.league) = (SELECT COUNT(DISTINCT t1.league) FROM teams t1); 


SELECT DISTINCT p.firstname, p.lastname FROM players p, player_rs prs, teams t
WHERE p.ilkid = prs.ilkid AND prs.tid = t.tid AND t.location = 'Houston' 
AND EXISTS (SELECT t2.tid FROM teams t2, player_rs prs2 WHERE t2.location = 'Chicago'
AND prs.ilkid = prs2.ilkid AND prs2.tid = t2.tid);


SELECT p.firstname, p.lastname FROM player_rs_career p
GROUP BY p.ilkid, p.firstname, p.lastname, p.pts
ORDER BY p.pts DESC LIMIT 10;


SELECT a.firstname, a.lastname FROM (SELECT * FROM player_rs_career p WHERE p.minutes > 0) a
WHERE CAST(a.pts AS FLOAT)/a.minutes = (SELECT MAX(CAST(b.pts AS FLOAT)/b.minutes) FROM
(SELECT * FROM player_rs_career p1 WHERE p1.minutes > 0) b);



SELECT a.pts, a.firstname, a.lastname FROM
(SELECT * FROM player_rs_career p WHERE (p.firstname = 'Michael' AND p.lastname = 'Jordan')
OR (p.firstname = 'Kareem' AND p.lastname = 'Abdul-jabbar')) a
WHERE a.pts = (SELECT MAX(b.pts) FROM (SELECT * FROM player_rs_career p 
WHERE (p.firstname = 'Michael' AND p.lastname = 'Jordan')
OR (p.firstname = 'Kareem' AND p.lastname = 'Abdul-jabbar')) b);


-- CREATE LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION seasons_played (VARCHAR, VARCHAR) RETURNS INTEGER AS $$
BEGIN
RETURN COUNT(*) FROM (SELECT DISTINCT p.year FROM player_rs p WHERE p.firstname = $1 AND p.lastname = $2) a;
END;
$$ LANGUAGE plpgsql;


select * from seasons_played('Michael', 'Jordan');


create table matrix (firstname varchar(30), lastname varchar(30),
		st_10000 integer, st_20000 integer, st_30000 integer,
		ge_30000 integer);

create or replace function point_matrix (varchar) returns setof matrix as $$
DECLARE mviews RECORD;
BEGIN
  FOR mviews IN SELECT p.firstname, p.lastname, p.pts FROM player_rs_career p, player_rs r 
  WHERE p.ilkid = r.ilkid AND r.tid = $1 LOOP
    IF mviews.pts < 10000 THEN 
      INSERT INTO matrix(firstname, lastname, st_10000, st_20000, st_30000, ge_30000)
      VALUES(mviews.firstname, mviews.lastname, mviews.pts, NULL, NULL, NULL);
    ELSIF mviews.pts < 20000 THEN 
      INSERT INTO matrix(firstname, lastname, st_10000, st_20000, st_30000, ge_30000)
      VALUES(mviews.firstname, mviews.lastname, NULL, mviews.pts, NULL, NULL);
    ELSIF mviews.pts < 30000 THEN 
      INSERT INTO matrix(firstname, lastname, st_10000, st_20000, st_30000, ge_30000)
      VALUES(mviews.firstname, mviews.lastname, NULL, NULL, mviews.pts, NULL);
    ELSE 
      INSERT INTO matrix(firstname, lastname, st_10000, st_20000, st_30000, ge_30000)
      VALUES(mviews.firstname, mviews.lastname, NULL, NULL, NULL, mviews.pts);
    END IF;
  END LOOP;

  FOR mviews in SELECT DISTINCT * FROM matrix m ORDER BY m.firstname, m.lastname LOOP
    RETURN NEXT mviews;
  END LOOP;
  return;
END
$$ LANGUAGE plpgsql;


select * from point_matrix ('IND');

drop function seasons_played(varchar, varchar);
drop function point_matrix(varchar);
drop table matrix;


\o
