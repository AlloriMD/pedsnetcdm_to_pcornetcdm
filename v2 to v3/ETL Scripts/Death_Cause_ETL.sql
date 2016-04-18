Insert into dcc_pcornet.death_cause(
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence	
)
select 
	person_id as patid,
	left(cause_source_value,8) as death_cause,
	coalesce(m1.target_concept,'OT') as death_cause_code,
	'NI' as death_cause_type, 
	'L' as death_cause_source,
	null as death_cause_confidence -- not dicretely captured in the EHRs
From
	dcc_pedsnet.death de
	join dcc_pcornet.demographic d on cast(de.person_id as text) = d.patid
	left join cz_omop_pcornet_concept_map m1 on cast(cause_concept_id as text) = source_concept_id 
	AND m1.source_concept_class='death cause code' 
where cause_concept_id>0
