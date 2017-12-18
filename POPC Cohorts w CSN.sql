/**********CU5 POPC Project Data Modeling**********/
/*For inpatient activity data,  need to double chek to see BHW info is there.*/
USE Epic; --Data Source
USE UserWork; --COBA Temp Data Dump Area for Tableau Mock-up
DECLARE @startdate DATE;
DECLARE @enddate DATE;
SET @startdate = '01/28/2017';
SET @enddate = '08/31/2017';

--POPC Outpatient Clinic----------------------------
DROP TABLE UserWork.DFCICOBA.POPC_Clinic;
SELECT SYSDATETIME() AS CreationDTS,
       'Clinic' AS POPC_Cohort,
       pe.PatientID,
       pe.PatientEncounterID,
       pe.AppointmentDTS AS DTS,      
       di1.DocumentTypeDSC AS MOLST_Ind,
       di2.DocumentTypeDSC AS PROXY_Ind,
	   ttp1.Chaplain_CNT,
       ttp2.SocialWorker_CNT,
       pe.DepartmentDSC,
	   pe.HospitalAdmitTypeDSC,
       m1.Medication AS MSCONTIN_Ind,
       m2.Medication AS OXYCONTI_Ind,
       m3.Medication AS FENTANYL_Ind,
       m4.Medication AS METHADONE_Ind,
       m5.Medication AS MORPHINE_Ind,
       m6.Medication AS OXYCODONE_Ind,
       m7.Medication AS DILAUDID_Ind,
       m8.Medication AS SENNA_Ind,
       m9.Medication AS MIRALAX_Ind,
       m10.Medication AS COLACE_Ind,
       m11.Medication AS MILKOFMAGNESIA_Ind,
       m12.Medication AS LACTULOSE_Ind,
       m13.Medication AS BISACODYL_Ind,
       m14.Medication AS MAGNESIUMCITRATE_Ind,
	   ra.CustomColumn02DSC AS DiseaseCenter,
	   pe.EncounterEpicProviderID,
	   vtr.VisitTypeDSC,
	   adt.PatientServiceDSC,
       loc.RevenueLocationNM AS PatientLocation
--     uc.ReferralProviderID
INTO UserWork.DFCICOBA.POPC_Clinic
FROM Epic.Encounter.PatientEncounter_DFCI pe
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            DocumentTypeDSC
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'MOLST' )/*DocumentStatusDSC is not considered*/
    ) di1
        ON pe.PatientEncounterID = di1.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            DocumentTypeDSC
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'Healthcare Proxy' )/*DocumentStatusDSC is not considered*/
    ) di2
        ON pe.PatientEncounterID = di2.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            VisitTypeID,
            VisitTypeDSC
        FROM Epic.Reference.VisitTypeRecord
    ) vtr
        ON pe.VisitTypeID = vtr.VisitTypeID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS Chaplain_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC LIKE '%Chaplain%'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp1
        ON pe.PatientEncounterID = ttp1.PatientEncounterID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS SocialWorker_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC = 'Social Worker'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp2
        ON pe.PatientEncounterID = ttp2.PatientEncounterID
    /*Medication dosage, consuming method are not considered and it follows the list of drugs that Dr.Tulsky gave us*/
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MS CONTIN' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MS CONTIN%'
    ) AS m1
        ON pe.PatientEncounterID = m1.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCONTI' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCONTI%'
    ) AS m2
        ON pe.PatientEncounterID = m2.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'FENTANYL' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%FENTANYL%PATCH%'
    ) AS m3
        ON pe.PatientEncounterID = m3.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'METHADONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%METHADONE%'
    ) AS m4
        ON pe.PatientEncounterID = m4.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MORPHINE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MORPHINE%'
    ) AS m5
        ON pe.PatientEncounterID = m5.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCODONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCODONE%'
    ) AS m6
        ON pe.PatientEncounterID = m6.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'DILAUDID' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%DILAUDID%'
    ) AS m7
        ON pe.PatientEncounterID = m7.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'SENNA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%SENNA%'
    ) AS m8
        ON pe.PatientEncounterID = m8.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MIRALAX' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MIRALAX%'
    ) AS m9
        ON pe.PatientEncounterID = m9.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'COLACE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%COLACE%'
    ) AS m10
        ON pe.PatientEncounterID = m10.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MILK OF MAGNESIA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MILK OF MAGNESIA%'
    ) AS m11
        ON pe.PatientEncounterID = m11.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'LACTULOSE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%LACTULOSE%'
    ) AS m12
        ON pe.PatientEncounterID = m12.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'BISACODYL' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%BISACODYL%'
    ) AS m13
        ON pe.PatientEncounterID = m13.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MAGNESIUM CITRATE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MAGNESIUM%CITRATE%'
    ) AS m14
        ON pe.PatientEncounterID = m14.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            PatientServiceDSC
        FROM Epic.Encounter.ADT_DFCI
        WHERE ADTEventTypeCD = 7
    ) AS adt
        ON pe.PatientEncounterID = adt.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            t1.LocationID,
            t1.RevenueLocationNM,
            t2.DepartmentID
        FROM Epic.Reference.Location t1
            LEFT JOIN Epic.Reference.Department t2
                ON t1.LocationID = t2.RevenueLocationID
    ) AS loc
        ON pe.DepartmentID = loc.DepartmentID
	LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            CustomColumn02DSC
        FROM Epic.Patient.RegistrationAdditional_DFCI
    ) AS ra
        ON pe.PatientID = ra.PatientID
