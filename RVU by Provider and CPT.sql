SELECT a16.MONTH_NBR,
       UPPER(SUBSTR(a16.MTH_NM, 1, 3)) CustCol_11,
       a12.EPIC_PROV_ID PROV_ID,
       (CASE
             WHEN a15.PROC_CD = '372288' THEN '99203'
             WHEN a15.PROC_CD = '372292' THEN '99204'
             WHEN a15.PROC_CD = '372298' THEN '99205'
             WHEN a15.PROC_CD = '372304' THEN '99211'
             WHEN a15.PROC_CD = '372322' THEN '99213'
             WHEN a15.PROC_CD = '372332' THEN '99214'
             WHEN a15.PROC_CD = '372350' THEN '99215'
             ELSE a15.CPT_CD END) CPT_CD,
       a17.CPT_CD_DESCR CPT_DESCR,
       a15.PROC_NM SERVICE_DESCR,
       a16.ACADEMIC_PERIOD,
       a16.CALENDAR_YR,
       CASE WHEN TRIM(a14.MO_DIVISION_NM) IS NULL THEN 'N/A'
            ELSE TRIM(a14.MO_DIVISION_NM) END MO_DIVISION_NM,
       CASE WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
            ELSE TRIM(a14.DISEASE_GRP_ABBREV) END CLIN_DEPT_GRP1,
       CASE WHEN TRIM(a14.SITE_NM) IS NULL THEN 'N/A'
            ELSE TRIM(a14.SITE_NM) END SITE_NM,
       a12.DISEASE_GRP_DESCR DISEASE_GRP_FN_DEPT_DESCR,
       a12.EPIC_PROV_ID PROV_ID0,
       a12.PROV_NM PROV_NM,
       SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) MONTHLYRVU,
       SUM(a11.TOT_SERVICE_QTY) MTDQUANTITY
  FROM (   SELECT RVU.PROV_DIM_SEQ,
                  RVU.PROC_DIM_SEQ,
                  BEG_MTH_DIM_SEQ,
                  INST_DIM_SEQ,
                  CLIN_DEPT_DIM_SEQ,
                  INPAT_OUTPAT_IND,
                  (CASE
                        WHEN PROV.PROV_TYPE_DESCR = 'PHYSICIAN' THEN -1
                        ELSE SUPER_PROV_DIM_SEQ END) SUPER_PROV_DIM_SEQ,
                  TOT_SERVICE_QTY,
                  TOT_WORK_RVU_AMT,
                  TOT_SERVICE_AMT,
                  RVU.DART_CREATE_DTTM
             FROM DARTEDM.F_MTHLY_PROV_SERVICE_RVU RVU
             JOIN DARTEDM.D_PROV PROV
               ON RVU.PROV_DIM_SEQ = PROV.PROV_DIM_SEQ) a11
  LEFT OUTER JOIN DARTEDM.D_PROV a12
    ON (a11.PROV_DIM_SEQ                        = a12.PROV_DIM_SEQ)
  LEFT OUTER JOIN DARTEDM.D_CLIN_DEPT a13
    ON (a11.CLIN_DEPT_DIM_SEQ                   = a13.CLIN_DEPT_DIM_SEQ)
  LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a14
    ON (   (CASE
                 WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                 ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                        WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                                        ELSE a14.CLIN_DEPT_ABBREV END)
     AND   a12.EPIC_PROV_ID                     = a14.EPIC_PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_PROC a15
    ON (a11.PROC_DIM_SEQ                        = a15.PROC_DIM_SEQ)
  LEFT OUTER JOIN DARTEDM.D_CALENDAR a16
    ON (a11.BEG_MTH_DIM_SEQ                     = a16.CALENDAR_DIM_SEQ)
  LEFT OUTER JOIN DARTEDM.D_CPT_CD a17
    ON ((CASE
              WHEN a15.PROC_CD = '372288' THEN '99203'
              WHEN a15.PROC_CD = '372292' THEN '99204'
              WHEN a15.PROC_CD = '372298' THEN '99205'
              WHEN a15.PROC_CD = '372304' THEN '99211'
              WHEN a15.PROC_CD = '372322' THEN '99213'
              WHEN a15.PROC_CD = '372332' THEN '99214'
              WHEN a15.PROC_CD = '372350' THEN '99215'
              ELSE a15.CPT_CD END)              = (CASE
                                                        WHEN a17.CPT_CD IS NULL THEN 'N/A'
                                                        ELSE a17.CPT_CD END))
 WHERE (   (CASE
                 WHEN TRIM(a14.MO_DIVISION_NM) IS NULL THEN 'N/A'
                 ELSE TRIM(a14.MO_DIVISION_NM) END) NOT IN ( 'N/A' )
     AND   a12.INT_EXT_IND IN ( 'E' )
     AND   (CASE
                 WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                 ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
     AND   a16.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                         FROM DARTEDM.D_CALENDAR
                                        WHERE ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                                  FROM DARTEDM.D_CALENDAR
                                                                 WHERE CALENDAR_DT = To_Date('31-07-2017', 'dd-mm-yyyy'))) AND To_Date(
                                                                                                                                   '31-07-2017',
                                                                                                                                   'dd-mm-yyyy'))
 GROUP BY a16.MONTH_NBR,
          UPPER(SUBSTR(a16.MTH_NM, 1, 3)),
          a12.EPIC_PROV_ID,
          (CASE
                WHEN a15.PROC_CD = '372288' THEN '99203'
                WHEN a15.PROC_CD = '372292' THEN '99204'
                WHEN a15.PROC_CD = '372298' THEN '99205'
                WHEN a15.PROC_CD = '372304' THEN '99211'
                WHEN a15.PROC_CD = '372322' THEN '99213'
                WHEN a15.PROC_CD = '372332' THEN '99214'
                WHEN a15.PROC_CD = '372350' THEN '99215'
                ELSE a15.CPT_CD END),
          a17.CPT_CD_DESCR,
          a15.PROC_NM,
          a16.ACADEMIC_PERIOD,
          a16.CALENDAR_YR,
          (CASE
                WHEN TRIM(a14.MO_DIVISION_NM) IS NULL THEN 'N/A'
                ELSE TRIM(a14.MO_DIVISION_NM) END),
          (CASE
                WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                ELSE TRIM(a14.DISEASE_GRP_ABBREV) END),
          (CASE
                WHEN TRIM(a14.SITE_NM) IS NULL THEN 'N/A'
                ELSE TRIM(a14.SITE_NM) END),
          a12.DISEASE_GRP_DESCR,
          a12.EPIC_PROV_ID,
          a12.PROV_NM;
