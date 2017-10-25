--SELECT pp.providerID, ii.IdentityTypeNM, pp.* FROM Epic.Reference.ProviderIdentity pp
--LEFT JOIN Epic.Reference.IdentityType ii on pp.IdentityTypeID = ii.[MasterPersonIndexTypeCD]
--WHERE pp.ProviderID = '1000023';

SELECT TOP 10 --*
pe.UserNM, 
pe.ExtendedUserNM, 
UserStatusDSC, 
pe.EmployeeRecordTypeDSC, 
pe.ProviderID,
rr.ProviderTypeNM,
pos.PlaceOfServiceNM,
pos.PlaceOfServiceID,
rr2.InpatientDefaultRelationshipDSC,
rr2.PrimaryDepartmentDSC,
ppi.IdentityTypeID,
iit.IdentityTypeNM,
ppi.ProviderIdentityID,
rr.*


FROM Person.Employee_DFCI pe 

LEFT JOIN [Reference].[ProviderPlaceOfService] pp ON pp.ProviderID = pe.ProviderID
LEFT JOIN Reference.PlaceOfService pos on pos.PlaceOfServiceID = pp.PlaceOfServiceID
LEFT JOIN [Reference].[ProviderIdentity] ppi on ppi.ProviderID = pe.ProviderID
LEFT JOIN [Epic].[Reference].[IdentityType] iit on iit.MasterPersonIndexTypeCD = ppi.IdentityTypeID
LEFT JOIN Epic.Reference.[Resource] rr ON rr.ProviderID = pe.ProviderID
LEFT JOIN Epic.Reference.Resource2 rr2 ON rr2.ProviderID = pe.ProviderID

WHERE --UserStatusCD = 2 -- = 'Deleted' can optionally remove deleted providers
PrimaryDepartmentDSC = 'DF PALLIATIVE CARE'  --modify for Primary department or remove for ALL
--pe.UserNM LIKE 'HALPORN, J%' --WINER, ERIC%'

--pe.ProviderID = '1007270'  --specific Provider by Provider ID

AND ppi.IdentityTypeID = 6 --Epic Provider ID Only –By Provider Identity Type