/*    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            ServiceDTS,
            ReferralProviderID
        FROM Epic.Finance.UniversalChargeLine_DFCI
        WHERE DepartmentDSC IN ( 'DF PALLIATIVE CARE', 'DF PSYCH ONC' )
              AND ReferralProviderID IS NOT NULL
    ) AS uc
        ON pe.PatientID = uc.PatientID
           AND CAST(uc.ServiceDTS AS DATE) = CAST(pe.AppointmentDTS AS DATE)*/
WHERE --pe.DepartmentDSC IN ( 'DF PALLIATIVE CARE', 'DF PSYCH ONC' )
      --AND pe.AppointmentStatusDSC IN ( 'Completed', 'Arrived' )
      pe.AppointmentDTS
      BETWEEN @startdate AND @enddate;

--IPCU Stay-----------------------------------------
DROP TABLE UserWork.DFCICOBA.POPC_IPCU;
DECLARE @startdate DATE;
DECLARE @enddate DATE;
SET @startdate = '01/28/2017';
SET @enddate = '08/31/2017';
SELECT SYSDATETIME() AS CreationDTS,
       CASE WHEN pb.BillAreaID=821 THEN 'IPCU' WHEN pb.BillAreaID=814 THEN 'GIP' END AS POPC_Cohort,
       pb.PatientID,
       pb.PatientEncounterID,
       pb.ServiceDTS AS DTS,
       pb.BillAreaID,
       pb.PlaceOfServiceID,      --	,adt.PatientServiceDSC
       di1.DocumentTypeDSC AS MOLST_Ind,
       di2.DocumentTypeDSC AS PROXY_Ind,
       ttp1.Chaplain_CNT,
       ttp2.SocialWorker_CNT,
       hap.ProviderID AS AttendingProviderID,
       peh.DepartmentDSC,
       peh.DischargeDispositionDSC,
       peh.HospitalAdmitDTS,
       peh.HospitalDischargeDTS,
       peh.HospitalAdmitTypeDSC, --	,rfv.ReasonNM
       m1.Medication AS MSCONTIN_Ind,
       m2.Medication AS OXYCONTI_Ind,
       m3.Medication AS FENTANYL_Ind,
       m4.Medication AS METHADONE_Ind,
       m5.Medication AS MORPHINE_Ind,
       m6.Medication AS OXYCODONE_Ind,
       m7.Medication AS DILAUDID_Ind,
       m8.Medication AS SENNA_Ind,
       m9.Medication AS MIRALAX_Ind,
       m10.Medication AS COLACE_Ind,
       m11.Medication AS MILKOFMAGNESIA_Ind,
       m12.Medication AS LACTULOSE_Ind,
       m13.Medication AS BISACODYL_Ind,
       m14.Medication AS MAGNESIUMCITRATE_Ind,
	   ra.CustomColumn02DSC AS DiseaseCenter
