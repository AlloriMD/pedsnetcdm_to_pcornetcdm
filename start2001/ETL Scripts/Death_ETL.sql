
Insert into chop_start2001_pcornet.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence, site
)
Select 
	de.person_id as patid,
	de.death_date as death_date,
	coalesce(m1.target_concept,'OT') as death_impute, 
	'L' as death_source, --  default for now until new conventions
	null as death_match_confidence, --  we do not capture it dicretely in the EHRs 
	min(de.site) as site -- retrieve one record in case of multiple death causes
From
	chop_pedsnet.death de
	join chop_start2001_pcornet.demographic d on d.patid = cast(de.person_id as text)
	left join chop_start2001_pcornet.cz_omop_pcornet_concept_map m1 on m1.source_concept_class='Death date impute' and 
	cast(de.death_impute_concept_id as text) = m1.source_concept_id
Where 
	de.death_type_concept_id  = 38003569 And
	de.person_id IN (select person_id from chop_start2001_pcornet.person_visit_start2001)
group by de.person_id , de.death_date, coalesce(m1.target_concept,'OT'); 
	
