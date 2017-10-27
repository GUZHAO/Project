
        
SELECT DISTINCT 
       COALESCE(pa11.DISEASE_GRP_FN_DEPT_DESCR,
                pa12.DISEASE_GRP_FN_DEPT_DESCR,
                pa13.DISEASE_GRP_FN_DEPT_DESCR,
                pa14.DISEASE_GRP_FN_DEPT_DESCR) DISEASE_GRP_FN_DEPT_DESCR,
       COALESCE(pa11.DISEASE_SUBGRP_DESCR, 
                pa12.DISEASE_SUBGRP_DESCR, 
                pa13.DISEASE_SUBGRP_DESCR, 
                pa14.DISEASE_SUBGRP_DESCR) DISEASE_SUBGRP_DESCR,
       COALESCE(pa11.PROV_ID, 
                pa12.PROV_ID, 
                pa13.PROV_ID, 
                pa14.PROV_ID) PROV_ID,
       COALESCE(pa11.PROV_ID0, 
                pa12.PROV_ID0, 
                pa13.PROV_ID0, 
                pa14.PROV_ID0) PROV_ID0,
       a15.PROV_NM PROV_NM,
       COALESCE(pa11.PROV_TYPE_CD, 
                pa12.PROV_TYPE_CD, 
                pa13.PROV_TYPE_CD, 
                pa14.PROV_TYPE_CD) PROV_TYPE_CD,
       COALESCE(pa11.PROV_TYPE_CD0, 
                pa12.PROV_TYPE_CD0, 
                pa13.PROV_TYPE_CD0, 
                pa14.PROV_TYPE_CD0) PROV_TYPE_CD0,
       pa11.CURRENTMONTHINPATIENTRVU CURRENTMONTHINPATIENTRVU,
       pa12.CURRENTMONTHOUTPATIENTRVU CURRENTMONTHOUTPATIENTRVU,
       (NVL(pa11.CURRENTMONTHINPATIENTRVU, 0) + NVL(pa12.CURRENTMONTHOUTPATIENTRVU, 0)) CURRENTMONTHTOTALRVU,
       pa13.CURRENTYEARINPATIENTRVU CURRENTYEARINPATIENTRVU,
       pa14.CURRENTYEAROUTPATIENTRVU CURRENTYEAROUTPATIENTRVU,
       (NVL(pa13.CURRENTYEARINPATIENTRVU, 0) + NVL(pa14.CURRENTYEAROUTPATIENTRVU, 0)) CURRENTYEARTOTALRVU
  FROM (   SELECT a12.EPIC_PROV_ID PROV_ID,
                  CASE
                       WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                       WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                       ELSE 'N/A' END PROV_TYPE_CD,
                  CASE
                       WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                       WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                       WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                       ELSE 'N/A' END PROV_TYPE_CD0,
                  a12.EPIC_PROV_ID PROV_ID0,
                  a12.DISEASE_GRP_DESCR DISEASE_GRP_FN_DEPT_DESCR,
                  a12.DISEASE_SUBGRP_DESCR DISEASE_SUBGRP_DESCR,
                  SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTMONTHINPATIENTRVU
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
                        JOIN DARTEDM.D_PROV PROV ON RVU.PROV_DIM_SEQ = PROV.PROV_DIM_SEQ) a11
             LEFT JOIN DARTEDM.D_PROV a12 ON (a11.PROV_DIM_SEQ = a12.PROV_DIM_SEQ)
             LEFT JOIN DARTEDM.D_CLIN_DEPT a13 ON (a11.CLIN_DEPT_DIM_SEQ = a13.CLIN_DEPT_DIM_SEQ)
             LEFT JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a14 ON (   (CASE WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                                                       ELSE a13.CLIN_DEPT_ABBREV END) = (CASE WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                                                                                              ELSE a14.CLIN_DEPT_ABBREV END)
                AND   a12.EPIC_PROV_ID = a14.EPIC_PROV_ID)
             LEFT JOIN DARTEDM.D_CALENDAR a15 ON (a11.BEG_MTH_DIM_SEQ = a15.CALENDAR_DIM_SEQ)
            WHERE (   a12.INT_EXT_IND IN ( 'E' )
                AND   (CASE
                            WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                    FROM DARTEDM.D_CALENDAR
                                                   WHERE MONTH_NBR   = (   SELECT MONTH_NBR
                                                                             FROM DARTEDM.D_CALENDAR
                                                                            WHERE CALENDAR_DT = To_Date(
                                                                                                    '31-07-2017',
                                                                                                    'dd-mm-yyyy'))
                                                     AND ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                                             FROM DARTEDM.D_CALENDAR
                                                                            WHERE CALENDAR_DT = To_Date(
                                                                                                    '31-07-2017',
                                                                                                    'dd-mm-yyyy'))) AND To_Date(
                                                                                                                            '31-07-2017',
                                                                                                                            'dd-mm-yyyy')
                AND   (CASE
                            WHEN a11.INPAT_OUTPAT_IND = 'O' THEN 'OUTPATIENT'
                            WHEN a11.INPAT_OUTPAT_IND = 'I' THEN 'INPATIENT'
                            ELSE '' END) IN ( 'INPATIENT' ))
            GROUP BY a12.EPIC_PROV_ID,
                     CASE
                          WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                          WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                          ELSE 'N/A' END,
                     CASE
                          WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                          WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                          WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                          ELSE 'N/A' END,
                     a12.EPIC_PROV_ID,
                     a12.DISEASE_GRP_DESCR,
                     a12.DISEASE_SUBGRP_DESCR) pa11
  FULL OUTER JOIN (   SELECT a12.EPIC_PROV_ID PROV_ID,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD0,
                             a12.EPIC_PROV_ID PROV_ID0,
                             a12.DISEASE_GRP_DESCR DISEASE_GRP_FN_DEPT_DESCR,
                             a12.DISEASE_SUBGRP_DESCR DISEASE_SUBGRP_DESCR,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTMONTHOUTPATIENTRVU
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
                                                                              WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a14.CLIN_DEPT_ABBREV END)
                           AND   a12.EPIC_PROV_ID                     = a14.EPIC_PROV_ID)
                        LEFT OUTER JOIN DARTEDM.D_CALENDAR a15
                          ON (a11.BEG_MTH_DIM_SEQ                     = a15.CALENDAR_DIM_SEQ)
                       WHERE (   a12.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                           AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                               FROM DARTEDM.D_CALENDAR
                                                              WHERE MONTH_NBR   = (   SELECT MONTH_NBR
                                                                                        FROM DARTEDM.D_CALENDAR
                                                                                       WHERE CALENDAR_DT = To_Date(
                                                                                                               '31-07-2017',
                                                                                                               'dd-mm-yyyy'))
                                                                AND ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                                                        FROM DARTEDM.D_CALENDAR
                                                                                       WHERE CALENDAR_DT = To_Date(
                                                                                                               '31-07-2017',
                                                                                                               'dd-mm-yyyy'))) AND To_Date(
                                                                                                                                       '31-07-2017',
                                                                                                                                       'dd-mm-yyyy')
                           AND   (CASE
                                       WHEN a11.INPAT_OUTPAT_IND = 'O' THEN 'OUTPATIENT'
                                       WHEN a11.INPAT_OUTPAT_IND = 'I' THEN 'INPATIENT'
                                       ELSE '' END) IN ( 'OUTPATIENT' ))
                       GROUP BY a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.DISEASE_GRP_DESCR,
                                a12.DISEASE_SUBGRP_DESCR) pa12
    ON (pa11.PROV_ID                                                     = pa12.PROV_ID)
  FULL OUTER JOIN (   SELECT a12.EPIC_PROV_ID PROV_ID,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD0,
                             a12.EPIC_PROV_ID PROV_ID0,
                             a12.DISEASE_GRP_DESCR DISEASE_GRP_FN_DEPT_DESCR,
                             a12.DISEASE_SUBGRP_DESCR DISEASE_SUBGRP_DESCR,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTYEARINPATIENTRVU
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
                                                                              WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a14.CLIN_DEPT_ABBREV END)
                           AND   a12.EPIC_PROV_ID                     = a14.EPIC_PROV_ID)
                        LEFT OUTER JOIN DARTEDM.D_CALENDAR a15
                          ON (a11.BEG_MTH_DIM_SEQ                     = a15.CALENDAR_DIM_SEQ)
                       WHERE (   a12.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                           AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                               FROM DARTEDM.D_CALENDAR
                                                              WHERE ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                                                        FROM DARTEDM.D_CALENDAR
                                                                                       WHERE CALENDAR_DT = To_Date(
                                                                                                               '31-07-2017',
                                                                                                               'dd-mm-yyyy'))) AND To_Date(
                                                                                                                                       '31-07-2017',
                                                                                                                                       'dd-mm-yyyy')
                           AND   (CASE
                                       WHEN a11.INPAT_OUTPAT_IND = 'O' THEN 'OUTPATIENT'
                                       WHEN a11.INPAT_OUTPAT_IND = 'I' THEN 'INPATIENT'
                                       ELSE '' END) IN ( 'INPATIENT' ))
                       GROUP BY a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.DISEASE_GRP_DESCR,
                                a12.DISEASE_SUBGRP_DESCR) pa13
    ON (COALESCE(pa11.PROV_ID, pa12.PROV_ID)                             = pa13.PROV_ID)
  FULL OUTER JOIN (   SELECT a12.EPIC_PROV_ID PROV_ID,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD0,
                             a12.EPIC_PROV_ID PROV_ID0,
                             a12.DISEASE_GRP_DESCR DISEASE_GRP_FN_DEPT_DESCR,
                             a12.DISEASE_SUBGRP_DESCR DISEASE_SUBGRP_DESCR,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTYEAROUTPATIENTRVU
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
                                                                              WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a14.CLIN_DEPT_ABBREV END)
                           AND   a12.EPIC_PROV_ID                     = a14.EPIC_PROV_ID)
                        LEFT OUTER JOIN DARTEDM.D_CALENDAR a15
                          ON (a11.BEG_MTH_DIM_SEQ                     = a15.CALENDAR_DIM_SEQ)
                       WHERE (   a12.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                           AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                               FROM DARTEDM.D_CALENDAR
                                                              WHERE ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                                                        FROM DARTEDM.D_CALENDAR
                                                                                       WHERE CALENDAR_DT = To_Date('31-07-2017','dd-mm-yyyy'))) 
                           AND To_Date('31-07-2017','dd-mm-yyyy')
                           AND (CASE
                                       WHEN a11.INPAT_OUTPAT_IND = 'O' THEN 'OUTPATIENT'
                                       WHEN a11.INPAT_OUTPAT_IND = 'I' THEN 'INPATIENT'
                                       ELSE '' END) IN ( 'OUTPATIENT' ))
                       GROUP BY a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PSYCHOLOGIST' ) THEN 'PSYC'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.DISEASE_GRP_DESCR,
                                a12.DISEASE_SUBGRP_DESCR) pa14
    ON (COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID)               = pa14.PROV_ID)
  LEFT JOIN DARTEDM.D_PROV a15
    ON (COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID, pa14.PROV_ID) = a15.EPIC_PROV_ID);