/*
Tables used for this analysis:
- indiv16, indiv20: the individual contributions file contains each contribution from an individual to a federal committee in 2016 and 2020, respectively
- ccl16, ccl20: These tables contains one record for each candidate to committee linkage.
- cm16, cm20: The committee tables contains one record for each committee registered with the Federal Election Commission. 
- cn16, cn20: The candidate tables contains one record for each candidate who has either registered with the Federal Election Commission or appeared on a ballot list prepared by a state elections office.

For more details on the table schema and description of individual contributions table:
https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/

For more details on the table schema and description of candidate-committee linkage table:
https://www.fec.gov/campaign-finance-data/candidate-committee-linkage-file-description/

For more details on the table schema and description of candidate table
https://www.fec.gov/campaign-finance-data/candidate-summary-file-description/
*/



-- 2016 Presidential election
-- Creating a temp table 'indiv_donor16' to store the aggregated donations for individual donors in the 2016 election
-- The table will have each row representing a unique donor along with the total amount of donations they have made to a political candidate or their PACs
with indiv_donor16 as (
SELECT
  indiv_contri16.cmte_id,
  indiv_contri16.name as donor_name,
  indiv_contri16.city,
  indiv_contri16.state,
  indiv_contri16.zip_code,
  indiv_contri16.employer,
  indiv_contri16.occupation, 
  cand16.cand_pty_affiliation as party,
  sum(indiv_contri16.transaction_amt) as indiv_total_donation_amt 
FROM
  bigquery-public-data.fec.indiv16 as indiv_contri16 
join
  bigquery-public-data.fec.ccl16 as linkage16 on indiv_contri16.cmte_id = linkage16.cmte_id
join 
  bigquery-public-data.fec.cm16 as com16 on linkage16.cmte_id = com16.cmte_id
join
  bigquery-public-data.fec.cn16 as cand16 on linkage16.cand_id = cand16.cand_id
where 
  indiv_contri16.transaction_dt between '2015-11-08' and '2016-11-08' -- all donations made in the 12 months leading up to the election date on 11/8/2016
  and cand16.cand_election_yr = 2016 -- the year candidate is on the ballot 
  and (cand16.cand_pty_affiliation in ('DEM', 'REP') 
        or com16.cmte_pty_affiliation in ('DEM', 'REP')) -- donations only to Republican and Democratic party candidates or their PACs
  and cand16.cand_office = 'P' -- candidates seeking presidential office
  and indiv_contri16.other_id is null -- for contributions from individuals, this column is null 
  and indiv_contri16.entity_tp = 'IND' -- for individual donations 
group by 
  1,2,3,4,5,6,7,8
) 
-- Using the temp table created above to count the number of individual donors and the total donation amount by individuals
select 
  party,
  count(distinct donor_name) as donor_count, 
  sum(indiv_total_donation_amt) as total_donation_amt
from indiv_donor16
group by 1
order by 1
;

-- 2020 Presidential election
-- Similar to 2016, creating a temp table 'indiv_donor120' to store the aggregated donations for individual donors in the 2020 election
-- The table will have each row representing a unique donor along with the total amount of donations they have made to a political candidate or their PACs
with indiv_donor20 as (
SELECT
  indiv_contri20.cmte_id,
  indiv_contri20.name as donor_name,
  indiv_contri20.city,
  indiv_contri20.state,
  indiv_contri20.zip_code,
  indiv_contri20.employer,
  indiv_contri20.occupation, 
  cand20.cand_pty_affiliation as party,
  sum(indiv_contri20.transaction_amt) as indiv_total_donation_amt 
FROM
  bigquery-public-data.fec.indiv20 as indiv_contri20
join
  bigquery-public-data.fec.ccl20 as linkage20 on indiv_contri20.cmte_id = linkage20.cmte_id
join 
  bigquery-public-data.fec.cm20 as com20 on linkage20.cmte_id = com20.cmte_id
join
  bigquery-public-data.fec.cn20 as cand20 on linkage20.cand_id = cand20.cand_id
where 
  indiv_contri20.transaction_dt between '2019-11-03' and '2020-11-03' -- all donations made in the 12 months leading up to the election date on 11/3/2020
  and cand20.cand_election_yr = 2020 -- the year candidate is on the ballot 
  and (cand20.cand_pty_affiliation in ('DEM', 'REP') 
        or com20.cmte_pty_affiliation in ('DEM', 'REP')) -- donations only to Republican and Democratic party candidates or their PACs
  and cand20.cand_office = 'P' -- candidates seeking presidential office
  and indiv_contri20.other_id is null -- for contributions from individuals, this column is null 
  and indiv_contri20.entity_tp = 'IND' -- for individual donations 
group by 
  1,2,3,4,5,6,7,8
) 
-- Using the temp table created above to count the number of individual donors and the total donation amount by individuals
select 
  party,
  count(distinct donor_name) as donor_count, 
  sum(indiv_total_donation_amt) as total_donation_amt
