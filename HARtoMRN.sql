/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT 
      SUBSTRING([Enc___Patient_Account], 2, 10) AS HAR
	  ,t2.PatientEncounterID
      ,t2.PatientID
	  ,t2.DepartmentDSC
      ,[HospitalAccountID]
	  ,t5.ADTDepartmentNM
	  ,t5.ADTLocationNM
	  FROM [UserWork].[DFCICOBA].[Immunotherapy] t1
	  LEFT JOIN  [Epic].[Encounter].[PatientEncounter_DFCI] t2 ON SUBSTRING([Enc___Patient_Account], 2, 10)=t2.HospitalAccountID
	  LEFT JOIN  Epic.Patient.Patient_DFCI t3 on t2.PatientID=t3.PatientID
      LEFT JOIN Integration.EMPI.MRN_DFCI t4 ON t3.EDWPatientID=t4.EDWPatientID
	  LEFT JOIN Epic.Encounter.PatientADTDepartment_DFCI t5 ON t5.PatientEncounterID = t2.PatientEncounterID