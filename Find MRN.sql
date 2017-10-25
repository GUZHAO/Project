/*Find MRN*/
SELECT PatientEncounterID,
       PatientID
FROM [Epic].[Encounter].[PatientEncounter_DFCI]
WHERE PatientEncounterID='3158084015'

SELECT PatientID
      ,EDWPatientID
FROM epic.patient.Patient_DFCI
WHERE patientID='Z8308805'

SELECT EDWPatientID,
       MRN
FROM Integration.empi.MRN_DFCI
WHERE EDWPatientID='1193430'