from indiv_donor20
group by 1
order by 1
;

-- 2016 election
-- Monthly individual donation totals leading up to Election Day
with indiv_donor16 as (
SELECT
  indiv_contri16.cmte_id,
  indiv_contri16.name as donor_name,
  indiv_contri16.city,
  indiv_contri16.state,
  indiv_contri16.zip_code,
  indiv_contri16.employer,
  indiv_contri16.occupation, 
  indiv_contri16.transaction_dt,
  cand16.cand_pty_affiliation as party,
  sum(indiv_contri16.transaction_amt) as indiv_total_donation_amt 
FROM
  bigquery-public-data.fec.indiv16 as indiv_contri16
join
  bigquery-public-data.fec.ccl16 as linkage16 on indiv_contri16.cmte_id = linkage16.cmte_id
join 
  bigquery-public-data.fec.cm16 as com16 on linkage16.cmte_id = com16.cmte_id
join
  bigquery-public-data.fec.cn16 as cand16 on linkage16.cand_id = cand16.cand_id
where 
  indiv_contri16.transaction_dt between '2015-11-08' and '2016-11-08' -- all donations made in the 12 months leading up to the election date on 11/8/2016
  and cand16.cand_election_yr = 2016 -- the year candidate is on the ballot 
  and (cand16.cand_pty_affiliation in ('DEM', 'REP') 
        or com16.cmte_pty_affiliation in ('DEM', 'REP')) -- donations only to Republican and Democratic party candidates or their PACs
  and cand16.cand_office = 'P' -- candidates seeking presidential office
  and indiv_contri16.other_id is null -- for contributions from individuals, this column is null 
  and indiv_contri16.entity_tp = 'IND' -- for individual donations 
group by 
  1,2,3,4,5,6,7,8,9
) 
select 
  extract(month from transaction_dt) as month,
  extract(year from transaction_dt) as year,
  sum(indiv_total_donation_amt) as total_donation_amt
from indiv_donor16
where extract(year from transaction_dt) = 2016
group by 1, 2
order by 2, 1
;


-- 2020 election
-- Monthly individual donation totals leading up to Election Day
with indiv_donor20 as (
SELECT
  indiv_contri20.cmte_id,
  indiv_contri20.name as donor_name,
  indiv_contri20.city,
  indiv_contri20.state,
  indiv_contri20.zip_code,
  indiv_contri20.employer,
  indiv_contri20.occupation, 
  indiv_contri20.transaction_dt,
  cand20.cand_pty_affiliation as party,
  sum(indiv_contri20.transaction_amt) as indiv_total_donation_amt 
FROM
  bigquery-public-data.fec.indiv20 as indiv_contri20
join
  bigquery-public-data.fec.ccl20 as linkage20 on indiv_contri20.cmte_id = linkage20.cmte_id
join 
  bigquery-public-data.fec.cm20 as com20 on linkage20.cmte_id = com20.cmte_id
join
  bigquery-public-data.fec.cn20 as cand20 on linkage20.cand_id = cand20.cand_id
where 
  indiv_contri20.transaction_dt between '2019-11-03' and '2020-11-03' -- all donations made in the 12 months leading up to the election date on 11/3/2020
  and cand20.cand_election_yr = 2020 -- the year candidate is on the ballot 
  and (cand20.cand_pty_affiliation in ('DEM', 'REP') 
        or com20.cmte_pty_affiliation in ('DEM', 'REP')) -- donations only to Republican and Democratic party candidates or their PACs
  and cand20.cand_office = 'P' -- candidates seeking presidential office
  and indiv_contri20.other_id is null -- for contributions from individuals, this column is null 
  and indiv_contri20.entity_tp = 'IND' -- for individual donations 
group by 
  1,2,3,4,5,6,7,8,9
)
select 
  extract(month from transaction_dt) as month,
  extract(year from transaction_dt) as year,
  sum(indiv_total_donation_amt) as total_donation_amt
from indiv_donor20
where 
  extract(year from transaction_dt) = 2020
group by 1, 2
order by 2, 1
;


