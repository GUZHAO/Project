SELECT DISTINCT
    coalesce(
        pa11.prov_id0,
        pa12.prov_id0,
        pa13.prov_id0,
        pa14.prov_id0
    ) prov_id,
    coalesce(
        pa11.prov_nm,
        pa12.prov_nm,
        pa13.prov_nm,
        pa14.prov_nm
    ) prov_nm,
    coalesce(
        pa11.prov_id,
        pa12.prov_id,
        pa13.prov_id,
        pa14.prov_id
    ) prov_id0,
    coalesce(
        pa11.clin_dept_grp1,
        pa12.clin_dept_grp1,
        pa13.clin_dept_grp1,
        pa14.clin_dept_grp1
    ) clin_dept_grp1,
    coalesce(
        pa11.site_nm,
        pa12.site_nm,
        pa13.site_nm,
        pa14.site_nm
    ) site_nm,
    (
        CASE
            WHEN TRIM(a17.mo_division_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a17.mo_division_nm)
        END
    ) mo_division_nm,
    pa11.previousyearinpatientrvu,
    nvl(
        (
            CASE
                WHEN pa15.currentyearacademicperiod <> 12.0 THEN pa11.previousyearinpatientrvu
                ELSE pa12.currentyearinpatientrvu
            END
        ),
        0
    ) currentyearinpatientrvuannual,
    pa13.previousyearoutpatientrvu,
    nvl(
        ( (pa14.currentyearoutpatientrvu / (
            CASE
                WHEN pa15.currentyearacademicperiod = 0 THEN NULL
                ELSE pa15.currentyearacademicperiod
            END
        ) ) * 12.0),
        0
    ) currentyearoutpatientrvuannual,
    ( nvl(pa11.previousyearinpatientrvu,0) + nvl(pa13.previousyearoutpatientrvu,0) ) previousyeartotalrvu,
    ( nvl(
        ( (pa14.currentyearoutpatientrvu / (
            CASE
                WHEN pa15.currentyearacademicperiod = 0 THEN NULL
                ELSE pa15.currentyearacademicperiod
            END
        ) ) * 12.0),
        0
    ) + nvl(
        (
            CASE
                WHEN pa15.currentyearacademicperiod <> 12.0 THEN pa11.previousyearinpatientrvu
                ELSE pa12.currentyearinpatientrvu
            END
        ),
        0
    ) ) currentyeartotalrvuannualized,
    pa16.proveffortprov proveffortprov
