SELECT DISTINCT COALESCE(pa11.PROV_ID2, pa12.PROV_ID2, pa13.PROV_ID2, pa14.PROV_ID2, pa15.PROV_ID2) PROV_ID,
       a18.PROV_NM PROV_NM,
       COALESCE(pa11.PROV_TYPE_CD, pa12.PROV_TYPE_CD, pa13.PROV_TYPE_CD, pa14.PROV_TYPE_CD, pa15.PROV_TYPE_CD) PROV_TYPE_CD,
       COALESCE(pa11.PROV_ID1, pa12.PROV_ID1, pa13.PROV_ID1, pa14.PROV_ID1, pa15.PROV_ID1) PROV_ID0,
       a19.PROV_NM PROV_NM0,
       COALESCE(
           pa11.PROV_TYPE_DESCR, pa12.PROV_TYPE_DESCR, pa13.PROV_TYPE_DESCR, pa14.PROV_TYPE_DESCR, pa15.PROV_TYPE_DESCR) PROV_TYPE_DESCR,
       COALESCE(pa11.PROV_ID0, pa12.PROV_ID0, pa13.PROV_ID0, pa14.PROV_ID0, pa15.PROV_ID0) PROV_ID1,
       COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID, pa14.PROV_ID, pa15.PROV_ID) PROV_ID2,
       a18.EPIC_PROV_ID SUPER_PROV_ID,
       COALESCE(pa11.CLIN_DEPT_GRP1, pa12.CLIN_DEPT_GRP1, pa13.CLIN_DEPT_GRP1, pa14.CLIN_DEPT_GRP1, pa15.CLIN_DEPT_GRP1) CLIN_DEPT_GRP1,
       COALESCE(pa11.CLIN_DEPT_SITE, pa12.CLIN_DEPT_SITE, pa13.CLIN_DEPT_SITE, pa14.CLIN_DEPT_SITE, pa15.CLIN_DEPT_SITE) CLIN_DEPT_SITE,
       pa11.CURRENTYEARINPATIENTRVU CURRENTYEARINPATIENTRVU,
       pa12.CURRENTYEAROUTPATIENTRVU CURRENTYEAROUTPATIENTRVU,
       (NVL(pa11.CURRENTYEARINPATIENTRVU, 0) + NVL(pa12.CURRENTYEAROUTPATIENTRVU, 0)) CURRENTYEARTOTALRVU,
       pa13.CURRENTYEARTOTALMDRVU CURRENTYEARTOTALMDRVU,
       pa14.CURRENTQUARTERINPATIENTRVU CURRENTQUARTERINPATIENTRVU,
       pa15.CURRENTQUARTEROUTPATIENTRVU CURRENTQUARTEROUTPATIENTRVU,
       (NVL(pa14.CURRENTQUARTERINPATIENTRVU, 0) + NVL(pa15.CURRENTQUARTEROUTPATIENTRVU, 0)) CURRENTQUARTERTOTALRVU,
       (CASE
             WHEN pa16.MAXPROVTYPE = 'PHYSICIAN' THEN pa17.SUPEREFFORT
             ELSE 0 END) ADJUSTEDSUPEREFFORT
  FROM (   SELECT (CASE
                        WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                        ELSE TRIM(a17.SITE_NM) END) CLIN_DEPT_SITE,
                  (CASE
                        WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                        ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
                  a16.EPIC_PROV_ID PROV_ID,
                  a12.EPIC_PROV_ID PROV_ID0,
                  CASE
                       WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                       WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                       ELSE 'N/A' END PROV_TYPE_CD,
                  a12.EPIC_PROV_ID PROV_ID1,
                  a12.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                  a16.EPIC_PROV_ID PROV_ID2,
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
                                                                   WHEN a14.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                                                   ELSE a14.CLIN_DEPT_ABBREV END)
                AND   a12.EPIC_PROV_ID                     = a14.EPIC_PROV_ID)
             LEFT OUTER JOIN DARTEDM.D_CALENDAR a15
               ON (a11.BEG_MTH_DIM_SEQ                     = a15.CALENDAR_DIM_SEQ)
             LEFT OUTER JOIN DARTEDM.D_PROV a16
               ON ((CASE
                         WHEN a11.SUPER_PROV_DIM_SEQ = -1 THEN a11.PROV_DIM_SEQ
                         ELSE a11.SUPER_PROV_DIM_SEQ END)  = a16.PROV_DIM_SEQ)
             LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
               ON (   (CASE
                            WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                            ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                                   WHEN a17.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                                                   ELSE a17.CLIN_DEPT_ABBREV END)
                AND   a16.EPIC_PROV_ID                     = a17.EPIC_PROV_ID)
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
            GROUP BY (CASE
                           WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                           ELSE TRIM(a17.SITE_NM) END),
                     (CASE
                           WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                           ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
                     a16.EPIC_PROV_ID,
                     a12.EPIC_PROV_ID,
                     CASE
                          WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                          WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN 'NP/PA'
                          ELSE 'N/A' END,
                     a12.EPIC_PROV_ID,
                     a12.PROV_TYPE_DESCR,
                     a16.EPIC_PROV_ID) pa11
  FULL OUTER JOIN (   SELECT (CASE
                                   WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.SITE_NM) END) CLIN_DEPT_SITE,
                             (CASE
                                   WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
                             a16.EPIC_PROV_ID PROV_ID,
                             a12.EPIC_PROV_ID PROV_ID0,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             a12.EPIC_PROV_ID PROV_ID1,
                             a12.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                             a16.EPIC_PROV_ID PROV_ID2,
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
                        LEFT OUTER JOIN DARTEDM.D_PROV a16
                          ON ((CASE
                                    WHEN a11.SUPER_PROV_DIM_SEQ = -1 THEN a11.PROV_DIM_SEQ
                                    ELSE a11.SUPER_PROV_DIM_SEQ END)  = a16.PROV_DIM_SEQ)
                        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
                          ON (   (CASE
                                       WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                       ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                                              WHEN a17.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a17.CLIN_DEPT_ABBREV END)
                           AND   a16.EPIC_PROV_ID                     = a17.EPIC_PROV_ID)
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
                                       ELSE '' END) IN ( 'OUTPATIENT' ))
                       GROUP BY (CASE
                                      WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.SITE_NM) END),
                                (CASE
                                      WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
                                a16.EPIC_PROV_ID,
                                a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.PROV_TYPE_DESCR,
                                a16.EPIC_PROV_ID) pa12
    ON (   pa11.CLIN_DEPT_GRP1                                                                                          = pa12.CLIN_DEPT_GRP1
     AND   pa11.CLIN_DEPT_SITE                                                                                          = pa12.CLIN_DEPT_SITE
     AND   pa11.PROV_ID                                                                                                 = pa12.PROV_ID
     AND   pa11.PROV_ID0                                                                                                = pa12.PROV_ID0)
  FULL OUTER JOIN (   SELECT (CASE
                                   WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.SITE_NM) END) CLIN_DEPT_SITE,
                             (CASE
                                   WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
                             a16.EPIC_PROV_ID PROV_ID,
                             a12.EPIC_PROV_ID PROV_ID0,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             a12.EPIC_PROV_ID PROV_ID1,
                             a12.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                             a16.EPIC_PROV_ID PROV_ID2,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTYEARTOTALMDRVU
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
                        LEFT OUTER JOIN DARTEDM.D_PROV a16
                          ON ((CASE
                                    WHEN a11.SUPER_PROV_DIM_SEQ = -1 THEN a11.PROV_DIM_SEQ
                                    ELSE a11.SUPER_PROV_DIM_SEQ END)  = a16.PROV_DIM_SEQ)
                        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
                          ON (   (CASE
                                       WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                       ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                                              WHEN a17.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a17.CLIN_DEPT_ABBREV END)
                           AND   a16.EPIC_PROV_ID                     = a17.EPIC_PROV_ID)
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
                           AND   a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ))
                       GROUP BY (CASE
                                      WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.SITE_NM) END),
                                (CASE
                                      WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
                                a16.EPIC_PROV_ID,
                                a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.PROV_TYPE_DESCR,
                                a16.EPIC_PROV_ID) pa13
    ON (   COALESCE(pa11.CLIN_DEPT_GRP1, pa12.CLIN_DEPT_GRP1)                                                           = pa13.CLIN_DEPT_GRP1
     AND   COALESCE(pa11.CLIN_DEPT_SITE, pa12.CLIN_DEPT_SITE)                                                           = pa13.CLIN_DEPT_SITE
     AND   COALESCE(pa11.PROV_ID, pa12.PROV_ID)                                                                         = pa13.PROV_ID
     AND   COALESCE(pa11.PROV_ID0, pa12.PROV_ID0)                                                                       = pa13.PROV_ID0)
  FULL OUTER JOIN (   SELECT (CASE
                                   WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.SITE_NM) END) CLIN_DEPT_SITE,
                             (CASE
                                   WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
                             a16.EPIC_PROV_ID PROV_ID,
                             a12.EPIC_PROV_ID PROV_ID0,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             a12.EPIC_PROV_ID PROV_ID1,
                             a12.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                             a16.EPIC_PROV_ID PROV_ID2,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTQUARTERINPATIENTRVU
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
                        LEFT OUTER JOIN DARTEDM.D_PROV a16
                          ON ((CASE
                                    WHEN a11.SUPER_PROV_DIM_SEQ = -1 THEN a11.PROV_DIM_SEQ
                                    ELSE a11.SUPER_PROV_DIM_SEQ END)  = a16.PROV_DIM_SEQ)
                        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
                          ON (   (CASE
                                       WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                       ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                                              WHEN a17.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a17.CLIN_DEPT_ABBREV END)
                           AND   a16.EPIC_PROV_ID                     = a17.EPIC_PROV_ID)
                       WHERE (   a12.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                           AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                               FROM DARTEDM.D_CALENDAR
                                                              WHERE ACADEMIC_QTR = (   SELECT ACADEMIC_QTR
                                                                                         FROM DARTEDM.D_CALENDAR
                                                                                        WHERE CALENDAR_DT = To_Date(
                                                                                                                '31-07-2017',
                                                                                                                'dd-mm-yyyy'))
                                                                AND ACADEMIC_YR  = (   SELECT ACADEMIC_YR
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
                       GROUP BY (CASE
                                      WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.SITE_NM) END),
                                (CASE
                                      WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
                                a16.EPIC_PROV_ID,
                                a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.PROV_TYPE_DESCR,
                                a16.EPIC_PROV_ID) pa14
    ON (   COALESCE(pa11.CLIN_DEPT_GRP1, pa12.CLIN_DEPT_GRP1, pa13.CLIN_DEPT_GRP1)                                      = pa14.CLIN_DEPT_GRP1
     AND   COALESCE(pa11.CLIN_DEPT_SITE, pa12.CLIN_DEPT_SITE, pa13.CLIN_DEPT_SITE)                                      = pa14.CLIN_DEPT_SITE
     AND   COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID)                                                           = pa14.PROV_ID
     AND   COALESCE(pa11.PROV_ID0, pa12.PROV_ID0, pa13.PROV_ID0)                                                        = pa14.PROV_ID0)
  FULL OUTER JOIN (   SELECT (CASE
                                   WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.SITE_NM) END) CLIN_DEPT_SITE,
                             (CASE
                                   WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                   ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
                             a16.EPIC_PROV_ID PROV_ID,
                             a12.EPIC_PROV_ID PROV_ID0,
                             CASE
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             a12.EPIC_PROV_ID PROV_ID1,
                             a12.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                             a16.EPIC_PROV_ID PROV_ID2,
                             SUM(NVL(a11.TOT_WORK_RVU_AMT, 0)) CURRENTQUARTEROUTPATIENTRVU
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
                        LEFT OUTER JOIN DARTEDM.D_PROV a16
                          ON ((CASE
                                    WHEN a11.SUPER_PROV_DIM_SEQ = -1 THEN a11.PROV_DIM_SEQ
                                    ELSE a11.SUPER_PROV_DIM_SEQ END)  = a16.PROV_DIM_SEQ)
                        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
                          ON (   (CASE
                                       WHEN a13.CLIN_DEPT_ABBREV IS NULL THEN 'N/A'
                                       ELSE a13.CLIN_DEPT_ABBREV END) = (CASE
                                                                              WHEN a17.CLIN_DEPT_ABBREV IS NULL THEN
                                                                                  'N/A'
                                                                              ELSE a17.CLIN_DEPT_ABBREV END)
                           AND   a16.EPIC_PROV_ID                     = a17.EPIC_PROV_ID)
                       WHERE (   a12.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a14.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a14.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' )
                           AND   a15.CALENDAR_DT BETWEEN (   SELECT MIN(CALENDAR_DT)
                                                               FROM DARTEDM.D_CALENDAR
                                                              WHERE ACADEMIC_QTR = (   SELECT ACADEMIC_QTR
                                                                                         FROM DARTEDM.D_CALENDAR
                                                                                        WHERE CALENDAR_DT = To_Date(
                                                                                                                '31-07-2017',
                                                                                                                'dd-mm-yyyy'))
                                                                AND ACADEMIC_YR  = (   SELECT ACADEMIC_YR
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
                       GROUP BY (CASE
                                      WHEN TRIM(a17.SITE_NM) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.SITE_NM) END),
                                (CASE
                                      WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                      ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
                                a16.EPIC_PROV_ID,
                                a12.EPIC_PROV_ID,
                                CASE
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a12.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a12.EPIC_PROV_ID,
                                a12.PROV_TYPE_DESCR,
                                a16.EPIC_PROV_ID) pa15
    ON (   COALESCE(pa11.CLIN_DEPT_GRP1, pa12.CLIN_DEPT_GRP1, pa13.CLIN_DEPT_GRP1, pa14.CLIN_DEPT_GRP1)                 = pa15.CLIN_DEPT_GRP1
     AND   COALESCE(pa11.CLIN_DEPT_SITE, pa12.CLIN_DEPT_SITE, pa13.CLIN_DEPT_SITE, pa14.CLIN_DEPT_SITE)                 = pa15.CLIN_DEPT_SITE
     AND   COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID, pa14.PROV_ID)                                             = pa15.PROV_ID
     AND   COALESCE(pa11.PROV_ID0, pa12.PROV_ID0, pa13.PROV_ID0, pa14.PROV_ID0)                                         = pa15.PROV_ID0)
  LEFT OUTER JOIN (   SELECT a11.EPIC_PROV_ID PROV_ID,
                             CASE
                                  WHEN a11.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                  WHEN a11.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                      'NP/PA'
                                  ELSE 'N/A' END PROV_TYPE_CD,
                             a11.EPIC_PROV_ID PROV_ID0,
                             a11.PROV_TYPE_DESCR PROV_TYPE_DESCR,
                             MAX(a11.PROV_TYPE_DESCR) MAXPROVTYPE
                        FROM DARTEDM.D_PROV a11
                        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a12
                          ON (a11.EPIC_PROV_ID = a12.EPIC_PROV_ID)
                       WHERE (   a11.INT_EXT_IND IN ( 'E' )
                           AND   (CASE
                                       WHEN TRIM(a12.DISEASE_GRP_ABBREV) IS NULL THEN 'N/A'
                                       ELSE TRIM(a12.DISEASE_GRP_ABBREV) END) NOT IN ( 'STIPEND' ))
                       GROUP BY a11.EPIC_PROV_ID,
                                CASE
                                     WHEN a11.PROV_TYPE_DESCR IN ( 'PHYSICIAN' ) THEN 'MD'
                                     WHEN a11.PROV_TYPE_DESCR IN ( 'NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT' ) THEN
                                         'NP/PA'
                                     ELSE 'N/A' END,
                                a11.EPIC_PROV_ID,
                                a11.PROV_TYPE_DESCR) pa16
    ON (COALESCE(pa11.PROV_ID0, pa12.PROV_ID0, pa13.PROV_ID0, pa14.PROV_ID0, pa15.PROV_ID0)                             = pa16.PROV_ID)
  LEFT OUTER JOIN (   SELECT (CASE
                                   WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-LNH' THEN 'LONDONDERRY'
                                   WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-MH' THEN 'MILFORD'
                                   WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SS' THEN 'SOUTH SHORE'
                                   WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SE' THEN 'ST ELIZABETHS'
                                   ELSE 'LONGWOOD' END) CLIN_DEPT_SITE,
                             a11.PROV_ALLOC_DISEASE_GRP CLIN_DEPT_GRP1,
                             a12.EPIC_PROV_ID PROV_ID,
                             a12.EPIC_PROV_ID PROV_ID0,
                             SUM((a11.EFFORT_PCT / 100)) SUPEREFFORT
                        FROM (   SELECT PROV_DIM_SEQ,
                                        EMPL_NM,
                                        PROV_NM,
                                        EMPL_ID,
                                        EPIC_PROV_ID,
                                        PROV_STATUS,
                                        PROV_TYPE_DESCR,
                                        ACADEMIC_YR,
                                        PROV_PRIM_DISEASE_GRP,
                                        XREF.DISEASE_GRP_DESCR PROV_ALLOC_DISEASE_GRP,
                                        EFF.FN_DEPT_ID,
                                        FN_DEPT_NM,
                                        WEEKLY_HOURS,
                                        DAILY_EFFORT_PCT_SUM,
                                        DAILY_DISTRIB_PCT_SUM,
                                        DAYS_IN_YEAR,
                                        EFFORT_PCT,
                                        DISTRIB_PCT
                                   FROM DARTEDM.MV_RVU_PROV_EFFORT EFF
                                   JOIN MICROSTRAT.DS_FN_DEPT_DISEASE_GRP_XREF XREF
                                     ON EFF.FN_DEPT_ID = XREF.FN_DEPT_ID) a11
                        LEFT OUTER JOIN DARTEDM.D_PROV a12
                          ON (a11.PROV_DIM_SEQ = a12.PROV_DIM_SEQ)
                       WHERE a11.ACADEMIC_YR = (   SELECT ACADEMIC_YR
                                                     FROM DARTEDM.D_CALENDAR
                                                    WHERE CALENDAR_DT = To_Date('31-07-2017', 'dd-mm-yyyy'))
                       GROUP BY (CASE
                                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-LNH' THEN 'LONDONDERRY'
                                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-MH' THEN 'MILFORD'
                                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SS' THEN 'SOUTH SHORE'
                                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SE' THEN 'ST ELIZABETHS'
                                      ELSE 'LONGWOOD' END),
                                a11.PROV_ALLOC_DISEASE_GRP,
                                a12.EPIC_PROV_ID,
                                a12.EPIC_PROV_ID) pa17
    ON (   COALESCE(
               pa11.CLIN_DEPT_GRP1, pa12.CLIN_DEPT_GRP1, pa13.CLIN_DEPT_GRP1, pa14.CLIN_DEPT_GRP1, pa15.CLIN_DEPT_GRP1) = pa17.CLIN_DEPT_GRP1
     AND   COALESCE(
               pa11.CLIN_DEPT_SITE, pa12.CLIN_DEPT_SITE, pa13.CLIN_DEPT_SITE, pa14.CLIN_DEPT_SITE, pa15.CLIN_DEPT_SITE) = pa17.CLIN_DEPT_SITE
     AND   COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID, pa14.PROV_ID, pa15.PROV_ID)                               = pa17.PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_PROV a18
    ON (COALESCE(pa11.PROV_ID, pa12.PROV_ID, pa13.PROV_ID, pa14.PROV_ID, pa15.PROV_ID)                                  = a18.EPIC_PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_PROV a19
    ON (COALESCE(pa11.PROV_ID1, pa12.PROV_ID1, pa13.PROV_ID1, pa14.PROV_ID1, pa15.PROV_ID1)                             = a19.EPIC_PROV_ID);
