-- Exploratory Data Analysis queries
select count(distinct npi) from prescriber;
select * from prescriber;
select * from prescription;


-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

select
	p.npi,
	sum(p.total_claim_count) as total_number_of_claims
from prescription as p
group by p.npi
order by total_number_of_claims desc
limit 1;

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

select
	pr.nppes_provider_first_name,
	pr.nppes_provider_last_org_name,
	pr.specialty_description,
	view_prescriber_claims.total_number_of_claims
from prescriber as pr
inner join (
	select
		p.npi,
		sum(p.total_claim_count) as total_number_of_claims
	from prescription as p
	inner join prescriber as pr
	on pr.npi = p.npi
	group by p.npi
	order by total_number_of_claims desc
	limit 1
) as view_prescriber_claims
on pr.npi = view_prescriber_claims.npi;

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

select
	pr.specialty_description,
	sum(p.total_claim_count) as total_number_of_claims
from prescription as p
inner join prescriber as pr
on pr.npi = p.npi
group by pr.specialty_description
order by total_number_of_claims desc
limit 1;

-- Family Practice

--     b. Which specialty had the most total number of claims for opioids?

select
	pr.specialty_description,
	sum(p.total_claim_count) as total_number_of_claims
from prescription as p
inner join prescriber as pr
on pr.npi = p.npi
inner join drug as d
on p.drug_name = d.drug_name
where d.opioid_drug_flag = 'Y'
group by pr.specialty_description
order by total_number_of_claims desc
limit 1;

-- Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

select
	pr.specialty_description,
	count(view_prescription_with_specialty.specialty_description) as specialty_count
from prescriber as pr
left join (
	select
		p.*,
		pr.specialty_description
	from prescription as p
	left join prescriber as pr
	on p.npi = pr.npi
) as view_prescription_with_specialty
on pr.npi = view_prescription_with_specialty.npi
group by pr.specialty_description
having count(view_prescription_with_specialty.specialty_description) < 1;

-- Yes, there are 15 specialties that are never recorded in the prescription.

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

select
	d.generic_name,
	cast(p.total_drug_cost as money)
from drug as d
inner join prescription as p
on d.drug_name = p.drug_name
order by p.total_drug_cost desc
limit 1;

-- PIRFENIDONE at $2,829,174.30

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

-- I used CAST instead of ROUND to achieve the same goal
select
	d.generic_name,
	cast((p.total_drug_cost / p.total_day_supply) as money) as total_cost_per_day
from drug as d
inner join prescription as p
on d.drug_name = p.drug_name
order by total_cost_per_day desc
limit 1;

-- IMMUN GLOB G(IGG)/GLY/IGA OV50 had the highest total cost per day at $7,141.11 (!) per day.

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

select
	drug_name,
	case
		when opioid_drug_flag = 'Y' then 'opioid'
		when antibiotic_drug_flag = 'Y' then 'antibiotic'
		else 'neither'
	end as drug_type
from drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

select
	case
		when d.opioid_drug_flag = 'Y' then 'opioid'
		when d.antibiotic_drug_flag = 'Y' then 'antibiotic'
		else 'neither'
	end as drug_type,
	cast(sum(total_drug_cost) as money)
from drug as d
inner join prescription as p
on d.drug_name = p.drug_name
group by drug_type;

-- More money was spent on Opioids ($105,080,626.37) than on Antibiotics ($38,435,121.26).

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.