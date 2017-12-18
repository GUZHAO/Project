SELECT DISTINCT t1.pt_id, t1.REFER_TO_SPLTY_DEPT_DESCR, t1.ENTRY_DTTM
FROM dart_ods.ods_edw_pt_refer t1
WHERE t1.ENTRY_DTTM>='01-OCT-15' and t1.REFER_TO_SPLTY_DEPT_DESCR IS NOT NULL
ORDER BY t1.pt_id, t1.ENTRY_DTTM
;

SELECT pt_id,
SUM(DECODE(ORDG_DTTM, 1, cpt)) AS stat_1,
SUM(DECODE(ORDG_DTTM, 2, cpt)) AS stat_2,
SUM(DECODE(ORDG_DTTM, 3, cpt)) AS stat_3,
SUM(DECODE(ORDG_DTTM, 4, cpt)) AS stat_4,
SUM(DECODE(ORDG_DTTM, 5, cpt)) AS stat_5
FROM (
SELECT DISTINCT t1.cpt, t1.ORDG_DTTM, t1.PT_ID
FROM dart_ods.ods_edw_ord_proc t1
WHERE t1.ORDG_DTTM>='01-OCT-15' AND CPT IN
(
'99221',
'99222',
'99223',
'99356',
'99357',
'99231',
'99232',
'99233',
'99201',
'99202',
'99203',
'99204',
'99205',
'99211',
'99212',
'99213',
'99214',
'99215',
'99354',
'99355',
'99497',
'99498'
)
ORDER BY t1.PT_ID
)
GROUP BY pt_id
ORDER BY 1;


SELECT DISTINCT t1.cpt, t1.SVC_DTTM, t1.HOSP_ACCT_ID, t1.PT_ENC_ID
FROM dart_ods.ods_edw_fin_hosp_transact t1
WHERE t1.SVC_DTTM>='01-OCT-15' AND CPT IN
(
'99221',
'99222',
'99223',
'99356',
'99357',
'99231',
'99232',
'99233',
'99201',
'99202',
'99203',
'99204',
'99205',
'99211',
'99212',
'99213',
'99214',
'99215',
'99354',
'99355',
'99497',
'99498'
)