SELECT DPS.TXN_ID             AS TRANSACTION_ID,
       FPS.ACCT_CLASS_NM      AS PATIENTTYPEIND,
       PR.CPT_CD              AS CPT_ID,
       CPT1.CPT_CD_DESCR      AS CPT_NM,
       CASE WHEN BILL.EPIC_PROV_ID = -1 THEN NULL ELSE BILL.EPIC_PROV_ID END
           AS BILLPROV_ID,
       CASE WHEN BILL.EPIC_PROV_ID = -1 THEN NULL ELSE BILL.PROV_NM END
           AS BILLPROV_NM,
       BILL.PROV_TYPE_DESCR   AS BILLPROV_TP,
       BILL.DISEASE_GRP_DESCR AS DISEASECENTER,
       CASE WHEN PROV.EPIC_PROV_ID = -1 THEN NULL ELSE PROV.EPIC_PROV_ID END
           AS PROV_ID,
       CASE WHEN PROV.EPIC_PROV_ID = -1 THEN NULL ELSE PROV.PROV_NM END
           AS PROV_NM,
       PROV.PROV_TYPE_DESCR   AS PROV_TP,
       PROV.DISEASE_GRP_DESCR AS PROV_DISEASECENTER,
       CPT.RVU,
       CAL.CALENDAR_DT        AS SERVICE_DT,
       PT.DFCI_MRN            AS DFCI_MRN,
       PT.BWH_MRN             AS BWH_MRN,
       CASE
           WHEN PT.LAST_NM IS NOT NULL
           THEN
               PT.LAST_NM || ',' || PT.FIRST_NM || ' ' || PT.MIDDLE_NM
       END
           AS PATIENT_NM,
       CASE WHEN SUP.EPIC_PROV_ID = -1 THEN NULL ELSE SUP.EPIC_PROV_ID END
           AS SUPERVISINGPROV_ID,
       CASE WHEN SUP.EPIC_PROV_ID = -1 THEN NULL ELSE SUP.PROV_NM END
           AS SUPERVISINGPROV_NM,
       DEPT.CLIN_DEPT_NM      AS DEPT_NM,
       DEPT.LOCATION_NM       AS PLACE_OF_SVC_NM,
       PR.PROC_CD             AS PROC_ID,
       FPS.SERVICE_QTY
  FROM DARTEDM.D_SERVICE_TXN  DPS
       JOIN DARTEDM.F_PATIENT_SERVICE FPS
           ON DPS.SERVICE_TXN_DIM_SEQ = FPS.SERVICE_TXN_DIM_SEQ
       JOIN DARTEDM.D_CALENDAR CAL
           ON FPS.SERVICE_DT_DIM_SEQ = CAL.CALENDAR_DIM_SEQ
       LEFT JOIN DARTEDM.D_PATIENT PT
           ON FPS.PATIENT_DIM_SEQ = PT.PATIENT_DIM_SEQ
       JOIN DARTEDM.D_PROV BILL
           ON FPS.BILLING_PROV_DIM_SEQ = BILL.PROV_DIM_SEQ
       LEFT JOIN DARTEDM.D_PROV PROV ON FPS.PROV_DIM_SEQ = PROV.PROV_DIM_SEQ
       LEFT JOIN DARTEDM.D_PROV SUP
           ON FPS.SUPER_PROV_DIM_SEQ = SUP.PROV_DIM_SEQ
       LEFT JOIN DARTEDM.D_PROC PR ON FPS.PROC_DIM_SEQ = PR.PROC_DIM_SEQ
       LEFT JOIN DARTEDM.D_CLIN_DEPT DEPT
           ON FPS.CLIN_DEPT_DIM_SEQ = DEPT.CLIN_DEPT_DIM_SEQ
       LEFT JOIN
       (  SELECT RVU, CPT_CD, CALENDAR_DIM_SEQ
            FROM DARTEDM.F_CPT_MEASURE FM
                 JOIN DARTEDM.D_CPT_CD CPT ON FM.CPT_DIM_SEQ = CPT.CPT_DIM_SEQ
           WHERE RVU IS NOT NULL
        GROUP BY RVU, CPT_CD, CALENDAR_DIM_SEQ) CPT
           ON     PR.CPT_CD = CPT.CPT_CD
              AND SUBSTR (TO_CHAR (FPS.SERVICE_DT_DIM_SEQ), 1, 4) = SUBSTR (TO_CHAR (CPT.CALENDAR_DIM_SEQ), 1, 4)
       LEFT JOIN DARTEDM.D_CPT_CD CPT1 ON PR.CPT_CD = CPT1.CPT_CD