INTO UserWork.DFCICOBA.POPC_IPCU
FROM Epic.Finance.ProfessionalBillingTransaction_DFCI pb
    -- LEFT JOIN CTE AS adt ON pb.PatientEncounterID=adt.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            PatientEncounterID,
            DocumentTypeDSC,
            ServiceDTS
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'MOLST' )
    ) di1
        ON pb.PatientID = di1.PatientID
           AND pb.ServiceDTS = di1.ServiceDTS
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            PatientEncounterID,
            DocumentTypeDSC,
            ServiceDTS
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'Healthcare Proxy' )
    ) di2
        ON pb.PatientID = di2.PatientID
           AND pb.ServiceDTS = di2.ServiceDTS
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS Chaplain_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC LIKE '%Chaplain%'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp1
        ON pb.PatientEncounterID = ttp1.PatientEncounterID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS SocialWorker_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC = 'Social Worker'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp2
        ON pb.PatientEncounterID = ttp2.PatientEncounterID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               DepartmentDSC,
               DischargeDispositionDSC,
               HospitalAdmitDTS,
               HospitalDischargeDTS,
               HospitalAdmitTypeDSC
        FROM Epic.Encounter.PatientEncounterHospital_DFCI
    ) AS peh
        ON pb.PatientEncounterID = peh.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            ProviderID,
            AttendingStartDTS
        FROM Epic.Encounter.HospitalAttendingProvider_DFCI
        WHERE ProviderID NOT LIKE 'E%'
    ) AS hap
        ON peh.PatientEncounterID = hap.PatientEncounterID
           AND peh.HospitalAdmitDTS = hap.AttendingStartDTS
    /* LEFT JOIN (SELECT DISTINCT
                   PatientEncounterID
                  ,PatientServiceDSC
				  ,EventDTS
            FROM Epic.Encounter.ADT_DFCI
			ORDER BY PatientEncounterID) AS adt ON peh.PatientEncounterID=adt.PatientEncounterID AND peh.HospitalAdmitDTS=adt.EventDTS*/
    /* LEFT JOIN (SELECT DISTINCT PatientEncounterID
                           ,ReasonNM
						   ,ROW_NUMBER() OVER (PARTITION BY PatientEncounterID ORDER BY ReasonNM) AS rn
            FROM Epic.Encounter.ReasonForVisit_DFCI) AS rfv ON pb.PatientEncounterID=rfv.PatientEncounterID*/
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MS CONTIN' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MS CONTIN%'
    ) AS m1
        ON pb.PatientEncounterID = m1.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCONTI' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCONTI%'
    ) AS m2
        ON pb.PatientEncounterID = m2.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'FENTANYL' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%FENTANYL%PATCH%'
    ) AS m3
        ON pb.PatientEncounterID = m3.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'METHADONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%METHADONE%'
    ) AS m4
        ON pb.PatientEncounterID = m4.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MORPHINE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MORPHINE%'
    ) AS m5
        ON pb.PatientEncounterID = m5.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCODONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCODONE%'
    ) AS m6
        ON pb.PatientEncounterID = m6.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'DILAUDID' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%DILAUDID%'
    ) AS m7
        ON pb.PatientEncounterID = m7.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'SENNA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%SENNA%'
    ) AS m8
        ON pb.PatientEncounterID = m8.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MIRALAX' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MIRALAX%'
    ) AS m9
        ON pb.PatientEncounterID = m9.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'COLACE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%COLACE%'
    ) AS m10
        ON pb.PatientEncounterID = m10.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MILK OF MAGNESIA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MILK OF MAGNESIA%'
    ) AS m11
        ON pb.PatientEncounterID = m11.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'LACTULOSE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%LACTULOSE%'
    ) AS m12
        ON pb.PatientEncounterID = m12.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'BISACODYL' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%BISACODYL%'
    ) AS m13
        ON pb.PatientEncounterID = m13.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MAGNESIUM CITRATE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MAGNESIUM%CITRATE%'
    ) AS m14
        ON pb.PatientEncounterID = m14.PatientEncounterID
	LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            CustomColumn02DSC
        FROM Epic.Patient.RegistrationAdditional_DFCI
    ) AS ra
        ON pb.PatientID = ra.PatientID
WHERE pb.BillAreaID IN ( 821, 814 ) --IPCU area and Hospice area
      AND pb.PlaceOfServiceID = 690 --(BWH MAIN CAMPUS IP)
      AND pb.ServiceDTS
      BETWEEN @startdate AND @enddate;

--IP Consult to PC--------------------------------------------------------------------------------
--need Orders.Procedure2_BWHDFCI and Orders.Procedure3_BWHDFCI views to complete filter
DROP TABLE UserWork.DFCICOBA.POPC_Consult;

