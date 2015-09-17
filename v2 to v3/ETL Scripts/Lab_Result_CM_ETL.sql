﻿
insert into pcornet_cdm.lab_result_cm (
	lab_result_cm_id,
	patid, encounterid,
	lab_name, specimen_source,
	lab_loinc, priority, result_loc,
	lab_px, lab_px_type,
	lab_order_date, 
	specimen_date, specimen_time,
	result_date, result_time, result_qual, result_num, result_modifier, result_unit,
	norm_range_low, norm_modifier_low,
	norm_range_high, norm_modifier_high,
	abn_ind,
	raw_lab_name, raw_lab_code, raw_panel, raw_result, raw_unit, raw_order_dept, raw_facility_code
)

select 
	m.measurement_id as lab_result_cm_id,
	m.person_id as patid,
	e.encounterid encounterid,
	m1.target_concept as lab_name,
	m2.target_concept as specimen_source,
	c1.concept_code as lab_loinc,
	null as priority,  -- null for now
	'UN' as result_loc, -- making this 'UN' for now - work in progress to edit the measurement table to include this. 	
	null as lab_px, -- null for now
	null as lab_px_type,
	null as lab_order_date, -- not available in PEDSnet CDM
	m.measurement_date as specimen_date,
	date_part('hour',m.measurement_time)||':'||date_part('minute',m.measurement_time) as specimen_time, -- HH:MI format 
	m.measurement_date as result_date, -- is that correct?
	null as result_time,
	'NI' as result_qual, -- derived field?
	m.value_as_number as result_num,
	m3.target_concept as result_modifier,
	m4.target_concept as result_unit,
	m.range_low::text as norm_range_low, -- TODO: incoporate the solution for non-numeric range values
	null as norm_modifier_low, -- No place for this in PEDSNet CDM. Link to observation maybe?
	m.range_high::text as norm_range_high, 
	null as norm_modifier_high, -- same as above
	null as abn_ind, -- null for now
	c1.concept_name as raw_lab_name,
	m.measurement_id as raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	unit_source_value as raw_unit,
	null as raw_order_dept,
	null as raw_facility_code 
	
from	 
	measurement m
	join pcornet_cdm.demographic d on cast(m.person_id as text)= d.patid
	join pcornet_cdm.encounter e on cast(m.visit_occurrence_id as text) = e.encounterid
	join concept c1 on m.measurement_concept_id = c1.concept_id and c1.vocabulary_id = 'LOINC'
	join concept c2 on m.operator_concept_id = c2.concept_id and c2.domain_id = 'Meas Value Operator'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on c1.concept_code = m1.source_concept_id and m1.source_concept_class = 'Lab name'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m2 on c1.concept_code = m2.source_concept_id and m2.source_concept_class = 'Specimen source'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m3 on cast(m.operator_concept_id as text) = m3.source_concept_id and m3.source_concept_class = 'Result modifier'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m4 on cast(m.unit_concept_id as text)= m4.source_concept_id and m4.source_concept_class = 'Unit'
