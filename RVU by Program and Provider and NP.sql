SELECT DISTINCT
    coalesce(
        pa11.prov_id2,
        pa12.prov_id2,
        pa13.prov_id2,
        pa14.prov_id2,
        pa15.prov_id2
    ) prov_id,
    a18.prov_nm prov_nm,
    coalesce(
        pa11.prov_type_cd,
        pa12.prov_type_cd,
        pa13.prov_type_cd,
        pa14.prov_type_cd,
        pa15.prov_type_cd
    ) prov_type_cd,
    coalesce(
        pa11.prov_id1,
        pa12.prov_id1,
        pa13.prov_id1,
        pa14.prov_id1,
        pa15.prov_id1
    ) prov_id0,
    a19.prov_nm prov_nm0,
    coalesce(
        pa11.prov_type_descr,
        pa12.prov_type_descr,
        pa13.prov_type_descr,
        pa14.prov_type_descr,
        pa15.prov_type_descr
    ) prov_type_descr,
    coalesce(
        pa11.prov_id0,
        pa12.prov_id0,
        pa13.prov_id0,
        pa14.prov_id0,
        pa15.prov_id0
    ) prov_id1,
    coalesce(
        pa11.prov_id,
        pa12.prov_id,
        pa13.prov_id,
        pa14.prov_id,
        pa15.prov_id
    ) prov_id2,
    a18.epic_prov_id super_prov_id,
    coalesce(
        pa11.clin_dept_grp1,
        pa12.clin_dept_grp1,
        pa13.clin_dept_grp1,
        pa14.clin_dept_grp1,
        pa15.clin_dept_grp1
    ) clin_dept_grp1,
    coalesce(
        pa11.clin_dept_site,
        pa12.clin_dept_site,
        pa13.clin_dept_site,
        pa14.clin_dept_site,
        pa15.clin_dept_site
    ) clin_dept_site,
    pa11.currentyearinpatientrvu currentyearinpatientrvu,
    pa12.currentyearoutpatientrvu currentyearoutpatientrvu,
    ( nvl(pa11.currentyearinpatientrvu,0) + nvl(pa12.currentyearoutpatientrvu,0) ) currentyeartotalrvu,
    pa13.currentyeartotalmdrvu currentyeartotalmdrvu,
    pa14.currentquarterinpatientrvu currentquarterinpatientrvu,
    pa15.currentquarteroutpatientrvu currentquarteroutpatientrvu,
    ( nvl(pa14.currentquarterinpatientrvu,0) + nvl(pa15.currentquarteroutpatientrvu,0) ) currentquartertotalrvu,
    (
        CASE
            WHEN pa16.maxprovtype = 'PHYSICIAN' THEN pa17.supereffort
            ELSE 0
        END
    ) adjustedsupereffort
