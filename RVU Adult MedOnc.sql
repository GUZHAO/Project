/*RVU Adult Medical Oncology*/
/*Main Tables
  DART_ODS.dartods.ods_hart_charge_data            --Inpatient, service_dt from 07-NOV-11 to 27-JAN-17
  DART_ODS.dart_ods.ods_edw_fin_prof_bill_transact --Inpatient, svcdttm from 28-JAN-17 going forward 
  DART_ODS.dartods.ods_bwpo_charge_data            --Outpatient?,
*/

/*Total 414076*/
SELECT COUNT(*) FROM (
SELECT
    t1.txn_id AS Transaction_ID,
    t1.txn_cd AS CPT_ID,
    t2.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_npi AS BillProv_NPI,
    t1.bill_prov_nm AS BillProv_NM,
--    t1.serv_prov_npi AS SvcProv_NPI,
--    t1.serv_prov_nm AS SvcProv_NM,
--    DiseaseGroup
    t1.work_rvu_amt AS RVU,
--    ServiceQuantity
--    cFTE
    t1.service_dt AS Service_DT,
    t1.mrn AS DFCI_MRN,
    t1.alt_mrn AS BWH_MRN,
    t3.pt_last_nm||','||t3.pt_first_nm||' '||t3.pt_middle_nm AS Patient_NM,
--    SupervisingMD_ID
--    SupervisingMD_NM


    t1.bill_prov_dept_nm AS BillProvDept_NM,
    t1.bill_area_nm AS BillArea_NM,
    t1.alt_mrn_site_nm AS Site_NM,
    t1.location_nm AS Location_NM,
    t1.place_of_service_nm AS PoS_NM   
FROM
    dartods.ods_hart_charge_data t1
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t2 ON t1.txn_cd=t2.cpt_cd
    LEFT JOIN dart_ods.mv_coba_pt t3 ON t1.mrn=t3.pt_dfci_mrn
);

/*Total 207086 changes daily*/    
SELECT COUNT(*) FROM (
SELECT
    t1.transact_id AS Transaction_ID,
    t1.cpt_cd AS CPT_ID,
    t6.cpt_cd_descr AS CPT_NM,
    t1.bill_prov_id AS BillProv_ID,
--    ProvideName
--    t1.svc_prov_id AS SvcProv_ID,
--    DiseaseGroup
    t1.work_rvu_amt,
--    t1.tot_rvu_amt,
--    t1.ovrhd_rvu_amt,
--    t1.malprac_rvu_amt,
--    t1.proc_cnt AS ServiceQuantity
--    cFTE
    t1.svc_dttm AS Service_DT,
    t5.pt_dfci_mrn AS DFCI_MRN,
    t5.pt_bwh_mrn AS BWH_MRN,
    t5.pt_last_nm||','||t5.pt_first_nm||' '||t5.pt_middle_nm AS Patient_NM,
--    SupervisingMD_ID
--    SupervisingMD_NM


    t1.dept_id AS Dept_ID,
    t1.dept_descr AS Dept_NM,
    t1.place_of_svc_id AS PoS_ID,
--    t3.place_of_svc_nm,
    t1.loc_id AS Location_ID,
--    t2.revenue_loc_NM,
    t1.svc_area_id AS ServiceArea_ID,
--    t4.svc_area_nm,
    t1.void_dttm,
    t1.prov_splty_cd,
    t1.prov_splty_descr,
    t1.bill_area_id
FROM
    dart_ods.ods_edw_fin_prof_bill_transact t1
--    LEFT JOIN dart_ods.ods_edw_ref_loc t2 ON t1.loc_id=t2.loc_id
--    LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t3 ON t1.place_of_svc_id=t3.place_of_svc_id
--    LEFT JOIN dart_ods.ods_edw_ref_svc_area t4 ON t1.svc_area_id=t4.svc_area_id
    LEFT JOIN dart_ods.mv_coba_pt t5 ON t1.pt_id=t5.pt_id
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t6 ON t1.cpt_cd=t6.cpt_cd
)
;

/*Total 102988 */
SELECT COUNT(*) FROM (
SELECT
    t1.txn_detail_id AS Transaction_ID,
    t1.cpt_cd AS CPT_ID,
    t2.cpt_cd_descr AS CPT_NM,
    t1.npi AS BillProv_NPI,
    t1.billing_prov_nm AS BillProv_NM, 
--    DiseaseGroup   
    t1.work_rvu_amt AS RVU,
--    t1.volume_amt AS ServiceQuantity,
--    cFTE
    t1.service_dt AS Service_DT,
--    DFCI_MRN
--    t1.epic_mrn,
    t1.bwh_mrn AS BWH_MRN,
    t1.patient_nm AS Patient_NM,
--    SupervisingMD_ID
--    SupervisingMD_NM


    t1.service_place_nm,
    t1.service_place_type,
    t1.billing_area_nm
FROM
    dartods.ods_bwpo_charge_data t1
    LEFT JOIN DARTEDM.D_CPT_CD@DARTPRD t2 ON t1.cpt_cd=t2.cpt_cd
ORDER BY t1.SERVICE_DT
)
;