SELECT SYSDATETIME() AS CreationDTS,
       'Consult' AS POPC_Cohort,
       pt.PatientID,
       op.PatientEncounterID,
       op.OrderingDTS AS DTS,
       di1.DocumentTypeDSC AS MOLST_Ind,
       di2.DocumentTypeDSC AS PROXY_Ind,
	   ttp1.Chaplain_CNT,
       ttp2.SocialWorker_CNT,
	   hap.ProviderID AS AttendingProviderID,
       ENC_HOSP.DepartmentDSC,
       ENC_HOSP.DischargeDispositionDSC,
       ENC_HOSP.HospitalAdmitDTS,
       ENC_HOSP.HospitalDischargeDTS,
       ENC_HOSP.HospitalAdmitTypeDSC,
       m1.Medication AS MSCONTIN_Ind,
       m2.Medication AS OXYCONTI_Ind,
       m3.Medication AS FENTANYL_Ind,
       m4.Medication AS METHADONE_Ind,
       m5.Medication AS MORPHINE_Ind,
       m6.Medication AS OXYCODONE_Ind,
       m7.Medication AS DILAUDID_Ind,
       m8.Medication AS SENNA_Ind,
       m9.Medication AS MIRALAX_Ind,
       m10.Medication AS COLACE_Ind,
       m11.Medication AS MILKOFMAGNESIA_Ind,
       m12.Medication AS LACTULOSE_Ind,
       m13.Medication AS BISACODYL_Ind,
       m14.Medication AS MAGNESIUMCITRATE_Ind,
	   ra.CustomColumn02DSC AS DiseaseCenter,
       loc.RevenueLocationNM AS PatientLocation,
	   op.ProcedureCD,
       op.ServiceAreaID,
       pt.BirthDTS,
       pt.SexDSC,
       pt.ZipCD
--,pidb.PatientIdentityID as BWH_MRN,
--,pidd.PatientIdentityID as DFCI_MRN,
INTO UserWork.DFCICOBA.POPC_Consult
FROM Epic.Patient.Patient_BWHDFCI pt
    JOIN Epic.Orders.Procedure_BWHDFCI op
        ON pt.PatientID = op.PatientID
    --  JOIN Epic.Orders.Procedure3_DFCI EDW_ORD_PROC_03 ON EDW_ORD_PROC.OrderProcedureID = EDW_ORD_PROC_03.OrderID
    --  JOIN Epic.Person.Employee_DFCI EDW_PERSON_EMPL ON EDW_ORD_PROC_03.StatusCompleteUserID = EDW_PERSON_EMPL.UserID 
    --  JOIN Epic.Orders.Procedure2_DFCI EDW_ORD_PROC_02 ON EDW_ORD_PROC.OrderProcedureID = EDW_ORD_PROC_02.OrderProcedureID
    JOIN Epic.Encounter.PatientEncounterHospital_BWHDFCI ENC_HOSP
        ON ENC_HOSP.PatientEncounterID = op.PatientEncounterID
    --  LEFT JOIN Epic.Patient.Identity_BWHDFCI pidb on (pidb.PatientID = pt.PatientID AND pidb.IdentityTypeID = 69) BWH MRN
    --  LEFT JOIN Epic.Patient.Identity_BWHDFCI pidd on (pidd.PatientID = pt.PatientID AND pidd.IdentityTypeID = 109) DFCI MRN
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            ProviderID,
            AttendingStartDTS
        FROM Epic.Encounter.HospitalAttendingProvider_DFCI
        WHERE ProviderID NOT LIKE 'E%'
    ) hap
        ON ENC_HOSP.PatientEncounterID = hap.PatientEncounterID
           AND ENC_HOSP.HospitalAdmitDTS = hap.AttendingStartDTS
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            DocumentTypeDSC
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'MOLST' )
    ) di1
        ON ENC_HOSP.PatientEncounterID = di1.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            DocumentTypeDSC
        FROM Epic.Encounter.DocumentInformation_DFCI
        WHERE DocumentTypeDSC IN ( 'Healthcare Proxy' )
    ) di2
        ON ENC_HOSP.PatientEncounterID = di2.PatientEncounterID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS Chaplain_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC LIKE '%Chaplain%'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp1
        ON ENC_HOSP.PatientEncounterID = ttp1.PatientEncounterID
    LEFT JOIN
    (
        SELECT PatientEncounterID,
               COUNT(PatientEncounterID) AS SocialWorker_CNT
        FROM Epic.Encounter.TreatmentTeamProvider_DFCI
        WHERE RoleDSC = 'Social Worker'
        GROUP BY PatientEncounterID,
                 RoleDSC
    ) ttp2
        ON ENC_HOSP.PatientEncounterID = ttp2.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            CustomColumn02DSC
        FROM Epic.Patient.RegistrationAdditional_DFCI
    ) AS ra
        ON pt.PatientID = ra.PatientID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MS CONTIN' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MS CONTIN%'
    ) AS m1
        ON ENC_HOSP.PatientEncounterID = m1.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCONTI' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCONTI%'
    ) AS m2
        ON ENC_HOSP.PatientEncounterID = m2.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'FENTANYL PATCH' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%FENTANYL%PATCH%'
    ) AS m3
        ON ENC_HOSP.PatientEncounterID = m3.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'METHADONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%METHADONE%'
    ) AS m4
        ON ENC_HOSP.PatientEncounterID = m4.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MORPHINE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MORPHINE%'
    ) AS m5
        ON ENC_HOSP.PatientEncounterID = m5.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'OXYCODONE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%OXYCODONE%'
    ) AS m6
        ON ENC_HOSP.PatientEncounterID = m6.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'DILAUDID' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%DILAUDID%'
    ) AS m7
        ON ENC_HOSP.PatientEncounterID = m7.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'SENNA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%SENNA%'
    ) AS m8
        ON ENC_HOSP.PatientEncounterID = m8.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MIRALAX' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MIRALAX%'
    ) AS m9
        ON ENC_HOSP.PatientEncounterID = m9.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'COLACE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%COLACE%'
    ) AS m10
        ON ENC_HOSP.PatientEncounterID = m10.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MILK OF MAGNESIA' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MILK OF MAGNESIA%'
    ) AS m11
        ON ENC_HOSP.PatientEncounterID = m11.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'LACTULOSE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%LACTULOSE%'
    ) AS m12
        ON ENC_HOSP.PatientEncounterID = m12.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'BISACODYL' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%BISACODYL%'
    ) AS m13
        ON ENC_HOSP.PatientEncounterID = m13.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientEncounterID,
            'MAGNESIUM CITRATE' AS Medication
        FROM Epic.Orders.Medication_DFCI
        WHERE MedicationDSC LIKE '%MAGNESIUM%CITRATE%'
    ) AS m14
        ON ENC_HOSP.PatientEncounterID = m14.PatientEncounterID
    LEFT JOIN
    (
        SELECT DISTINCT
            t1.LocationID,
            t1.RevenueLocationNM,
            t2.DepartmentID
        FROM Epic.Reference.Location t1
            LEFT JOIN Epic.Reference.Department t2
                ON t1.LocationID = t2.RevenueLocationID
    ) AS loc
        ON ENC_HOSP.DepartmentID = loc.DepartmentID
