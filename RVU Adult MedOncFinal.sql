SELECT 
    TO_NUMBER(t1.txn_id) AS Transaction_ID,
    'Inpatient' AS PatientTypeInd,
    t1.txn_cd AS CPT_ID,
    t2.cpt_cd_descr AS CPT_NM,
    t6.prov_id AS BillProv_ID,
    t1.bill_prov_nm AS BillProv_NM,
    t6.prov_type_descr AS BillProv_TP,
    t6.prov_dx_grp_dv AS DiseaseCenter,
    t5.RVU,
--    DiseaseGroup
--    1 AS ServiceQuantity,
--    cFTE
    t1.service_dt AS Service_DT,
    t1.mrn AS DFCI_MRN,
    t1.alt_mrn AS BWH_MRN,
    CASE WHEN t3.pt_last_nm IS NOT NULL THEN t3.pt_last_nm||','||t3.pt_first_nm||' '||t3.pt_middle_nm 
         ELSE NULL
         END AS Patient_NM,
    t4.super_prov_id AS SupervisingProv_ID,
    t4.prov_nm AS SupervisingProv_NM,
    t1.bill_prov_dept_nm AS Dept_NM,
    t1.alt_mrn_site_nm AS Place_of_SVC_NM,
    NULL AS proc_id
FROM
    dartods.ods_hart_charge_data t1
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t2 ON t1.txn_cd=t2.cpt_cd
    LEFT JOIN dart_ods.mv_coba_pt t3 ON t1.mrn=t3.pt_dfci_mrn
    LEFT JOIN (SELECT DISTINCT t1.super_prov_id, t1.cont_dttm, t2.pt_dfci_mrn, t3.prov_nm
                FROM (SELECT DISTINCT pt_enc_id, super_prov_id, cont_dttm FROM dart_ods.ods_edw_enc_pt_enc_02 WHERE super_prov_id IS NOT NULL) t1 
                LEFT JOIN dart_ods.mv_coba_pt_enc t2 ON t1.pt_enc_id=t2.enc_id_csn
                LEFT JOIN dart_ods.mv_coba_prov t3 ON t1.super_prov_id=t3.prov_id) t4 ON t1.mrn=t4.pt_dfci_mrn and t1.service_dt=t4.cont_dttm
    LEFT JOIN (SELECT DISTINCT t1.RVU, t2.cpt_cd, t1.calendar_dim_seq FROM dartedm.f_cpt_measure@DARTPRD t1 LEFT JOIN dartedm.d_cpt_cd@DARTPRD t2 ON t1.cpt_dim_seq=t2.cpt_dim_seq WHERE t1.RVU IS NOT NULL) t5 
         ON t1.txn_cd=t5.cpt_cd AND 
            EXTRACT(YEAR FROM t1.service_dt)=TO_NUMBER(substr(t5.calendar_dim_seq,1,4))
    LEFT JOIN dart_ods.mv_coba_prov t6 ON t1.bill_prov_npi=t6.prov_npi_id

UNION 

SELECT
    t1.transact_id AS Transaction_ID,
    'Inpatient' AS PatientTypeInd,
    t1.cpt_cd AS CPT_ID,
    t6.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_id AS BillProv_ID,
    t7.prov_nm AS BillProv_NM,
    t10.RVU,
--    DiseaseGroup
--    1 AS ServiceQuantity,
--    cFTE
    t1.svc_dttm AS Service_DT,
    t5.pt_dfci_mrn AS DFCI_MRN,
    t5.pt_bwh_mrn AS BWH_MRN,
    CASE WHEN t5.pt_last_nm IS NOT NULL THEN t5.pt_last_nm||','||t5.pt_first_nm||' '||t5.pt_middle_nm 
         ELSE NULL 
         END AS Patient_NM,
    t8.super_prov_id AS SupervisingProv_ID,
    t9.prov_nm as SupervisingProv_NM,
    t1.dept_descr AS Dept_NM,
    t3.place_of_svc_nm AS Place_of_SVC_NM,
    t1.proc_id
