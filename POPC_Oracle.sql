SELECT
    t1.pt_id,
    t13.PT_DFCI_MRN,
    t13.PT_BWH_MRN,
    t1.pt_enc_id,
    t1.appt_dttm AS appt_dts,
    t1.dept_descr AS department_nm,
    t1.enc_epic_prov_id AS enc_prov_id,
    t1.cont_dttm AS contact_dts,
    t14.event_dttm AS ed_event_dttm,
    t1.hosp_admit_dttm,
    t1.hosp_dischg_dttm,
    t1.hosp_admit_typ_descr AS hosp_admit_tp,
    t6.prov_nm AS enc_prov_nm,
    t2.molst_ind,--patient level
    t3.healthcareproxy_ind,--patient level
    t4.opioid_ind,
    t5.laxative_ind,
    t6.prov_dx_grp_dv AS dis_ctr_nm,
    t6.prov_dx_grp_dv AS dis_ctr_nm_ref,
    t6.prov_dx_grp_dv AS dis_ctr_nm_att,
    t7.chaplain_cnt,
    t8.socialworker_cnt,
    t9.pt_death_dt,--patient level
    t10.chemo_ind,--patient level
    t10.ordg_dttm AS chemo_ordg_dttm,--patient level
    t9.pt_birth_dt,--patient level
    t9.pt_race_1_nm,--patient level
    t9.pt_gender_nm,--patient level
    t9.pt_perm_zip_cd,--patient level
    t9.pt_age_dv,--patient level
    t13.enc_refer_prov_id,
    t13.enc_refer_prov_nm,
    t13.enc_attndg_prov_id,
    t13.enc_attndg_prov_nm,
    t13.enc_loc_nm_dv AS pt_loc_nm,
    t13.enc_vis_typ_descr AS visit_ty
