
SELECT 
pb.ServiceAreaID, 
pb.ProcedureID,
rp.ProcedureNM,
COUNT(DISTINCT pb.PatientID) AS DistinctPatientID, 
Min(ServiceDTS), 
Max(ServiceDTS) 

FROM Finance.ProfessionalBillingTransaction_DFCI pb

LEFT JOIN Reference.[Procedure] rp on rp.ProcedureID = pb.ProcedureID

WHERE pb.DepartmentDSC LIKE 'DF PALL%'
AND pb.PlaceOfServiceID = 690 --BWH MAIN CAMPUS IP
GROUP BY pb.ServiceAreaID, pb.ProcedureID, rp.ProcedureNM
