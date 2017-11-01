SELECT DISTINCT
    (
        CASE
            WHEN TRIM(a18.mo_division_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a18.mo_division_nm)
        END
    ) mo_division_nm,
    coalesce(
        pa11.site_nm,
        pa12.site_nm,
        pa13.site_nm,
        pa14.site_nm
    ) site_nm,
    coalesce(
        pa11.clin_dept_grp1,
        pa12.clin_dept_grp1,
        pa13.clin_dept_grp1,
        pa14.clin_dept_grp1
    ) clin_dept_grp1,
    coalesce(
        pa11.prov_id0,
        pa12.prov_id0,
        pa13.prov_id0,
        pa14.prov_id0
    ) prov_id,
    a19.prov_nm prov_nm,
    coalesce(
        pa11.prov_id,
        pa12.prov_id,
        pa13.prov_id,
        pa14.prov_id
    ) prov_id0,
    coalesce(
        pa11.prov_type_cd,
        pa12.prov_type_cd,
        pa13.prov_type_cd,
        pa14.prov_type_cd
    ) prov_type_cd,
    pa11.previousyearinpatientrvu previousyearinpatientrvu,
    nvl(
        (
            CASE
                WHEN pa15.currentyearacademicperiod <> 12.0 THEN pa11.previousyearinpatientrvu
                ELSE pa12.currentyearinpatientrvu
            END
        ),
        0
    ) currentyearinpatientrvuannuali,
    pa13.previousyearoutpatientrvu previousyearoutpatientrvu,
    nvl(
        ( (pa14.currentyearoutpatientrvu / (
            CASE
                WHEN pa15.currentyearacademicperiod = 0   THEN NULL
                ELSE pa15.currentyearacademicperiod
            END
        ) ) * 12.0),
        0
    ) currentyearoutpatientrvuannual,
    ( nvl(pa11.previousyearinpatientrvu,0) + nvl(pa13.previousyearoutpatientrvu,0) ) previousyeartotalrvu,
    ( nvl(
        ( (pa14.currentyearoutpatientrvu / (
            CASE
                WHEN pa15.currentyearacademicperiod = 0   THEN NULL
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
    (
        CASE
            WHEN pa16.maxprovtype = 'PHYSICIAN' THEN pa17.proveffort
            ELSE 0
        END
    ) adjustedproveffortnppa0,
    nvl(
        ( (nvl(
            ( (pa14.currentyearoutpatientrvu / (
                CASE
                    WHEN pa15.currentyearacademicperiod = 0   THEN NULL
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
        ) ) / (
            CASE
                WHEN(
                    CASE
                        WHEN pa16.maxprovtype = 'PHYSICIAN' THEN pa17.proveffort
                        ELSE 1
                    END
                ) = 0 THEN NULL
                ELSE(
                    CASE
                        WHEN pa16.maxprovtype = 'PHYSICIAN' THEN pa17.proveffort
                        ELSE 1
                    END
                )
            END
        ) ),
        0
    ) provaytdrvusperstdftesitervu
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
            a12.epic_prov_id prov_id0,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) previousyearinpatientrvu
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
            JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            JOIN dartedm.mv_rvu_report_category a14 ON (
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
            JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
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
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a15.academic_yr = (
                        SELECT
                            academic_yr - 1
                        FROM
                            dartedm.d_calendar
                        WHERE
                            calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id
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
            a12.epic_prov_id prov_id0,
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
            JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            JOIN dartedm.mv_rvu_report_category a14 ON (
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
            JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
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
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id
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
            a12.epic_prov_id prov_id0,
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
            JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            JOIN dartedm.mv_rvu_report_category a14 ON (
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
            JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
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
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
                AND
                    a15.academic_yr = (
                        SELECT
                            academic_yr - 1
                        FROM
                            dartedm.d_calendar
                        WHERE
                            calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id
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
            a12.epic_prov_id prov_id0,
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
            JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            JOIN dartedm.mv_rvu_report_category a14 ON (
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
            JOIN dartedm.d_calendar a15 ON (
                a11.beg_mth_dim_seq = a15.calendar_dim_seq
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
                    (
                        CASE
                            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a14.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id
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
                    calendar_dt = TO_DATE('31-07-2017','dd-mm-yyyy')
            )
    ) pa15
    LEFT OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN TRIM(a12.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a12.site_nm)
                END
            ) site_nm,
            (
                CASE
                    WHEN TRIM(a12.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a12.disease_grp_abbrev)
                END
            ) clin_dept_grp1,
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
            MAX(a11.prov_type_descr) maxprovtype
        FROM
            dartedm.d_prov a11
            JOIN dartedm.mv_rvu_report_category a12 ON (
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
                AND
                    (
                        CASE
                            WHEN TRIM(a12.mo_division_nm) IS NULL THEN 'N/A'
                            ELSE TRIM(a12.mo_division_nm)
                        END
                    ) NOT IN (
                        'N/A','POPC'
                    )
            )
        GROUP BY
            (
                CASE
                    WHEN TRIM(a12.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a12.site_nm)
                END
            ),
            (
                CASE
                    WHEN TRIM(a12.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a12.disease_grp_abbrev)
                END
            ),
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
            a11.epic_prov_id
    ) pa16 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1
            ) = pa16.clin_dept_grp1
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id
            ) = pa16.prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm,
                pa13.site_nm,
                pa14.site_nm
            ) = pa16.site_nm
    )
    LEFT OUTER JOIN (
        SELECT
            (
                CASE
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-LNH' THEN 'LONDONDERRY'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-MH'  THEN 'MILFORD'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SS'  THEN 'SOUTH SHORE'
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SE'   THEN 'ST ELIZABETHS'
                    ELSE 'LONGWOOD'
                END
            ) site_nm,
            a11.prov_alloc_disease_grp clin_dept_grp1,
            a12.epic_prov_id prov_id,
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
            a12.epic_prov_id prov_id0,
            SUM( (a11.effort_pct / 100) ) proveffort
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
            JOIN dartedm.d_prov a12 ON (
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
                    WHEN a11.prov_alloc_disease_grp = 'MED ONC-SE'   THEN 'ST ELIZABETHS'
                    ELSE 'LONGWOOD'
                END
            ),
            a11.prov_alloc_disease_grp,
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
            a12.epic_prov_id
    ) pa17 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1
            ) = pa17.clin_dept_grp1
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id
            ) = pa17.prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm,
                pa13.site_nm,
                pa14.site_nm
            ) = pa17.site_nm
    )
    JOIN dartedm.mv_rvu_report_category a18 ON (
            coalesce(
                pa11.clin_dept_grp1,
                pa12.clin_dept_grp1,
                pa13.clin_dept_grp1,
                pa14.clin_dept_grp1
            ) = (
                CASE
                    WHEN TRIM(a18.disease_grp_abbrev) IS NULL THEN 'N/A'
                    ELSE TRIM(a18.disease_grp_abbrev)
                END
            )
        AND
            coalesce(
                pa11.prov_id,
                pa12.prov_id,
                pa13.prov_id,
                pa14.prov_id
            ) = a18.epic_prov_id
        AND
            coalesce(
                pa11.site_nm,
                pa12.site_nm,
                pa13.site_nm,
                pa14.site_nm
            ) = (
                CASE
                    WHEN TRIM(a18.site_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a18.site_nm)
                END
            )
    )
    JOIN dartedm.d_prov a19 ON ( coalesce(
        pa11.prov_id0,
        pa12.prov_id0,
        pa13.prov_id0,
        pa14.prov_id0
    ) ) = a19.epic_prov_id;