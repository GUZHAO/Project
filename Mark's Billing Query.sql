--BWH ICU (or Hospice) Counts using UCL
USE Epic
SELECT 
 
ProviderBillAreaDSC,
u.BillingProviderID,
em.ExtendedUserNM as BillingProviderNM,
COUNT(DISTINCT PatientID) as PtCount,
COUNT(DISTINCT CAST(u.ServiceDTS as varchar(12)) + PatientID) AS PtSvcDays, 
--AS ICU_Days, Hospice Days, etc...
MIN(u.ServiceDTS) as MinSvcDt, 
MAX(u.ServiceDTS) as MaxSvcDt

FROM [Finance].[UniversalChargeLine_DFCI] u
INNER JOIN Epic.Finance.BillArea ba ON u.ProviderBillAreaCD = ba.BillAreaID
LEFT JOIN Person.Employee_DFCI em ON em.ProviderID = u.BillingProviderID
WHERE --ProviderBillAreaDSC = 'DF BIS BINNEY HOSPICE'
--'DF BPU BINNEY PM ICU' AND 
u.ServiceDTS BETWEEN '1/1/2015' AND '7/31/2017'
AND DepartmentDSC IN ('DF PALLIATIVE CARE', 'DF PSYCH ONC') --, 'BWH PSYCH ONC')
GROUP BY ProviderBillAreaDSC,u.BillingProviderID, em.ExtendedUserNM
ORDER BY ProviderBillAreaDSC,u.BillingProviderID, MinSvcDt