FROM
    (
        SELECT
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ) site_nm,
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            a12.prov_nm prov_nm,
            SUM(nvl(a11.tot_work_rvu_amt,0)) previousyearinpatientrvu
        FROM
            (
                SELECT
                    rvu.prov_dim_seq,
                    rvu.proc_dim_seq,
                    rvu.beg_mth_dim_seq,
                    rvu.clin_dept_dim_seq,
                    rvu.inpat_outpat_ind,
                    (
                        CASE
                            WHEN prov.prov_type_descr = 'PHYSICIAN' THEN -1
                            ELSE rvu.super_prov_dim_seq
                        END
                    ) super_prov_dim_seq,
                    rvu.tot_service_qty,
                    rvu.tot_work_rvu_amt,
                    rvu.tot_service_amt,
                    rvu.dart_create_dttm
                FROM
                    dartedm.f_mthly_prov_service_rvu rvu
                    JOIN dartedm.d_prov prov ON rvu.prov_dim_seq = prov.prov_dim_seq
            ) a11
            LEFT OUTER JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a14 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a14.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a14.clin_dept_abbrev
                        END
                    )
                AND
                    a12.epic_prov_id = a14.epic_prov_id
            )
            LEFT OUTER JOIN dartedm.d_proc a15 ON (
                a11.proc_dim_seq = a15.proc_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_calendar a16 ON (
                a11.beg_mth_dim_seq = a16.calendar_dim_seq
            )
        WHERE
            (
                    a15.proc_nm NOT LIKE 'HCTC%'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT LIKE '%H'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT IN (
                        '13158','21046','21086','2160000006','2164000369','2200000773','2200000774','2200000775','2200000776','2200001041','246035','6271084'
,'6271134','6271175','6490015','6490023','6521116','6521181','8160','8193','8421','8480','8647','8789','9015','9056P'
                    )
                AND
                    a12.prov_type_descr IN (
                        'PHYSICIAN'
                    )
                AND
                    (
                        CASE
                            WHEN a15.proc_cd = '372288' THEN '99203'
                            WHEN a15.proc_cd = '372292' THEN '99204'
                            WHEN a15.proc_cd = '372298' THEN '99205'
                            WHEN a15.proc_cd = '372304' THEN '99211'
                            WHEN a15.proc_cd = '372322' THEN '99213'
                            WHEN a15.proc_cd = '372332' THEN '99214'
                            WHEN a15.proc_cd = '372350' THEN '99215'
                            ELSE a15.cpt_cd
                        END
                    ) IN (
                        '11042','11100','11101','11200','17000','17003','20610','31231','31505','31575','32421','36600','38204','38205','38207','38208','38209'
,'38214','38220','38221','38240','38241','38242','41100','49082','61020','61070','62270','62311','88108','88142','88172','88173',
'88302','88304','88305','88311','88312','88313','88321','88323','88342','88346','88348','88365','88368','88381','95180','96040','96450'
,'96542','99354','99355','99201','99202','99203','99204','99205','99211','99212','99213','99214','99215','99217','99218','99219',
'99220','99221','99222','99223','99224','99225','99226','99231','99232','99233','99234','99235','99236','99238','99239','99241','99242'
,'99243','99244','99245','99251','99252','99253','99254','99255','99281','99282','99283','99284','99285','99288','99291','99292',
'99304','99305','99306','99307','99308','99309','99310','99315','99316','99318','99324','99325','99326','99327','99334','99335','99336'
,'99337','99341','99342','99343','99344','99345','99347','99348','99349','99347','99348','99349','99350','99354','99355','99356',
'99357','G0364'
                    )
                AND (
                        a12.int_ext_ind IN (
                            'I'
                        )
                    OR
                        a12.epic_prov_id IN (
                            '6625','6198'
                        )
                ) AND
                    (
                        CASE
                            WHEN a14.disease_grp_abbrev IN (
                                'PALLIATIVE CARE','PSYCH-SOC','PEDI PALLIATIVE','ADULT PALLIATIVE CARE'
                            ) THEN 'POPC'
                            WHEN a14.disease_grp_abbrev IN (
                                'PEDI','SURGERY-PEDI'
                            ) THEN 'PEDI'
                            ELSE 'ADULT'
                        END
                    ) IN (
                        'ADULT'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a16.academic_yr = (
                        SELECT
                            academic_yr - 1
                        FROM
                            dartedm.d_calendar
                        WHERE
                            calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
                    )
                AND
                    (
                        CASE
                            WHEN a11.inpat_outpat_ind = 'O' THEN 'OUTPATIENT'
                            WHEN a11.inpat_outpat_ind = 'I' THEN 'INPATIENT'
                            ELSE ''
                        END
                    ) IN (
                        'INPATIENT'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ),
            a12.epic_prov_id,
            a12.epic_prov_id,
            a12.prov_nm
    ) pa11
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ) site_nm,
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            a12.prov_nm prov_nm,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentyearinpatientrvu
        FROM
            (
                SELECT
                    rvu.prov_dim_seq,
                    rvu.proc_dim_seq,
                    beg_mth_dim_seq,
                    clin_dept_dim_seq,
                    inpat_outpat_ind,
                    (
                        CASE
                            WHEN prov.prov_type_descr = 'PHYSICIAN' THEN -1
                            ELSE super_prov_dim_seq
                        END
                    ) super_prov_dim_seq,
                    tot_service_qty,
                    tot_work_rvu_amt,
                    tot_service_amt,
                    rvu.dart_create_dttm
                FROM
                    dartedm.f_mthly_prov_service_rvu rvu
                    JOIN dartedm.d_prov prov ON rvu.prov_dim_seq = prov.prov_dim_seq
            ) a11
            LEFT OUTER JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a14 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a14.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a14.clin_dept_abbrev
                        END
                    )
                AND
                    a12.epic_prov_id = a14.epic_prov_id
            )
            LEFT OUTER JOIN dartedm.d_proc a15 ON (
                a11.proc_dim_seq = a15.proc_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_calendar a16 ON (
                a11.beg_mth_dim_seq = a16.calendar_dim_seq
            )
        WHERE
            (
                    a15.proc_nm NOT LIKE 'HCTC%'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT LIKE '%H'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT IN (
                        '13158','21046','21086','2160000006','2164000369','2200000773','2200000774','2200000775','2200000776','2200001041','246035','6271084'
,'6271134','6271175','6490015','6490023','6521116','6521181','8160','8193','8421','8480','8647','8789','9015','9056P'
                    )
                AND
                    a12.prov_type_descr IN (
                        'PHYSICIAN'
                    )
                AND
                    (
                        CASE
                            WHEN a15.proc_cd = '372288' THEN '99203'
                            WHEN a15.proc_cd = '372292' THEN '99204'
                            WHEN a15.proc_cd = '372298' THEN '99205'
                            WHEN a15.proc_cd = '372304' THEN '99211'
                            WHEN a15.proc_cd = '372322' THEN '99213'
                            WHEN a15.proc_cd = '372332' THEN '99214'
                            WHEN a15.proc_cd = '372350' THEN '99215'
                            ELSE a15.cpt_cd
                        END
                    ) IN (
                        '11042','11100','11101','11200','17000','17003','20610','31231','31505','31575','32421','36600','38204','38205','38207','38208','38209'
,'38214','38220','38221','38240','38241','38242','41100','49082','61020','61070','62270','62311','88108','88142','88172','88173',
'88302','88304','88305','88311','88312','88313','88321','88323','88342','88346','88348','88365','88368','88381','95180','96040','96450'
,'96542','99354','99355','99201','99202','99203','99204','99205','99211','99212','99213','99214','99215','99217','99218','99219',
'99220','99221','99222','99223','99224','99225','99226','99231','99232','99233','99234','99235','99236','99238','99239','99241','99242'
,'99243','99244','99245','99251','99252','99253','99254','99255','99281','99282','99283','99284','99285','99288','99291','99292',
'99304','99305','99306','99307','99308','99309','99310','99315','99316','99318','99324','99325','99326','99327','99334','99335','99336'
,'99337','99341','99342','99343','99344','99345','99347','99348','99349','99347','99348','99349','99350','99354','99355','99356',
'99357','G0364'
                    )
                AND (
                        a12.int_ext_ind IN (
                            'I'
                        )
                    OR
                        a12.epic_prov_id IN (
                            '6625','6198'
                        )
                ) AND
                    (
                        CASE
                            WHEN a14.disease_grp_abbrev IN (
                                'PALLIATIVE CARE','PSYCH-SOC','PEDI PALLIATIVE','ADULT PALLIATIVE CARE'
                            ) THEN 'POPC'
                            WHEN a14.disease_grp_abbrev IN (
                                'PEDI','SURGERY-PEDI'
                            ) THEN 'PEDI'
                            ELSE 'ADULT'
                        END
                    ) IN (
                        'ADULT'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a16.calendar_dt BETWEEN (
                        SELECT
                            MIN(calendar_dt)
                        FROM
                            dartedm.d_calendar
                        WHERE
                            academic_yr = (
                                SELECT
                                    academic_yr
                                FROM
                                    dartedm.d_calendar
                                WHERE
                                    calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
                            )
                    ) AND TO_DATE('30-06-2017','dd-mm-yyyy')
                AND
                    (
                        CASE
                            WHEN a11.inpat_outpat_ind = 'O' THEN 'OUTPATIENT'
                            WHEN a11.inpat_outpat_ind = 'I' THEN 'INPATIENT'
                            ELSE ''
                        END
                    ) IN (
                        'INPATIENT'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ),
            a12.epic_prov_id,
            a12.epic_prov_id,
            a12.prov_nm
    ) pa12 ON (
            pa11.clin_dept_grp1 = pa12.clin_dept_grp1
        AND
            pa11.prov_id = pa12.prov_id
        AND
            pa11.site_nm = pa12.site_nm
    )
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ) site_nm,
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            a12.prov_nm prov_nm,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) previousyearoutpatientrvu
        FROM
            (
                SELECT
                    rvu.prov_dim_seq,
                    rvu.proc_dim_seq,
                    beg_mth_dim_seq,
                    inst_dim_seq,
                    clin_dept_dim_seq,
                    inpat_outpat_ind,
                    (
                        CASE
                            WHEN prov.prov_type_descr = 'PHYSICIAN' THEN -1
                            ELSE super_prov_dim_seq
                        END
                    ) super_prov_dim_seq,
                    tot_service_qty,
                    tot_work_rvu_amt,
                    tot_service_amt,
                    rvu.dart_create_dttm
                FROM
                    dartedm.f_mthly_prov_service_rvu rvu
                    JOIN dartedm.d_prov prov ON rvu.prov_dim_seq = prov.prov_dim_seq
            ) a11
            LEFT OUTER JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a14 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a14.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a14.clin_dept_abbrev
                        END
                    )
                AND
                    a12.epic_prov_id = a14.epic_prov_id
            )
            LEFT OUTER JOIN dartedm.d_proc a15 ON (
                a11.proc_dim_seq = a15.proc_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_calendar a16 ON (
                a11.beg_mth_dim_seq = a16.calendar_dim_seq
            )
        WHERE
            (
                    a15.proc_nm NOT LIKE 'HCTC%'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT LIKE '%H'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT IN (
                        '13158','21046','21086','2160000006','2164000369','2200000773','2200000774','2200000775','2200000776','2200001041','246035','6271084'
,'6271134','6271175','6490015','6490023','6521116','6521181','8160','8193','8421','8480','8647','8789','9015','9056P'
                    )
                AND
                    a12.prov_type_descr IN (
                        'PHYSICIAN'
                    )
                AND
                    (
                        CASE
                            WHEN a15.proc_cd = '372288' THEN '99203'
                            WHEN a15.proc_cd = '372292' THEN '99204'
                            WHEN a15.proc_cd = '372298' THEN '99205'
                            WHEN a15.proc_cd = '372304' THEN '99211'
                            WHEN a15.proc_cd = '372322' THEN '99213'
                            WHEN a15.proc_cd = '372332' THEN '99214'
                            WHEN a15.proc_cd = '372350' THEN '99215'
                            ELSE a15.cpt_cd
                        END
                    ) IN (
                        '11042','11100','11101','11200','17000','17003','20610','31231','31505','31575','32421','36600','38204','38205','38207','38208','38209'
,'38214','38220','38221','38240','38241','38242','41100','49082','61020','61070','62270','62311','88108','88142','88172','88173',
'88302','88304','88305','88311','88312','88313','88321','88323','88342','88346','88348','88365','88368','88381','95180','96040','96450'
,'96542','99354','99355','99201','99202','99203','99204','99205','99211','99212','99213','99214','99215','99217','99218','99219',
'99220','99221','99222','99223','99224','99225','99226','99231','99232','99233','99234','99235','99236','99238','99239','99241','99242'
,'99243','99244','99245','99251','99252','99253','99254','99255','99281','99282','99283','99284','99285','99288','99291','99292',
'99304','99305','99306','99307','99308','99309','99310','99315','99316','99318','99324','99325','99326','99327','99334','99335','99336'
,'99337','99341','99342','99343','99344','99345','99347','99348','99349','99347','99348','99349','99350','99354','99355','99356',
'99357','G0364'
                    )
                AND (
                        a12.int_ext_ind IN (
                            'I'
                        )
                    OR
                        a12.epic_prov_id IN (
                            '6625','6198'
                        )
                ) AND
                    (
                        CASE
                            WHEN a14.disease_grp_abbrev IN (
                                'PALLIATIVE CARE','PSYCH-SOC','PEDI PALLIATIVE','ADULT PALLIATIVE CARE'
                            ) THEN 'POPC'
                            WHEN a14.disease_grp_abbrev IN (
                                'PEDI','SURGERY-PEDI'
                            ) THEN 'PEDI'
                            ELSE 'ADULT'
                        END
                    ) IN (
                        'ADULT'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a16.academic_yr = (
                        SELECT
                            academic_yr - 1
                        FROM
                            dartedm.d_calendar
                        WHERE
                            calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
                    )
                AND
                    (
                        CASE
                            WHEN a11.inpat_outpat_ind = 'O' THEN 'OUTPATIENT'
                            WHEN a11.inpat_outpat_ind = 'I' THEN 'INPATIENT'
                            ELSE ''
                        END
                    ) IN (
                        'OUTPATIENT'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ),
            a12.epic_prov_id,
            a12.epic_prov_id,
            a12.prov_nm
    ) pa13 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1
            ) = pa13.clin_dept_grp1
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id
            ) = pa13.prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm
            ) = pa13.site_nm
    )
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ) site_nm,
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            a12.prov_nm prov_nm,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentyearoutpatientrvu
        FROM
            (
                SELECT
                    rvu.prov_dim_seq,
                    rvu.proc_dim_seq,
                    beg_mth_dim_seq,
                    inst_dim_seq,
                    clin_dept_dim_seq,
                    inpat_outpat_ind,
                    (
                        CASE
                            WHEN prov.prov_type_descr = 'PHYSICIAN' THEN -1
                            ELSE super_prov_dim_seq
                        END
                    ) super_prov_dim_seq,
                    tot_service_qty,
                    tot_work_rvu_amt,
                    tot_service_amt,
                    rvu.dart_create_dttm
                FROM
                    dartedm.f_mthly_prov_service_rvu rvu
                    JOIN dartedm.d_prov prov ON rvu.prov_dim_seq = prov.prov_dim_seq
            ) a11
            LEFT OUTER JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a14 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a14.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a14.clin_dept_abbrev
                        END
                    )
                AND
                    a12.epic_prov_id = a14.epic_prov_id
            )
            LEFT OUTER JOIN dartedm.d_proc a15 ON (
                a11.proc_dim_seq = a15.proc_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_calendar a16 ON (
                a11.beg_mth_dim_seq = a16.calendar_dim_seq
            )
        WHERE
            (
                    a15.proc_nm NOT LIKE 'HCTC%'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT LIKE '%H'
                AND
                    (
                        CASE
                            WHEN a15.proc_cd IS NULL THEN 'N/A'
                            ELSE a15.proc_cd
                        END
                    ) NOT IN (
                        '13158','21046','21086','2160000006','2164000369','2200000773','2200000774','2200000775','2200000776','2200001041','246035','6271084'
,'6271134','6271175','6490015','6490023','6521116','6521181','8160','8193','8421','8480','8647','8789','9015','9056P'
                    )
                AND
                    a12.prov_type_descr IN (
                        'PHYSICIAN'
                    )
                AND
                    (
                        CASE
                            WHEN a15.proc_cd = '372288' THEN '99203'
                            WHEN a15.proc_cd = '372292' THEN '99204'
                            WHEN a15.proc_cd = '372298' THEN '99205'
                            WHEN a15.proc_cd = '372304' THEN '99211'
                            WHEN a15.proc_cd = '372322' THEN '99213'
                            WHEN a15.proc_cd = '372332' THEN '99214'
                            WHEN a15.proc_cd = '372350' THEN '99215'
                            ELSE a15.cpt_cd
                        END
                    ) IN (
                        '11042','11100','11101','11200','17000','17003','20610','31231','31505','31575','32421','36600','38204','38205','38207','38208','38209'
,'38214','38220','38221','38240','38241','38242','41100','49082','61020','61070','62270','62311','88108','88142','88172','88173',
'88302','88304','88305','88311','88312','88313','88321','88323','88342','88346','88348','88365','88368','88381','95180','96040','96450'
,'96542','99354','99355','99201','99202','99203','99204','99205','99211','99212','99213','99214','99215','99217','99218','99219',
'99220','99221','99222','99223','99224','99225','99226','99231','99232','99233','99234','99235','99236','99238','99239','99241','99242'
,'99243','99244','99245','99251','99252','99253','99254','99255','99281','99282','99283','99284','99285','99288','99291','99292',
'99304','99305','99306','99307','99308','99309','99310','99315','99316','99318','99324','99325','99326','99327','99334','99335','99336'
,'99337','99341','99342','99343','99344','99345','99347','99348','99349','99347','99348','99349','99350','99354','99355','99356',
'99357','G0364'
                    )
                AND (
                        a12.int_ext_ind IN (
                            'I'
                        )
                    OR
                        a12.epic_prov_id IN (
                            '6625','6198'
                        )
                ) AND
                    (
                        CASE
                            WHEN a14.disease_grp_abbrev IN (
                                'PALLIATIVE CARE','PSYCH-SOC','PEDI PALLIATIVE','ADULT PALLIATIVE CARE'
                            ) THEN 'POPC'
                            WHEN a14.disease_grp_abbrev IN (
                                'PEDI','SURGERY-PEDI'
                            ) THEN 'PEDI'
                            ELSE 'ADULT'
                        END
                    ) IN (
                        'ADULT'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a16.calendar_dt BETWEEN (
                        SELECT
                            MIN(calendar_dt)
                        FROM
                            dartedm.d_calendar
                        WHERE
                            academic_yr = (
                                SELECT
                                    academic_yr
                                FROM
                                    dartedm.d_calendar
                                WHERE
                                    calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
                            )
                    ) AND TO_DATE('30-06-2017','dd-mm-yyyy')
                AND
                    (
                        CASE
                            WHEN a11.inpat_outpat_ind = 'O' THEN 'OUTPATIENT'
                            WHEN a11.inpat_outpat_ind = 'I' THEN 'INPATIENT'
                            ELSE ''
                        END
                    ) IN (
                        'OUTPATIENT'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.disease_grp_abbrev)
                END
            ),
            a12.epic_prov_id,
            a12.epic_prov_id,
            a12.prov_nm
    ) pa14 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1
            ) = pa14.clin_dept_grp1
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id
            ) = pa14.prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm,
                pa13.site_nm
            ) = pa14.site_nm
    )
    CROSS JOIN (
        SELECT
            MAX(a11.academic_period) currentyearacademicperiod
        FROM
            dartedm.d_calendar a11
        WHERE
            a11.academic_period = (
                SELECT
                    academic_period
                FROM
                    dartedm.d_calendar
                WHERE
                    calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
            )
    ) pa15
    LEFT OUTER JOIN (
        SELECT
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            a12.prov_nm prov_nm,
            SUM( (a11.effort_pct / 100) ) proveffortprov
        FROM
            (
                SELECT
                    prov_dim_seq,
                    empl_nm,
                    prov_nm,
                    empl_id,
                    epic_prov_id,
                    prov_status,
                    prov_type_descr,
                    academic_yr,
                    prov_prim_disease_grp,
                    xref.disease_grp_descr prov_alloc_disease_grp,
                    eff.fn_dept_id,
                    fn_dept_nm,
                    weekly_hours,
                    daily_effort_pct_sum,
                    daily_distrib_pct_sum,
                    days_in_year,
                    effort_pct,
                    distrib_pct
                FROM
                    dartedm.mv_rvu_prov_effort eff
                    JOIN microstrat.ds_fn_dept_disease_grp_xref xref ON eff.fn_dept_id = xref.fn_dept_id
            ) a11
            LEFT OUTER JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
        WHERE
            a11.academic_yr = (
                SELECT
                    academic_yr
                FROM
                    dartedm.d_calendar
                WHERE
                    calendar_dt = TO_DATE('30-06-2017','dd-mm-yyyy')
            )
        GROUP BY
            a12.epic_prov_id,
            a12.epic_prov_id,
            a12.prov_nm
    ) pa16 ON (
        coalesce(
            pa11.prov_id,
            pa12.prov_id,
            pa13.prov_id,
            pa14.prov_id
        ) = pa16.prov_id
    )
    LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1
            ) = (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            )
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id
            ) = a17.epic_prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm,
                pa13.site_nm,
                pa14.site_nm
            ) = (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            )
    );