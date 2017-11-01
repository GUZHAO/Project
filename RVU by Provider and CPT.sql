DEFINE startdate=TO_DATE('30-09-2016','dd-mm-yyyy');
DEFINE enddate=TO_DATE('31-07-2017','dd-mm-yyyy');

SELECT
    a16.month_nbr,
    upper(substr(
        a16.mth_nm,
        1,
        3
    ) ) month_ltr,
    a12.epic_prov_id prov_id,
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
    ) cpt_cd,
    a17.cpt_cd_descr cpt_descr,
    a15.proc_nm service_descr,
    a16.academic_period,
    a16.calendar_yr,
        CASE
            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a14.mo_division_nm)
        END
    mo_division_nm,
        CASE
            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
            ELSE TRIM(a14.disease_grp_abbrev)
        END
    clin_dept_grp1,
        CASE
            WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a14.site_nm)
        END
    site_nm,
    a12.disease_grp_descr disease_grp_fn_dept_descr,
    a12.prov_nm prov_nm,
    SUM(nvl(a11.tot_work_rvu_amt,0)) monthlyrvu,
    SUM(a11.tot_service_qty) mtdquantity
FROM
    (
        SELECT
            rvu.prov_dim_seq,
            rvu.proc_dim_seq,
            rvu.beg_mth_dim_seq,
            rvu.clin_dept_dim_seq,
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
    LEFT JOIN dartedm.d_proc a15 ON (
        a11.proc_dim_seq = a15.proc_dim_seq
    )
    LEFT JOIN dartedm.d_calendar a16 ON (
        a11.beg_mth_dim_seq = a16.calendar_dim_seq
    )
    LEFT JOIN dartedm.d_cpt_cd a17 ON (
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
        ) = (
            CASE
                WHEN a17.cpt_cd IS NULL THEN 'N/A'
                ELSE a17.cpt_cd
            END
        )
    )
WHERE
    (
            (
                CASE
                    WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
                    ELSE TRIM(a14.mo_division_nm)
                END
            ) NOT IN (
                'N/A'
            )
        AND
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
            a16.calendar_dt BETWEEN &startdate AND &enddate
    )
GROUP BY
    a16.month_nbr,
    upper(substr(
        a16.mth_nm,
        1,
        3
    ) ),
    a12.epic_prov_id,
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
    ),
    a17.cpt_cd_descr,
    a15.proc_nm,
    a16.academic_period,
    a16.calendar_yr,
    (
        CASE
            WHEN TRIM(a14.mo_division_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a14.mo_division_nm)
        END
    ),
    (
        CASE
            WHEN TRIM(a14.disease_grp_abbrev) IS NULL THEN 'N/A'
            ELSE TRIM(a14.disease_grp_abbrev)
        END
    ),
    (
        CASE
            WHEN TRIM(a14.site_nm) IS NULL THEN 'N/A'
            ELSE TRIM(a14.site_nm)
        END
    ),
    a12.disease_grp_descr,
    a12.epic_prov_id,
    a12.prov_nm
ORDER BY
    a16.calendar_yr,
    a16.month_nbr,
    a12.epic_prov_id;