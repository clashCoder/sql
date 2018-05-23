/*******************************************************************************
 Return the statecode, county name and 2010 population of all counties who
 had a population of over 2,000,000 in 2010. Return the rows in descending order
 from most populated to least
 ******************************************************************************/

SELECT cou.statecode,cou.name,cou.population_2010
FROM counties cou
WHERE cou.population_2010 > 2000000
ORDER BY cou.population_2010 DESC

/*******************************************************************************
 Return a list of statecodes and the number of counties in that state,
 ordered from the least number of counties to the most 
*******************************************************************************/

SELECT cou.statecode, COUNT(cou.statecode) AS numCounties
FROM counties cou, states s
WHERE cou.statecode = s.statecode
GROUP BY s.statecode 
ORDER BY numCounties ASC;


/*******************************************************************************
 On average how many counties are there per state (return a single real
 number) 
*******************************************************************************/

SELECT cast(COUNT(c.name) / COUNT(DISTINCT s.statecode) as DECIMAL(20,1)) AS countiesPerState
 
FROM states s, counties c
 
WHERE s.statecode = c.statecode;


/*******************************************************************************
 Return a count of how many states have more than the average number of
 counties
*******************************************************************************/

SELECT COUNT(*) highAvg
FROM (
   SELECT s.statecode, COUNT(c.statecode) AS numCounties
   FROM counties c, states s
   WHERE s.statecode = c.statecode
   GROUP BY s.statecode
   ORDER BY numCounties ASC
) AS TEMP
WHERE TEMP.numCounties > ALL (
 SELECT COUNT(c2.name) / COUNT(DISTINCT s2.statecode)
 FROM states s2, counties c2
 WHERE s2.statecode = c2.statecode
);



/*******************************************************************************
 Return the statecodes of states whose 2010 population does
 not equal the sum of the 2010 populations of their counties
*******************************************************************************/

SELECT s2.statecode
FROM  
(
SELECT s.statecode, SUM(c.population_2010) AS pop
FROM states s, counties c
WHERE c.statecode = s.statecode
GROUP BY s.statecode
ORDER BY pop DESC
) as TEMP, states s2
WHERE (s2.population_2010 <> TEMP.pop) AND (s2.statecode = TEMP.statecode)
;

/*******************************************************************************
 How many states have at least one senator whose first name is John,
 Johnny, or Jon? Return a single integer
*******************************************************************************/

SELECT COUNT(*) AS numSenWithSpecFrstName
FROM (
	SELECT DISTINCT sn.statecode
	FROM senators sn
	WHERE sn.name LIKE "John %"
	UNION
	SELECT DISTINCT sn2.statecode
	FROM senators sn2
	WHERE sn2.name LIKE "Johnny %"
	UNION
	SELECT DISTINCT sn3.statecode
	FROM senators sn3
	WHERE sn3.name LIKE "Jon %" ) AS table1
;


/*******************************************************************************
Find all the senators who were born in a year before the year their state
was admitted to the union.  For each, output the statecode, year the state was
admitted to the union, senator name, and year the senator was born.  Note: in
SQLite you can extract the year as an integer using the following:
"cast(strftime('%Y',admitted_to_union) as integer)"
*******************************************************************************/

SELECT sn.statecode, YEAR(s.admitted_to_union) AS YrStateJoined, sn.name, sn.born
FROM senators sn, states s
WHERE (s.statecode = sn.statecode) AND YEAR(s.admitted_to_union) > sn.born;


/*******************************************************************************
Find all the counties of West Virginia (statecode WV) whose population
shrunk between 1950 and 2010, and for each, return the name of the county and
the number of people who left during that time (as a positive number).
*******************************************************************************/

SELECT c.name, ABS((c.population_1950) - (c.population_2010)) AS numPplLeft
FROM counties c
WHERE c.population_1950 > c.population_2010 AND c.statecode LIKE "wv";

/*******************************************************************************
Return the statecode of the state(s) that is (are) home to the most
committee chairmen
*******************************************************************************/

SELECT TEMP.statecode
FROM
			 ( SELECT DISTINCT s2.statecode,COUNT(*) AS numCommittee
			   FROM senators s2, committees c2
                           WHERE s2.name = c2.chairman 
			   GROUP BY s2.statecode) AS TEMP
WHERE TEMP.numCommittee = (SELECT MAX(TEMP2.numCommittee2)
			   FROM
			   ( SELECT COUNT(*) AS numCommittee2
  			     FROM senators s3, committees c3
                             WHERE s3.name = c3.chairman
			     GROUP BY s3.statecode) AS TEMP2);

/*******************************************************************************
Return the statecode of the state(s) that are not the home of any
committee chairmen
*******************************************************************************/

SELECT DISTINCT s.statecode
FROM senators s
WHERE s.statecode NOT IN ( SELECT s.statecode
		           FROM senators s, committees c
                           WHERE s.name = c.chairman);


/*******************************************************************************
Find all subcommittes whose chairman is the same as the chairman of its
parent committee.  For each, return the id of the parent committee, the name of
the parent committee's chairman, the id of the subcommittee, and name of that
subcommittee's chairman
*******************************************************************************/

SELECT com1.id, com1.chairman, com2.id, com2.chairman
FROM committees com1 INNER JOIN committees com2
ON (com1.id = com2.parent_committee) AND (com1.chairman = com2.chairman);