FROM
    dart_ods.ods_edw_fin_prof_bill_transact t1
    LEFT JOIN dart_ods.ods_edw_ref_loc t2 ON t1.loc_id=t2.loc_id
    LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t3 ON t1.place_of_svc_id=t3.place_of_svc_id
    LEFT JOIN dart_ods.ods_edw_ref_svc_area t4 ON t1.svc_area_id=t4.svc_area_id
    LEFT JOIN dart_ods.mv_coba_pt t5 ON t1.pt_id=t5.pt_id
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t6 ON t1.cpt_cd=t6.cpt_cd
    LEFT JOIN dart_ods.mv_coba_prov t7 ON t1.bill_prov_id=t7.prov_id
    LEFT JOIN dart_ods.ods_edw_enc_pt_enc_02 t8 ON t1.pt_enc_id=t8.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_prov t9 ON t8.super_prov_id=t9.prov_id
    LEFT JOIN (SELECT DISTINCT t1.RVU, t2.cpt_cd, t1.calendar_dim_seq FROM dartedm.f_cpt_measure@DARTPRD t1 LEFT JOIN dartedm.d_cpt_cd@DARTPRD t2 ON t1.cpt_dim_seq=t2.cpt_dim_seq WHERE t1.RVU is not null) t10 
         ON t1.cpt_cd=t10.cpt_cd AND 
            extract(year from t1.svc_dttm)=TO_NUMBER(substr(t10.calendar_dim_seq,1,4))
WHERE t1.dept_id=14010010364 --DF Medical Oncology

UNION

SELECT
    t1.transact_id AS Transaction_ID,
    t1.hosp_acct_cls_descr AS PatientTypeInd,
    t1.cpt AS CPT_ID,
    t4.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_id AS BillProv_ID,
    t5.prov_nm AS BillProv_NM,
    --disease group
    t10.RVU,
    t1.svc_dttm AS Service_DT,
--    1 AS ServiceQuantity,
    --cFTE
    t2.pt_dfci_mrn AS DFCI_MRN,
    t2.pt_bwh_mrn AS BWH_MRN,
    CASE WHEN t3.pt_last_nm IS NOT NULL THEN t3.pt_last_nm||','||t3.pt_first_nm||' '||t3.pt_middle_nm 
         ELSE NULL 
         END AS Patient_NM,
    t6.super_prov_id AS SupervisingProv_ID,
    t7.prov_nm as SupervisingProv_NM,
    t1.dept_descr AS Dept_NM,
    t8.place_of_svc_nm AS Place_of_SVC_NM,
    t1.proc_id
FROM
    dart_ods.ods_edw_fin_hosp_transact t1
    LEFT JOIN dart_ods.mv_coba_pt_enc t2 ON t1.pt_enc_id=t2.enc_id_csn
    LEFT JOIN dart_ods.mv_coba_pt t3 ON t2.pt_id=t3.pt_id
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t4 ON t1.cpt=t4.cpt_cd
    LEFT JOIN dart_ods.mv_coba_prov t5 ON t1.bill_prov_id=t5.prov_id
    LEFT JOIN dart_ods.ods_edw_enc_pt_enc_02 t6 ON t1.pt_enc_id=t6.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_prov t7 ON t6.super_prov_id=t7.prov_id
    LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t8 ON t1.place_of_svc_id=t8.place_of_svc_id
    LEFT JOIN dart_ods.ods_edw_ref_svc_area t9 ON t1.svc_area_id=t9.svc_area_id
    LEFT JOIN (SELECT DISTINCT t1.RVU, t2.cpt_cd, t1.calendar_dim_seq FROM dartedm.f_cpt_measure@DARTPRD t1 LEFT JOIN dartedm.d_cpt_cd@DARTPRD t2 ON t1.cpt_dim_seq=t2.cpt_dim_seq WHERE t1.RVU is not null) t10 
         ON t1.cpt=t10.cpt_cd AND 
            extract(year from t1.svc_dttm)=TO_NUMBER(substr(t10.calendar_dim_seq,1,4))
--WHERE t1.dept_id=14010010364 --DF Medical Oncology
;