WHERE FPS.TXN_TYPE_NM = 'CHARGE' AND FPS.ACCT_CLASS_NM = 'OUTPATIENT' AND FPS.DART_CREATE_SRC_CD = 'COR' -- LEGACY CHARGES
;

SELECT count(*) as CNT FROM (
SELECT DISTINCT
    de.empl_dim_seq,
    dp.prov_dim_seq,
    dp.epic_prov_id,
    fead.DISTRIB_PCT
FROM
    dartedm.d_empl de
    INNER JOIN dartadm.user_login ul ON ul.empl_id = de.empl_id
    INNER JOIN dartedm.d_prov dp ON dp.phs_id = ul.opr_id
    LEFT JOIN (SELECT DISTINCT empl_dim_seq, ALLOC_DT_DIM_SEQ, DISTRIB_PCT FROM dartedm.f_empl_alloc_detail) fead ON de.empl_dim_seq=fead.empl_dim_seq
);

SELECT COUNT(*) AS CNT FROM (
SELECT DISTINCT
    t1.empl_dim_seq,
    t1.PROJ_DIM_SEQ,
    t1.FN_DEPT_DIM_SEQ,
    t1.distrib_pct,
    t1.EFFORT_PCT,
    t4.epic_prov_id,
    t5.proj_start_dt,
    t5.proj_end_dt
FROM
    dartedm.f_empl_alloc_detail t1 
    LEFT JOIN dartedm.d_empl t2 ON t1.empl_dim_seq=t2.empl_dim_seq
    LEFT JOIN (SELECT DISTINCT empl_id, opr_id FROM dartadm.user_login WHERE empl_id NOT IN (' ', '033856', 'ACCOUNT NID', '035224')) t3 ON t2.empl_id=t3.empl_id
    LEFT JOIN (SELECT DISTINCT phs_id, epic_prov_id from dartedm.d_prov WHERE LENGTH(epic_prov_id)=7 and epic_prov_id IS NOT NULL) t4 ON t3.opr_id = t4.phs_id 
    LEFT JOIN dartedm.d_proj t5 ON t1.proj_dim_seq=t5.proj_dim_seq
WHERE t4.epic_prov_id IS NOT NULL AND t2.empl_id='000156'
);   

SELECT PHS_ID, count(PHS_ID) as cnt
FROM (SELECT DISTINCT phs_id, epic_prov_id from dartedm.d_prov where length(epic_prov_id)=7 and epic_prov_id IS NOT NULL)
group by PHS_ID
ORDER BY CNT DESC;

SELECT *
FROM dartedm.d_prov
WHERE phs_id='CL86';

SELECT empl_id, count(empl_id) as cnt 
from (SELECT DISTINCT empl_id, opr_id FROM dartadm.user_login WHERE empl_id NOT IN (' ', '033856', 'ACCOUNT NID', '035224'))
group by empl_id
order by cnt desc;

SELECT *
FROM dartadm.user_login;
--WHERE empl_id='033856';

SELECT
    prov.epic_prov_id,
    cal.academic_yr,
    round(
        SUM(hrs.std_hrs_alloc * alloc.distrib_pct / 100 / yr_days.no_of_days) * 100,
        3
    ) distrib_pct
FROM
    dartedm.f_empl_alloc_detail alloc
    LEFT JOIN dartedm.f_empl_std_hrs_alloc hrs ON (
            hrs.empl_dim_seq = alloc.empl_dim_seq
        AND
            hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq
    )
    LEFT JOIN dartedm.d_calendar cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
    LEFT JOIN dartedm.d_empl emp ON emp.empl_dim_seq = alloc.empl_dim_seq
    LEFT JOIN dartadm.user_login login ON login.empl_id = emp.empl_id
    JOIN dartedm.d_prov prov ON prov.phs_id = login.opr_id
    LEFT JOIN (
        SELECT
            cal_sub.academic_yr,
            COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
        FROM
            dartedm.d_calendar cal_sub
        GROUP BY
            cal_sub.academic_yr
    ) yr_days ON yr_days.academic_yr = cal.academic_yr
WHERE
    alloc.active_ind = 'A'
GROUP BY
    cal.academic_yr,
    prov.epic_prov_id
ORDER BY prov.epic_prov_id;
