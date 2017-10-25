/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT 
      SUBSTRING([Enc___Patient_Account], 2, 10) AS HAR
	  ,[PatientEncounterID]
      ,t2.PatientID
      ,[HospitalAccountID]
	  ,t4.MRN
	  FROM [UserWork].[DFCICOBA].[Immunotherapy] t1
	  LEFT JOIN  [Epic].[Encounter].[PatientEncounter_DFCI] t2 ON SUBSTRING([Enc___Patient_Account], 2, 10)=t2.HospitalAccountID
	  LEFT JOIN  Epic.Patient.Patient_DFCI t3 on t2.PatientID=t3.PatientID
      LEFT JOIN Integration.EMPI.MRN_DFCI t4 ON t3.EDWPatientID=t4.EDWPatientID