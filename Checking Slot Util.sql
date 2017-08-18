--checking counts for both filters
SELECT
COUNT(*) as CNT
FROM DART_ODS.MV_COBA_PROV_SLOT_UTIL 
WHERE SLOT_DEPT_DESCR = 'DF PALLIATIVE CARE' AND SLOT_BLK_LIST IS NOT NULL;
--checking counts for one filter and this filter is a must
SELECT
COUNT(*) as CNT
FROM DART_ODS.MV_COBA_PROV_SLOT_UTIL 
WHERE SLOT_DEPT_DESCR = 'DF PALLIATIVE CARE';
--checking unique provider names
SELECT DISTINCT
slot_prov_nm
FROM DART_ODS.MV_COBA_PROV_SLOT_UTIL 
WHERE SLOT_DEPT_DESCR = 'DF PALLIATIVE CARE' AND slot_blk_list IS NOT NULL;

SELECT
    slot_dept_id,
    slot_dept_abbr,
    slot_dept_descr,
    slot_dept_floor_loc_dv,
    slot_dt,
    slot_day_of_week,
    slot_begin_dttm,
    slot_tm,
    slot_length_minute_nbr,
    slot_end_dttm,
    slot_prov_id,
    slot_prov_nm,
    slot_prov_typ_descr,
    slot_sched_appt_cnt,
    slot_orig_reg_open_cnt,
    slot_unavail_rsn_descr,
    slot_overbk_ind,
    slot_visit_typ_descr,
    slot_day_unavail_rsn_descr,
    slot_tm_unavail_rsn_descr,
    slot_out_tmplt_ind,
    slot_blk_list,
    slot_enc_id,
    slot_appt_state_descr,
    slot_schd_by_nm,
    slot_schd_by_login_dept
FROM
    dart_ods.mv_coba_prov_slot_util
    WHERE slot_prov_nm='TULSKY, JAMES A' AND SLOT_DEPT_DESCR = 'DF PALLIATIVE CARE' AND slot_blk_list IS NOT NULL;