FROM
    (
        SELECT
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ) clin_dept_site,
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a16.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a12.epic_prov_id prov_id1,
            a12.prov_type_descr prov_type_descr,
            a16.epic_prov_id prov_id2,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentyearinpatientrvu
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
            LEFT OUTER JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_prov a16 ON (
                (
                    CASE
                        WHEN a11.super_prov_dim_seq =-1 THEN a11.prov_dim_seq
                        ELSE a11.super_prov_dim_seq
                    END
                ) = a16.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a17.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a17.clin_dept_abbrev
                        END
                    )
                AND
                    a16.epic_prov_id = a17.epic_prov_id
            )
        WHERE
            (
                    a12.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
                AND
                    a15.calendar_dt BETWEEN (
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
                                    calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                            )
                    ) AND TO_DATE('31-07-2017','dd-mm-yyyy')
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
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ),
            a16.epic_prov_id,
            a12.epic_prov_id,
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.prov_type_descr,
            a16.epic_prov_id
    ) pa11
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ) clin_dept_site,
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a16.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a12.epic_prov_id prov_id1,
            a12.prov_type_descr prov_type_descr,
            a16.epic_prov_id prov_id2,
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
            LEFT OUTER JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_prov a16 ON (
                (
                    CASE
                        WHEN a11.super_prov_dim_seq =-1 THEN a11.prov_dim_seq
                        ELSE a11.super_prov_dim_seq
                    END
                ) = a16.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a17.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a17.clin_dept_abbrev
                        END
                    )
                AND
                    a16.epic_prov_id = a17.epic_prov_id
            )
        WHERE
            (
                    a12.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
                AND
                    a15.calendar_dt BETWEEN (
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
                                    calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                            )
                    ) AND TO_DATE('31-07-2017','dd-mm-yyyy')
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
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ),
            a16.epic_prov_id,
            a12.epic_prov_id,
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.prov_type_descr,
            a16.epic_prov_id
    ) pa12 ON (
            pa11.clin_dept_grp1 = pa12.clin_dept_grp1
        AND
            pa11.clin_dept_site = pa12.clin_dept_site
        AND
            pa11.prov_id = pa12.prov_id
        AND
            pa11.prov_id0 = pa12.prov_id0
    )
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ) clin_dept_site,
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a16.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a12.epic_prov_id prov_id1,
            a12.prov_type_descr prov_type_descr,
            a16.epic_prov_id prov_id2,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentyeartotalmdrvu
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
            LEFT OUTER JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_prov a16 ON (
                (
                    CASE
                        WHEN a11.super_prov_dim_seq =-1 THEN a11.prov_dim_seq
                        ELSE a11.super_prov_dim_seq
                    END
                ) = a16.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a17.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a17.clin_dept_abbrev
                        END
                    )
                AND
                    a16.epic_prov_id = a17.epic_prov_id
            )
        WHERE
            (
                    a12.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
                AND
                    a15.calendar_dt BETWEEN (
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
                                    calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                            )
                    ) AND TO_DATE('31-07-2017','dd-mm-yyyy')
                AND
                    a12.prov_type_descr IN (
                        'PHYSICIAN'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ),
            a16.epic_prov_id,
            a12.epic_prov_id,
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.prov_type_descr,
            a16.epic_prov_id
    ) pa13 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1
            ) = pa13.clin_dept_grp1
        AND
            coalesce(
                pa11.clin_dept_site,
                pa12.clin_dept_site
            ) = pa13.clin_dept_site
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id
            ) = pa13.prov_id
        AND
            coalesce(
                pa11.prov_id0,
                pa12.prov_id0
            ) = pa13.prov_id0
    )
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ) clin_dept_site,
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a16.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a12.epic_prov_id prov_id1,
            a12.prov_type_descr prov_type_descr,
            a16.epic_prov_id prov_id2,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentquarterinpatientrvu
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
            LEFT OUTER JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_prov a16 ON (
                (
                    CASE
                        WHEN a11.super_prov_dim_seq =-1 THEN a11.prov_dim_seq
                        ELSE a11.super_prov_dim_seq
                    END
                ) = a16.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a17.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a17.clin_dept_abbrev
                        END
                    )
                AND
                    a16.epic_prov_id = a17.epic_prov_id
            )
        WHERE
            (
                    a12.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
                AND
                    a15.calendar_dt BETWEEN (
                        SELECT
                            MIN(calendar_dt)
                        FROM
                            dartedm.d_calendar
                        WHERE
                                academic_qtr = (
                                    SELECT
                                        academic_qtr
                                    FROM
                                        dartedm.d_calendar
                                    WHERE
                                        calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                                )
                            AND
                                academic_yr = (
                                    SELECT
                                        academic_yr
                                    FROM
                                        dartedm.d_calendar
                                    WHERE
                                        calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                                )
                    ) AND TO_DATE('31-07-2017','dd-mm-yyyy')
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
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ),
            a16.epic_prov_id,
            a12.epic_prov_id,
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.prov_type_descr,
            a16.epic_prov_id
    ) pa14 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1
            ) = pa14.clin_dept_grp1
        AND
            coalesce(
                pa11.clin_dept_site,
                pa12.clin_dept_site,
                pa13.clin_dept_site
            ) = pa14.clin_dept_site
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id
            ) = pa14.prov_id
        AND
            coalesce(
                pa11.prov_id0,
                pa12.prov_id0,
                pa13.prov_id0
            ) = pa14.prov_id0
    )
    FULL OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ) clin_dept_site,
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
            a16.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a12.epic_prov_id prov_id1,
            a12.prov_type_descr prov_type_descr,
            a16.epic_prov_id prov_id2,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentquarteroutpatientrvu
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
            LEFT OUTER JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
            )
            LEFT OUTER JOIN dartedm.d_prov a16 ON (
                (
                    CASE
                        WHEN a11.super_prov_dim_seq =-1 THEN a11.prov_dim_seq
                        ELSE a11.super_prov_dim_seq
                    END
                ) = a16.prov_dim_seq
            )
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a17 ON (
                    (
                        CASE
                            WHEN a13.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a13.clin_dept_abbrev
                        END
                    ) = (
                        CASE
                            WHEN a17.clin_dept_abbrev IS NULL THEN 'N/A'
                            ELSE a17.clin_dept_abbrev
                        END
                    )
                AND
                    a16.epic_prov_id = a17.epic_prov_id
            )
        WHERE
            (
                    a12.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
                AND
                    a15.calendar_dt BETWEEN (
                        SELECT
                            MIN(calendar_dt)
                        FROM
                            dartedm.d_calendar
                        WHERE
                                academic_qtr = (
                                    SELECT
                                        academic_qtr
                                    FROM
                                        dartedm.d_calendar
                                    WHERE
                                        calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                                )
                            AND
                                academic_yr = (
                                    SELECT
                                        academic_yr
                                    FROM
                                        dartedm.d_calendar
                                    WHERE
                                        calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
                                )
                    ) AND TO_DATE('31-07-2017','dd-mm-yyyy')
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
                    WHEN TRIM(a17.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a17.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a17.disease_grp_abbrev)
                END
            ),
            a16.epic_prov_id,
            a12.epic_prov_id,
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.prov_type_descr,
            a16.epic_prov_id
    ) pa15 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1
            ) = pa15.clin_dept_grp1
        AND
            coalesce(
                pa11.clin_dept_site,
                pa12.clin_dept_site,
                pa13.clin_dept_site,
                pa14.clin_dept_site
            ) = pa15.clin_dept_site
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id
            ) = pa15.prov_id
        AND
            coalesce(
                pa11.prov_id0,
                pa12.prov_id0,
                pa13.prov_id0,
                pa14.prov_id0
            ) = pa15.prov_id0
    )
    LEFT OUTER JOIN (
        SELECT
            a11.epic_prov_id prov_id,
                CASE
                    WHEN a11.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a11.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd,
            a11.epic_prov_id prov_id0,
            a11.prov_type_descr prov_type_descr,
            MAX(a11.prov_type_descr) maxprovtype
        FROM
            dartedm.d_prov a11
            LEFT OUTER JOIN dartedm.mv_rvu_report_category a12 ON (
                a11.epic_prov_id = a12.epic_prov_id
            )
        WHERE
            (
                    a11.int_ext_ind IN (
                        'E'
                    )
                AND
                    (
                        CASE
                            WHEN TRIM(a12.disease_grp_abbrev) IS NULL THEN 'N/A'
                            ELSE TRIM(a12.disease_grp_abbrev)
                        END
                    ) NOT IN (
                        'STIPEND'
                    )
            )
        GROUP BY
            a11.epic_prov_id,
            CASE
                WHEN a11.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a11.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a11.epic_prov_id,
            a11.prov_type_descr
    ) pa16 ON (
        coalesce(
            pa11.prov_id0,
            pa12.prov_id0,
            pa13.prov_id0,
            pa14.prov_id0,
            pa15.prov_id0
        ) = pa16.prov_id
    )
    LEFT OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-LNH' THEN 'LONDONDERRY'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-MH'  THEN 'MILFORD'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SS'  THEN 'SOUTH SHORE'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SE'  THEN 'ST ELIZABETHS'
                    ELSE 'LONGWOOD'
                END
            ) clin_dept_site,
            a11.prov_alloc_disease_grp clin_dept_grp1,
            a12.epic_prov_id prov_id,
            a12.epic_prov_id prov_id0,
            SUM( (a11.effort_pct / 100) ) supereffort
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
                    calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
            )
        GROUP BY
            (
                CASE
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-LNH' THEN 'LONDONDERRY'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-MH'  THEN 'MILFORD'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SS'  THEN 'SOUTH SHORE'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SE'  THEN 'ST ELIZABETHS'
                    ELSE 'LONGWOOD'
                END
            ),
            a11.prov_alloc_disease_grp,
            a12.epic_prov_id,
            a12.epic_prov_id
    ) pa17 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1,
                pa15.clin_dept_grp1
            ) = pa17.clin_dept_grp1
        AND
            coalesce(
                pa11.clin_dept_site,
                pa12.clin_dept_site,
                pa13.clin_dept_site,
                pa14.clin_dept_site,
                pa15.clin_dept_site
            ) = pa17.clin_dept_site
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id,
                pa15.prov_id
            ) = pa17.prov_id
    )
    LEFT OUTER JOIN dartedm.d_prov a18 ON (
        coalesce(
            pa11.prov_id,
            pa12.prov_id,
            pa13.prov_id,
            pa14.prov_id,
            pa15.prov_id
        ) = a18.epic_prov_id
    )
    LEFT OUTER JOIN dartedm.d_prov a19 ON (
        coalesce(
            pa11.prov_id1,
            pa12.prov_id1,
            pa13.prov_id1,
            pa14.prov_id1,
            pa15.prov_id1
        ) = a19.epic_prov_id
    );