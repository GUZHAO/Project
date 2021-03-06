/****** homework 1 checking primary key for all the foreign tables ******/

/*DocumentInformation_DFCI*/

--Purpose:checking the 2 document categories I want--
--Result:might need to exlcude some, see SQL below--
SELECT DISTINCT
    DocumentTypeDSC
FROM Epic.Encounter.DocumentInformation_DFCI
WHERE DocumentTypeDSC LIKE '%MOLST%'
      OR DocumentTypeDSC LIKE '%PROXY%';

--Purpose:checking document type counts--
--Result:see OneNote--
SELECT tt1.DocumentTypeDSC,
       tt1.DocumentStatusDSC,
       COUNT(tt1.DocumentTypeDSC) AS DOC_CNT
FROM Epic.Encounter.DocumentInformation_DFCI tt1
WHERE tt1.DocumentTypeDSC IN ( 'MOLST' )
      OR tt1.DocumentTypeDSC LIKE '%PROXY%'
GROUP BY tt1.DocumentTypeDSC,
         tt1.DocumentStatusDSC
ORDER BY DOC_CNT DESC;

--Purpose:checking a specific encounter that has multiple documents falling into the category--
--Result:it seems to be pure duplicates, will apply distinct statement in SQL--
SELECT PatientEncounterID,
       DocumentTypeDSC,
       DocumentStatusDSC
FROM Epic.Encounter.DocumentInformation_DFCI
WHERE PatientEncounterID = 3103919320;

--Purpose:checking primary key--
--Result:can't use encounter ID as the primary key as there are a fair amount records that having missing document types. Use Patient ID as the primary key--
SELECT tt1.PatientID,
       tt1.DocumentTypeDSC,
       tt1.DocumentStatusDSC,
       COUNT(DISTINCT tt1.PatientID) AS tt1_CNT
FROM Epic.Encounter.DocumentInformation_DFCI tt1
WHERE tt1.DocumentTypeDSC IN ( 'MOLST', 'Healthcare Proxy' )
GROUP BY tt1.PatientID,
         tt1.DocumentTypeDSC,
         tt1.DocumentStatusDSC
ORDER BY tt1.PatientID DESC;
--Final Result:MOLST and Healthcare Proxy have to be considered seperately as a patient could have both of them

/*VisitTypeRecord*/
--Purpose:get a unique list of visit type and find the primary key--
--Result:VisitTypeID can be used as primary key--
SELECT VisitTypeID,
       VisitTypeDSC,
       COUNT(VisitTypeID) AS CNT
FROM Epic.Reference.VisitTypeRecord
GROUP BY VisitTypeID,
         VisitTypeDSC
ORDER BY CNT DESC;
--Final Result:join the table as is


/*PatientEncounterHospital_DFCI*/
--Purpose:checking primary key--
--Result:patient encounter id can be used as the primary key--
SELECT PatientID,
       DepartmentDSC,
       HospitalAdmitTypeDSC,
       COUNT(DISTINCT PatientID) AS CNT
FROM Epic.Encounter.PatientEncounterHospital_DFCI
WHERE DepartmentDSC LIKE '%DF%'
      OR DepartmentDSC LIKE '%BW%'
GROUP BY PatientID,
         DepartmentDSC,
         HospitalAdmitTypeDSC
ORDER BY CNT DESC;

--Purpose:checking the encounter difference between PatientEcnounter table and PatientEncounterHospital table--
--Result:PatientEncounter table contains more encounters for a single patient generally. There might be reason for that design but I'm just not aware of it--
SELECT PatientID,
       PatientEncounterID,
       DepartmentDSC,
       HospitalAdmitTypeDSC
FROM Epic.Encounter.PatientEncounterHospital_DFCI
WHERE PatientID = 'Z9884380'
ORDER BY PatientEncounterID;

SELECT PatientID,
       PatientEncounterID,
       DepartmentDSC,
       HospitalAdmitTypeDSC
FROM Epic.Encounter.PatientEncounter_DFCI
WHERE PatientID = 'Z9884380'
ORDER BY PatientEncounterID;
--Final Result:grabbing Department and Admission Type data from PatientEncounter table directly 