WHERE op.ProcedureID = 371 --'IP CONSULT TO PALLIATIVE CARE'
      AND op.ServiceAreaID = 10 --Partners Service Area
      --EDW_ORD_PROC_03.StatusCompleteDTS IS NOT NULL and  --Completed Consults
      --EDW_ORD_PROC_02.PatientLocationDSC like 'BWH%'  --Occurred in BWH location
      AND op.OrderingDTS
      BETWEEN @startdate AND @enddate;

--Patient Information------------------------------------
/*PatientRaceDSC 'Unavailable' values are removed*/
/*PatientRaceDSC  only the first value will be selected*/
DROP TABLE UserWork.DFCICOBA.POPC_Patient_Info;
WITH CTE
AS (SELECT DISTINCT
        PatientID,
        PatientRaceDSC,
        ROW_NUMBER() OVER (PARTITION BY PatientID ORDER BY PatientRaceDSC DESC) AS RN
    FROM Epic.Patient.Race_DFCI
    WHERE PatientRaceDSC != 'Unavailable')
SELECT t1.PatientID,
       t1.BirthDTS,
       t1.SexDSC,
       t1.ZipCD,
       t2.PatientRaceDSC,
       t3.CustomColumn02DSC AS DiseaseCenter
INTO UserWork.DFCICOBA.POPC_Patient_Info
FROM Epic.Patient.Patient_DFCI t1
    LEFT JOIN
    (SELECT CTE.* FROM CTE WHERE CTE.RN = 1) AS t2
        ON t1.PatientID = t2.PatientID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            CustomColumn02DSC
        FROM Epic.Patient.RegistrationAdditional_DFCI
    ) AS t3
        ON t1.PatientID = t3.PatientID;
