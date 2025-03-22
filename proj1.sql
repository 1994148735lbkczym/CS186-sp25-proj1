-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM People
  WHERE People.weight > 300
   -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst AS nf, namelast AS nl, birthyear
  FROM People
  WHERE nf LIKE '% %'
  ORDER BY nf ASC, nl ASC -- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM People AS p1
  GROUP BY birthyear
  ORDER BY birthyear ASC -- replace this line
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, count(*)
  FROM People AS p1
  GROUP BY birthyear
  HAVING avgheight > 70
  ORDER BY birthyear ASC -- replace this line
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, h.yearid 
  FROM People p NATURAL JOIN HallofFame AS h
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, p.playerid ASC-- replace this line
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT  p.namefirst, p.namelast, p.playerid, s.schoolID, h.yearid
  FROM People p
  INNER JOIN CollegePlaying c ON p.playerid = c.playerid
  INNER JOIN Schools s ON c.schoolid = s.schoolid
  INNER JOIN HallofFame h ON p.playerid = h.playerid
  WHERE  h.inducted = 'Y' AND s.schoolstate = 'CA'
  ORDER BY h.yearid DESC, s.schoolid ASC, p.playerid ASC;
;
-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
  FROM HallofFame h 
  LEFT JOIN CollegePlaying c ON h.playerid = c.playerid
  INNER JOIN People p ON p.playerid = h.playerid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC,  c.schoolid ASC -- replace this line
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, (b.H + b.H2B + 2.0*b.H3B + 3.0*b.HR)/ b.AB AS slg
  FROM Batting b
  INNER JOIN People p ON p.playerid = b.playerid
  WHERE b.AB > 50
  ORDER BY slg DESC, b.yearid ASC, p.playerid ASC
  LIMIT 10 -- replace this line
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
    SELECT p.playerid, p.namefirst, p.namelast, (SUM(b.H) + SUM(b.H2B) + SUM(2.0*b.H3B) + SUM(3.0*b.HR))/ SUM(b.AB) AS lslg
  FROM Batting b
  INNER JOIN People p ON p.playerid = b.playerid
  GROUP BY p.playerid
  HAVING SUM(b.AB) > 50
  ORDER BY lslg DESC, b.yearid ASC, p.playerid ASC
  LIMIT 10 -- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p1.namefirst, p1.namelast, (SUM(b1.H) + SUM(b1.H2B) + SUM(2.0*b1.H3B) + SUM(3.0*b1.HR))/ SUM(b1.AB) AS lslg
  FROM Batting b1
  INNER JOIN People p1 ON p1.playerid = b1.playerid
  GROUP BY p1.playerid
  HAVING SUM(b1.AB) > 50
  AND lslg > (
    SELECT (SUM(b2.H) + SUM(b2.H2B) + SUM(2.0*b2.H3B) + SUM(3.0*b2.HR))/ SUM(b2.AB) AS lslg2
    FROM Batting b2
    WHERE b2.playerid = 'mayswi01'
    GROUP BY b2.playerid
  )
  ORDER BY lslg DESC  -- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary) 
  FROM Salaries s
  GROUP BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  with salaries2016 as(
    select * from salaries
    where yearid = 2016
  ),
  salaryStats as (
    select MIN(salary) as mins, MAX(salary) as maxs, (MAX(salary)-MIN(salary))/10.0 as width
    from salaries2016
  ), salaryBins as (
    select s.salary, MIN(CAST((s.salary - salaryStats.mins)/width AS INT), 9) AS binid
    from salaries2016 s, salaryStats
  )
  SELECT id.binid, id.binid*(select width from salaryStats)+(select mins from salaryStats), (id.binid+1)*(select width from salaryStats)+(select mins from salaryStats), count(*)
  from binids id LEFT JOIN salaryBins sb on id.binid = sb.binid
  group by id.binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  with yearlyData AS(
    select yearid, min(salary) as mins, max(salary) as maxs , avg(salary) as avgs
    from salaries
    group by yearid
  )
  select d2.yearid, d2.mins-d1.mins, d2.maxs-d1.maxs, d2.avgs-d1.avgs
    from yearlyData d1
    INNER JOIN yearlyData d2 on d1.yearid+1 = d2.yearid
    order by d1.yearid asc
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  with maxSalaries as (
    select yearid, max(salary) as salary
    from salaries
    where yearid = 2001 or yearid = 2000
    group by yearid
  )
  select p.playerid, p.namefirst, p.namelast, ms.salary, ms.yearid
  from maxSalaries ms
  JOIN salaries s
  on ms.yearid = s.yearid and ms.salary = s.salary
  JOIN people p
  on s.playerid = p.playerid

  order by ms.yearid asc
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  with all2016 as (
    select * from allstarfull
    where yearid = 2016
  )
  select s.teamid, max(s.salary) - min(s.salary)
  from all2016
  JOIN salaries s
  ON all2016.playerid = s.playerid and all2016.teamid = s.teamid and s.yearid = 2016
  group by s.teamid
;