FROM
    dart_ods.ods_edw_enc_pt_enc t1
    LEFT JOIN (
        SELECT
            pt_id,
            1 AS molst_ind
        FROM
            dart_ods.ods_edw_enc_doc_info
        WHERE
            doc_typ_descr IN (
                'MOLST'
            )
        GROUP BY
            pt_id,
            1
    ) t2 ON t1.pt_id = t2.pt_id
    LEFT JOIN (
        SELECT
            pt_id,
            1 AS healthcareproxy_ind
        FROM
            dart_ods.ods_edw_enc_doc_info
        WHERE
            doc_typ_descr IN (
                'HEALTHCARE PROXY'
            )
        GROUP BY
            pt_id,
            1
    ) t3 ON t1.pt_id = t3.pt_id
    LEFT JOIN (
        SELECT
            pt_enc_id,
            1 AS opioid_ind
        FROM
            dart_ods.ods_edw_ord_med
        WHERE
   Med_DESCR LIKE '%MS CONTIN%' 
OR Med_DESCR LIKE '%morphine%'
OR Med_DESCR LIKE '%OXYCODON%' 
OR Med_DESCR LIKE '%FENTANYL%PATCH%' 
OR Med_DESCR LIKE '%METHADONE%'
OR Med_DESCR LIKE '%DILAUDID%'
        GROUP BY
            pt_enc_id,
            1
    ) t4 ON t1.pt_enc_id = t4.pt_enc_id
    LEFT JOIN (
        SELECT
            pt_enc_id,
            1 AS laxative_ind
        FROM
            dart_ods.ods_edw_ord_med
        WHERE
   Med_DESCR LIKE '%polyethylene glycol%'
or Med_DESCR LIKE '%SENNA%' 
or Med_DESCR LIKE '%COLACE%' 
or Med_DESCR LIKE '%docusate%'
or Med_DESCR LIKE '%MILK OF MAGNESIA%'
or Med_DESCR LIKE '%BISACODYL%'
or Med_DESCR LIKE '%MAGNESIUM%CITRATE%' 
or Med_DESCR LIKE '%LACTULOSE%'
        GROUP BY
            pt_enc_id,
            1
    ) t5 ON t1.pt_enc_id = t5.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_prov t6 ON t1.enc_epic_prov_id = t6.prov_id
    LEFT JOIN (
        SELECT
            pt_enc_id,
            COUNT(pt_enc_id) AS chaplain_cnt
        FROM
            dart_ods.ods_edw_enc_tx_team_prov
        WHERE
            role_descr LIKE '%CHAPLAIN%'
        GROUP BY
            pt_enc_id,
            role_descr
    ) t7 ON t1.pt_enc_id = t7.pt_enc_id
    LEFT JOIN (
        SELECT
            pt_enc_id,
            COUNT(pt_enc_id) AS socialworker_cnt
        FROM
            dart_ods.ods_edw_enc_tx_team_prov
        WHERE
            role_descr = 'SOCIAL WORKER'
        GROUP BY
            pt_enc_id,
            role_descr
    ) t8 ON t1.pt_enc_id = t8.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_pt t9 ON t1.pt_id = t9.pt_id
    LEFT JOIN (
        SELECT DISTINCT
            t1.pt_id,
            t1.ordg_dttm,
            1 AS chemo_ind
        FROM
            dart_ods.ods_edw_ord_proc t1
            LEFT JOIN dartedm.d_cpt_cd@dartprd t2 ON t1.cpt = t2.cpt_cd
        WHERE
            t1.cpt IN (
'51720','C9004','C9006','C9020','C9021','C9025','C9027','C9106','C9110','C9117','C9118','C9119','C9120','C9127','C9129','C9131','C9207'
,'C9213','C9214','C9215','C9216','C9218','C9233','C9235','C9237','C9239','C9240','C9243','C9257','C9259','C9260','C9265','C9272',
'C9273','C9276','C9280','C9284','C9287','C9289','C9292','C9295','C9296','C9410','C9414','C9415','C9417','C9418','C9419','C9420','C9421'
,'C9422','C9423','C9424','C9425','C9426','C9427','C9428','C9429','C9430','C9431','C9432','C9433','C9435','C9436','C9437','C9438',
'C9439','C9440','C9442','C9449','C9453','C9455','J0202','J0207','J0480','J0594','J0880','J0881','J0882','J0885','J0886','J0887','J0888'
,'J0894','J0897','J1050','J1051','J1055','J1260','J1300','J1438','J1439','J1440','J1441','J1442','J1446','J1447','J1459','J1561',
'J1566','J1567','J1568','J1569','J1572','J1595','J1602','J1675','J1725','J1745','J1786','J1826','J1950','J2323','J2352','J2355','J2357'
,'J2425','J2501','J2505','J2562','J2778','J2791','J2793','J2796','J2820','J3262','J3315','J3357','J3590','J7500','J7501','J7502',
'J7505','J7507','J7508','J7513','J7515','J7516','J7517','J7518','J7520','J7525','J7599','J8498','J8510','J8520','J8521','J8530','J8560'
,'J8561','J8562','J8597','J8600','J8610','J8700','J8705','J8999','J9000','J9001','J9002','J9010','J9015','J9017','J9019','J9020',
'J9025','J9027','J9031','J9032','J9033','J9035','J9039','J9040','J9041','J9042','J9043','J9045','J9047','J9050','J9055','J9060','J9062'
,'J9065','J9070','J9080','J9090','J9091','J9092','J9093','J9094','J9095','J9096','J9097','J9098','J9100','J9110','J9120','J9130',
'J9140','J9150','J9151','J9155','J9160','J9165','J9170','J9171','J9178','J9179','J9180','J9181','J9182','J9185','J9190','J9200','J9201'
,'J9202','J9206','J9207','J9208','J9209','J9211','J9213','J9214','J9215','J9216','J9217','J9218','J9219','J9225','J9226','J9228',
'J9230','J9245','J9250','J9260','J9261','J9262','J9263','J9264','J9265','J9266','J9267','J9268','J9270','J9271','J9280','J9290','J9291'
,'J9293','J9299','J9300','J9301','J9302','J9303','J9305','J9306','J9307','J9308','J9310','J9315','J9320','J9328','J9330','J9340',
'J9350','J9351','J9354','J9355','J9357','J9360','J9370','J9371','J9375','J9380','J9390','J9395','J9400','J9999','Q0136','Q2016','Q2017'
,'Q2024','Q2026','Q2043','Q2046','Q2048','Q2049','Q2050','Q4081','S0079','S0088','S0107','S0108','S0115','S0116','S0117','S0135',
'S0145','S0156','S0157','S0170','S0172','S0175','S0176','S0178','S0179','S0187'
            )
    ) t10 ON t1.pt_id = t10.pt_id
    LEFT JOIN dart_ods.ods_edw_enc_pt_enc t11 ON t1.pt_enc_id = t11.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_pt_enc t13 ON t1.pt_enc_id = t13.enc_id_csn
    LEFT JOIN dart_ods.mv_coba_prov t6 ON t13.enc_refer_prov_id = t6.prov_id
    LEFT JOIN dart_ods.mv_coba_prov t6 ON t13.enc_attndg_prov_id = t6.prov_id
    LEFT JOIN (SELECT event_dttm, pt_id, pt_enc_id
                FROM dart_ods.ods_edw_enc_adt
                WHERE pt_cls_cd='103' AND event_dttm>'01-OCT-2015' AND dept_id=10030010039 AND adt_event_typ_descr='ADMISSION' AND adt_event_subtyp_descr^='CANCELED') t14 ON t1.pt_enc_id=t14.pt_enc_id
WHERE
        t1.pt_id IN (
            SELECT
                pe.pt_id
            FROM
                dart_ods.mv_coba_pt_enc pe
            WHERE
                    enc_status_descr IN (
                        'ARRIVED','COMPLETED'
                    )
                AND
                    pe.enc_loc_nm_dv = 'DANA-FARBER CANCER INSTITUTE LONGWOOD'
        )
    AND
        '01-OCT-15' <= t1.cont_dttm
    AND
        t1.cont_dttm <= '30-NOV-17'
;
        