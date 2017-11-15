SELECT
    t1.transact_id AS Transaction_ID,
    'Inpatient' AS PatientTypeInd,
    t1.cpt_cd AS CPT_ID,
    t6.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_id AS BillProv_ID,
    t7.prov_nm AS BillProv_NM,
    t7.prov_type_descr AS BillProv_TP,
    t7.prov_dx_grp_dv AS DiseaseCenter,
    t10.RVU,
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
--WHERE t1.dept_id=14010010364 --DF Medical Oncology

UNION ALL

SELECT
    t1.transact_id AS Transaction_ID,
    t1.hosp_acct_cls_descr AS PatientTypeInd,
    t1.cpt AS CPT_ID,
    t4.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_id AS BillProv_ID,
    t5.prov_nm AS BillProv_NM,
    t5.prov_type_descr AS BillProv_TP,
    t5.prov_dx_grp_dv AS DiseaseCenter,
    t10.RVU,
    t1.svc_dttm AS Service_DT,
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
WHERE t1.transact_typ_cd=1 AND t1.post_dttm>='30-MAY-15'