/*TreatmentTeamProvider_DFCI*/
--Purpose:checking if encouter vs provider is unique
--Result:need to bring AttendingStartDTS
SELECT PatientEncounterID,
       ProviderID,
       AttendingStartDTS,
       ROW_NUMBER() OVER (PARTITION BY PatientEncounterID
                          ORDER BY AttendingStartDTS,
                                   ProviderID
                         ) AS rn
FROM [Epic].[Encounter].[HospitalAttendingProvider_DFCI]
WHERE ProviderID NOT LIKE 'E%'
GROUP BY PatientEncounterID,
         ProviderID,
         AttendingStartDTS
ORDER BY PatientEncounterID;

--Purpose:checking the primary key
--Result:due to that a single encounter can have mutiple records for a single day, it has to be deduplicated before joining
SELECT PatientID,
       RoleDSC,
       COUNT(PatientID) AS CNT
FROM Epic.Encounter.TreatmentTeamProvider_DFCI
WHERE RoleDSC LIKE '%Chaplain%'
      OR RoleDSC LIKE '%Social%'
GROUP BY PatientID,
         RoleDSC
ORDER BY CNT DESC;

--Purpose:checking how to deduplicate
--Result:pre-calculate the number of vivist for Chaplain & Social Workers visits, See OneNote
SELECT PatientEncounterID,
       LineNBR,
       RoleDSC,
       ActionDSC,
       ProviderID,
       ProviderTeamID,
       EditDTS
FROM Epic.Encounter.TreatmentTeamProvider_DFCI
WHERE PatientEncounterID = 3158084015
      AND
      (
          RoleDSC LIKE '%Chaplain%'
          OR RoleDSC LIKE '%Social%'
      );

--Purpose:checking dates
--Result:EditDTS is also part of the primary key but can not proceed with this key
SELECT PatientEncounterID,
       RoleDSC,
       CAST(EditDTS AS DATE) AS EDITDT,
       COUNT(PatientEncounterID) AS CNT
FROM Epic.Encounter.TreatmentTeamProvider_DFCI
WHERE RoleDSC LIKE '%Chaplain%'
      OR RoleDSC LIKE '%Social%'
GROUP BY PatientEncounterID,
         RoleDSC,
         CAST(EditDTS AS DATE)
ORDER BY CNT DESC;
--Fianl Result:count Chaplain and Social Worker(students excluded) Role for each patient only and separately

/*Medication_DFCI*/
--Purpose:checking how to present the bowel regiment medications based on encounter level.
--Result:have to create uniqu column for each medication and turn them into indicators. Unfortunately dosage, form and route can't be considered.
SELECT t1.PatientEncounterID,
       t2.MedicationNM,
       t1.MedicationID,
       COUNT(DISTINCT t1.PatientEncounterID) AS CNT
FROM Epic.Orders.Medication_DFCI t1
    LEFT JOIN
    (
        SELECT MedicationID,
               MedicationNM
        FROM Epic.Reference.MedicationRecord2
    ) AS t2
        ON t1.MedicationID = t2.MedicationID
WHERE t2.MedicationNM LIKE '%MS CONTIN%'
      OR t2.MedicationNM LIKE '%OXYCONTIN%'
      OR t2.MedicationNM LIKE '%FENTANYL%PATCH%'
      OR t2.MedicationNM LIKE '%METHADONE%'
      OR t2.MedicationNM LIKE '%MORPHINE%'
      OR t2.MedicationNM LIKE '%OXYCODONE%'
      OR t2.MedicationNM LIKE '%DILAUDID%'
      OR t2.MedicationNM LIKE '%SENNA%'
      OR t2.MedicationNM LIKE '%MIRALAX%'
      OR t2.MedicationNM LIKE '%COLACE%'
      OR t2.MedicationNM LIKE '%MILK OF MAGNESIA%'
      OR t2.MedicationNM LIKE '%LACTULOSE%'
      OR t2.MedicationNM LIKE '%BISACODYL%'
      OR t2.MedicationNM LIKE '%MAGNESIUM%CITRATE%'
GROUP BY t1.PatientEncounterID,
         t2.MedicationNM,
         t1.MedicationID
ORDER BY CNT DESC,
         t1.PatientEncounterID;

