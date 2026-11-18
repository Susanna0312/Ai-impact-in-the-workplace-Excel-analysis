--1)Table creation--
CREATE TABLE survey_responses (
    respondent_id       INTEGER PRIMARY KEY,
    role                TEXT,
    industry            TEXT,
    company_size        TEXT,
    country             TEXT,
    salary_band         TEXT,
    uses_ai_at_work     BOOLEAN,
    ai_tools_count      INTEGER,
    weekly_ai_minutes   NUMERIC,
    hours_saved_per_week NUMERIC,
    productivity_change TEXT,
    trust_in_ai_output  NUMERIC,
    worried_about_job   NUMERIC,
    barrier_to_adoption TEXT,
    company_ai_policy   TEXT,
    training_offered    BOOLEAN
);
 --2)
 select *from survey_responses;

 --3)check the import is worked--
 select count(*)as Total_respondents from survey_responses

 --4)Respondents use AI at work--
 select count(*)as Ai_users from survey_responses where uses_ai_at_work=TRUE

 --5)overall AI adoption rate--
SELECT
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses;

--6)Ai adoption rate by job roles--
SELECT
    role,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM public.survey_responses
GROUP BY role
ORDER BY adoption_rate DESC;

-- 7)Ai adoption rate by industries--
select industry,count(*)as total_respondents,count(*) filter(where uses_ai_at_work=TRUE) as AI_users,
round(100*count(*) filter (where uses_ai_at_work=TRUE)/count(*),2) as adoption_rate from survey_responses
group by industry 
order by adoption_rate DESC;

--8)barriers to adoption--
select barrier_to_adoption,count(*) filter(where uses_ai_at_work=FALSE)as total_respondents,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS barrier_pct from survey_responses 
group by barrier_to_adoption
order by total_respondents DESC;

--9)Average work hours saved in each role--
select role,count(*)as Ai_users,round(avg(hours_saved_per_week),2)as avg_hours_saved from survey_responses 
where uses_ai_at_work=TRUE
group by role 
order by avg_hours_saved DESC,role ASC;

--10)productivity change among AI users--
select productivity_change,count(*)as AI_users ,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS productivity_pct
from survey_responses where uses_ai_at_work=TRUE 
group by productivity_change 
order by AI_users DESC;

--11)productivity improvement--
SELECT
    COUNT(*) AS ai_users,
    COUNT(*) FILTER (
        WHERE productivity_change IN (
            'slightly more productive',
            'more productive',
            'significantly more productive'
        )
    ) AS improved_users,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE productivity_change IN (
                'slightly more productive',
                'more productive',
                'significantly more productive'
            )
        ) / COUNT(*),
        2
    ) AS improvement_pct
FROM survey_responses
WHERE uses_ai_at_work = TRUE;

--12) AI adoption by company size--
SELECT
    company_size,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses
GROUP BY company_size
ORDER BY CASE company_size
    WHEN '1-50' THEN 1
    WHEN '51-500' THEN 2
    WHEN '501-5000' THEN 3
    WHEN '5000+' THEN 4
    ELSE 5
END;

--13)Ai adoption rate by company policy--
SELECT
    company_ai_policy,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses
GROUP BY company_ai_policy
ORDER BY adoption_rate DESC

--14)Ai adoption rate by training offered and not offered --
SELECT
    training_offered,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses
GROUP BY training_offered
ORDER BY adoption_rate desc

--15)saving more time report--
SELECT
    training_offered,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses
GROUP BY training_offered
ORDER BY training_offered 

--16)Ai adoption by country --
SELECT
    country,
    COUNT(*) AS total_respondents,
    COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE) AS ai_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uses_ai_at_work = TRUE)
        / COUNT(*),
        2
    ) AS adoption_rate
FROM survey_responses
GROUP BY country
ORDER BY adoption_rate DESC

--17)Trust in AI output and concern about job security bw AI and Non AI users--
SELECT
    uses_ai_at_work,
    COUNT(*) AS total_respondents,
   	ROUND(avg(trust_in_ai_output),4) AS avg_trustscore,
	ROUND(avg(worried_about_job),2) AS avg_jobconcernscore
FROM survey_responses
GROUP BY uses_ai_at_work
ORDER BY uses_ai_at_work

--18)Avg weekly hours saved by number of AI tools used--
select ai_tools_count,
count(*)as total_respondents,
round(avg(hours_saved_per_week),2)as avg_hours_saved_weekly
from survey_responses
group by ai_tools_count
order by avg_hours_saved_weekly DESC

--19)Final check--
WITH totals AS (
    SELECT
        COUNT(*) AS total_respondents,
        COUNT(*) FILTER (WHERE uses_ai_at_work) AS ai_users,
        AVG(hours_saved_per_week)
            FILTER (WHERE uses_ai_at_work) AS avg_hours_saved,
        COUNT(*) FILTER (
            WHERE uses_ai_at_work
              AND productivity_change IN (
                  'slightly more productive',
                  'more productive',
                  'significantly more productive'
              )
        ) AS improved_users
    FROM public.survey_responses
)
SELECT
    total_respondents,
    ROUND(100.0 * ai_users / total_respondents, 2) AS adoption_pct,
    ROUND(avg_hours_saved, 2) AS avg_weekly_hours_saved,
    ROUND(100.0 * improved_users / NULLIF(ai_users, 0), 2)
        AS productivity_improvement_pct
FROM totals;


