SELECT DISTINCT
    coalesce(
        pa11.disease_grp_fn_dept_descr,
        pa12.disease_grp_fn_dept_descr,
        pa13.disease_grp_fn_dept_descr,
        pa14.disease_grp_fn_dept_descr
    ) disease_grp_fn_dept_descr,
    coalesce(
        pa11.disease_subgrp_descr,
        pa12.disease_subgrp_descr,
        pa13.disease_subgrp_descr,
        pa14.disease_subgrp_descr
    ) disease_subgrp_descr,
    coalesce(
        pa11.prov_id,
        pa12.prov_id,
        pa13.prov_id,
        pa14.prov_id
    ) prov_id,
    coalesce(
        pa11.prov_id0,
        pa12.prov_id0,
        pa13.prov_id0,
        pa14.prov_id0
    ) prov_id0,
    a15.prov_nm prov_nm,
    coalesce(
        pa11.prov_type_cd,
        pa12.prov_type_cd,
        pa13.prov_type_cd,
        pa14.prov_type_cd
    ) prov_type_cd,
    coalesce(
        pa11.prov_type_cd0,
        pa12.prov_type_cd0,
        pa13.prov_type_cd0,
        pa14.prov_type_cd0
    ) prov_type_cd0,
    pa11.currentmonthinpatientrvu currentmonthinpatientrvu,
    pa12.currentmonthoutpatientrvu currentmonthoutpatientrvu,
    ( nvl(pa11.currentmonthinpatientrvu,0) + nvl(pa12.currentmonthoutpatientrvu,0) ) currentmonthtotalrvu,
    pa13.currentyearinpatientrvu currentyearinpatientrvu,
    pa14.currentyearoutpatientrvu currentyearoutpatientrvu,
    ( nvl(pa13.currentyearinpatientrvu,0) + nvl(pa14.currentyearoutpatientrvu,0) ) currentyeartotalrvu
FROM
    (
        SELECT
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
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'PSYCHOLOGIST'
                    ) THEN 'PSYC'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd0,
            a12.epic_prov_id prov_id0,
            a12.disease_grp_descr disease_grp_fn_dept_descr,
            a12.disease_subgrp_descr disease_subgrp_descr,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentmonthinpatientrvu
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
            LEFT JOIN dartedm.d_prov a12 ON (
                a11.prov_dim_seq = a12.prov_dim_seq
            )
            LEFT JOIN dartedm.d_clin_dept a13 ON (
                a11.clin_dept_dim_seq = a13.clin_dept_dim_seq
            )
            LEFT JOIN dartedm.mv_rvu_report_category a14 ON (
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
            LEFT JOIN dartedm.d_calendar a15 ON (
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
                    a15.calendar_dt BETWEEN (
                        SELECT
                            MIN(calendar_dt)
                        FROM
                            dartedm.d_calendar
                        WHERE
                                month_nbr = (
                                    SELECT
                                        month_nbr
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'PSYCHOLOGIST'
                ) THEN 'PSYC'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.disease_grp_descr,
            a12.disease_subgrp_descr
    ) pa11
    FULL OUTER JOIN (
        SELECT
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
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'PSYCHOLOGIST'
                    ) THEN 'PSYC'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd0,
            a12.epic_prov_id prov_id0,
            a12.disease_grp_descr disease_grp_fn_dept_descr,
            a12.disease_subgrp_descr disease_subgrp_descr,
            SUM(nvl(a11.tot_work_rvu_amt,0) ) currentmonthoutpatientrvu
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
                                month_nbr = (
                                    SELECT
                                        month_nbr
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'PSYCHOLOGIST'
                ) THEN 'PSYC'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.disease_grp_descr,
            a12.disease_subgrp_descr
    ) pa12 ON (
        pa11.prov_id = pa12.prov_id
    )
    FULL OUTER JOIN (
        SELECT
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
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'PSYCHOLOGIST'
                    ) THEN 'PSYC'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd0,
            a12.epic_prov_id prov_id0,
            a12.disease_grp_descr disease_grp_fn_dept_descr,
            a12.disease_subgrp_descr disease_subgrp_descr,
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'PSYCHOLOGIST'
                ) THEN 'PSYC'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.disease_grp_descr,
            a12.disease_subgrp_descr
    ) pa13 ON (
        coalesce(
            pa11.prov_id,
            pa12.prov_id
        ) = pa13.prov_id
    )
    FULL OUTER JOIN (
        SELECT
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
                CASE
                    WHEN a12.prov_type_descr IN (
                        'PHYSICIAN'
                    ) THEN 'MD'
                    WHEN a12.prov_type_descr IN (
                        'PSYCHOLOGIST'
                    ) THEN 'PSYC'
                    WHEN a12.prov_type_descr IN (
                        'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                    ) THEN 'NP/PA'
                    ELSE 'N/A'
                END
            prov_type_cd0,
            a12.epic_prov_id prov_id0,
            a12.disease_grp_descr disease_grp_fn_dept_descr,
            a12.disease_subgrp_descr disease_subgrp_descr,
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
            CASE
                WHEN a12.prov_type_descr IN (
                    'PHYSICIAN'
                ) THEN 'MD'
                WHEN a12.prov_type_descr IN (
                    'PSYCHOLOGIST'
                ) THEN 'PSYC'
                WHEN a12.prov_type_descr IN (
                    'NURSE PRACTITIONER','PHYSICIAN ASSISTANT'
                ) THEN 'NP/PA'
                ELSE 'N/A'
            END,
            a12.epic_prov_id,
            a12.disease_grp_descr,
            a12.disease_subgrp_descr
    ) pa14 ON (
        coalesce(
            pa11.prov_id,
            pa12.prov_id,
            pa13.prov_id
        ) = pa14.prov_id
    )
    LEFT JOIN dartedm.d_prov a15 ON (
        coalesce(
            pa11.prov_id,
            pa12.prov_id,
            pa13.prov_id,
            pa14.prov_id
        ) = a15.epic_prov_id
    );