--Purpose:check patient has chemo within last 2 weeks before they expired
--Result:
WITH CTE
AS (SELECT t1.PatientID,
           t1.OrderDTS,
           t2.MedicationNM,
           t1.MedicationID,
           --,COUNT(DISTINCT t1.PatientEncounterID) AS CNT
           ROW_NUMBER() OVER (PARTITION BY t1.PatientID ORDER BY t1.OrderDTS DESC) AS rn
    FROM Epic.Orders.Medication_DFCI t1
        LEFT JOIN
        (
            SELECT MedicationID,
                   MedicationNM
            FROM Epic.Reference.MedicationRecord2
        ) AS t2
            ON t1.MedicationID = t2.MedicationID
    WHERE t2.MedicationNM LIKE '%CHEMO%'
          AND t1.OrderDTS IS NOT NULL
--GROUP BY t1.PatientID
--      ,t1.OrderDTS
--	    ,t2.MedicationNM
--	    ,t1.MedicationID
--ORDER BY CNT DESC
--        ,t1.PatientEncounterID
)
SELECT *
FROM CTE
WHERE rn = 1;

--Purpose:checking OrderDTS could exceed patient expiration date--
--Result:
SELECT t1.PatientEncounterID,
       t1.OrderDTS,
       t1.OrderClassDSC,
       t1.OrderStatusDSC,
       t2.DischargeDTS,
       t3.DischargeDispositionDSC,
       t3.DischargeDestinationDSC,
       t3.DischargeCategoryDSC,
       t3.HospitalDischargeDTS
FROM Epic.Orders.Medication_DFCI t1
    LEFT JOIN Epic.Encounter.PatientEncounter_DFCI t2
        ON t1.PatientEncounterID = t2.PatientEncounterID
    LEFT JOIN Epic.Encounter.PatientEncounterHospital_DFCI t3
        ON t1.PatientEncounterID = t3.PatientEncounterID
WHERE t1.MedicationDSC LIKE '%CHEMO%'
      AND t3.DischargeDispositionDSC LIKE '%EXPIRED%'
ORDER BY t1.PatientEncounterID,
         t1.OrderDTS;
--Final Result:

/*ADT_DFCI*/
--Purpose:check primary key--
--Result:need to distinct count encounters based on services--
SELECT DISTINCT
    PatientEncounterID,
    PatientServiceDSC,
    EventDTS
--	  ,COUNT(DISTINCT PatientEncounterID) AS CNT
FROM Epic.Encounter.ADT_DFCI
GROUP BY PatientEncounterID,
         PatientServiceDSC,
         EventDTS
ORDER BY PatientEncounterID;
--Final Results:join the table as is

/*UniversalChargeLine_DFCI*/
--Purpose:check the primary key--
--Result:put this on hold as this is not on encounter level and the patient id alone can not be a primary key--
SELECT DISTINCT
    t1.PatientID,
    t1.ServiceDTS,
    t1.ReferralProviderID,
    t2.AppointmentDTS
FROM Epic.Finance.UniversalChargeLine_DFCI t1
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            AppointmentDTS
        FROM Epic.Encounter.PatientEncounter_DFCI
    ) t2
        ON t1.PatientID = t2.PatientID
           AND CAST(t1.ServiceDTS AS DATE) = CAST(t2.AppointmentDTS AS DATE)
WHERE t1.DepartmentDSC IN ( 'DF PALLIATIVE CARE', 'DF PSYCH ONC' )
      AND t1.ReferralProviderID IS NOT NULL;

SELECT PatientID,
       ReferralProviderID,
       SystemFlagDSC,
       COUNT(DISTINCT PatientID) AS CNT
FROM Epic.Finance.UniversalChargeLine_DFCI
WHERE DepartmentDSC IN ( 'DF PALLIATIVE CARE', 'DF PSYCH ONC' )
      AND SystemFlagDSC NOT IN ( 'DELETED', 'VOIDED' )
GROUP BY PatientID,
         ReferralProviderID,
         SystemFlagDSC
ORDER BY CNT DESC;
--Final Results: 

/*Procedure_DFCI*/
--Purpose:check primary key--
--Result:
WITH CTEE
AS (SELECT PatientID,
           PatientEncounterID,
           OrderingDTS,
           ProcedureCD,
           CASE
               WHEN CPT IN ( '99201', '99202', '99203', '99204', '99205' ) THEN
                   'NEW'
               WHEN CPT IN ( '99211', '99212', '99213', '99214', '99215' ) THEN
                   'ESTABLISHED'
               ELSE
                   'NONE'
           END AS Category_CPT,
           COUNT(DISTINCT PatientID) AS CNT
    FROM Epic.Orders.Procedure_DFCI
    WHERE ProcedureCD LIKE '99%'
    GROUP BY PatientID,
             PatientEncounterID,
             OrderingDTS,
             ProcedureCD,
             CPT
--ORDER BY CNT DESC
)
SELECT DISTINCT
    PatientID,
    PatientEncounterID,
    OrderingDTS,
    Category_CPT
INTO UserWork.DFCICOBA.CPT_TEST
FROM CTEE;

SELECT *,
       ROW_NUMBER() OVER (PARTITION BY PatientID,
                                       OrderingDTS,
                                       Category_CPT
                          ORDER BY OrderingDTS DESC
                         ) AS rn
FROM UserWork.DFCICOBA.CPT_TEST
WHERE YEAR(OrderingDTS) >= 2017;

SELECT *
FROM UserWork.DFCICOBA.POPC_Clinic T1
    LEFT JOIN UserWork.DFCICOBA.CPT_TEST T2
        ON T1.PatientID = T2.PatientID;

/*Patient_DFCI*/
--Purpose:check primary key
--Result:can't get race information due to a patient could be assigned to nultiple races.
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
       t2.ReferralTypeDSC,
       t3.PatientRaceDSC,
       t4.CustomColumn02DSC AS DiseaseCenter,
       COUNT(t1.PatientID) AS CNT
FROM Epic.Patient.Patient_DFCI t1
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            ReferralTypeDSC
        FROM Epic.Patient.Referral_DFCI
    ) t2
        ON t1.PatientID = t2.PatientID
    LEFT JOIN
    (SELECT CTE.* FROM CTE WHERE CTE.RN = 1) t3
        ON t1.PatientID = t3.PatientID
    LEFT JOIN
    (
        SELECT DISTINCT
            PatientID,
            CustomColumn02DSC
        FROM Epic.Patient.RegistrationAdditional_DFCI
    ) t4
        ON t1.PatientID = t4.PatientID
GROUP BY t1.PatientID,
         t1.BirthDTS,
         t1.SexDSC,
         t1.ZipCD,
         t2.ReferralTypeDSC,
         t3.PatientRaceDSC,
         t4.CustomColumn02DSC
ORDER BY CNT DESC;
--Final Result:

/*RevenueLocation*/
--Purpose:map revenue location to department
--Result:can create an unique list between revenue location and department
SELECT t1.LocationID,
       t1.RevenueLocationNM,
       t2.RevenueLocationID,
       t2.DepartmentID,
       t2.DepartmentNM,
       COUNT(DISTINCT t1.LocationID) AS CNT
FROM Epic.Reference.Location t1
    LEFT JOIN Epic.Reference.Department t2
        ON t1.LocationID = t2.RevenueLocationID
GROUP BY t1.LocationID,
         t1.RevenueLocationNM,
         t2.RevenueLocationID,
         t2.DepartmentID,
         t2.DepartmentNM
ORDER BY CNT DESC;

/*ReasonForVisit*/
--Purpose:checking primary key
--Result:no appropriate unique key
SELECT PatientEncounterID,
       ReasonNM,
       OnsetDTS,
       COUNT(DISTINCT PatientEncounterID) AS cnt
FROM Epic.Encounter.ReasonForVisit_DFCI
GROUP BY PatientEncounterID,
         ReasonNM,
         OnsetDTS
ORDER BY cnt DESC;


/****** homework 2 checking frequency of the main table ******/
SELECT t1.PatientID,
       t1.PatientEncounterID,
       COUNT(t1.PatientID) AS P_ID_CNT
FROM UserWork.DFCICOBA.POPC_Clinic t1
GROUP BY t1.PatientID,
         t1.PatientEncounterID
ORDER BY P_ID_CNT DESC;
