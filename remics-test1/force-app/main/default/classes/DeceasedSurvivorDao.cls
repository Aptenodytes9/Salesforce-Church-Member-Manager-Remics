public with sharing class DeceasedSurvivorDao {

    // Acquire the Deceased People and their bereaved families in the order of households
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyHousehold(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // Bereaved families
                SurvivorPerson__r.Name,
                SurvivorIRelationshipFromHouseholder__c,
                // Households
                SurvivorHousehold__c,
                SurvivorHousehold__r.Name,
                SurvivorHousehold__r.PostalCode__c,
                SurvivorHousehold__r.AddressAllCombined__c,
                SurvivorHousehold__r.HouseholderName__c,
                SurvivorHousehold__r.JointSignature1__c,
                SurvivorHousehold__r.JointSignature2__c,
                SurvivorHousehold__r.JointSignature3__c,
                // Deceased People
                DeceasedPerson__c,
                DeceasedPerson__r.Name,
                DeceasedDate__c,
                SurvivorRelationship__c
            FROM DeceasedSurvivor__c 
            WHERE SurvivorDeath__c = FALSE
                AND (
                    (DeceasedDate__c >= :dateList[0] AND DeceasedDate__c <= :dateList[1])
                    OR (DeceasedDate__c >= :dateList[2] AND DeceasedDate__c <= :dateList[3])
                    OR (DeceasedDate__c >= :dateList[4] AND DeceasedDate__c <= :dateList[5])
                    OR (DeceasedDate__c >= :dateList[6] AND DeceasedDate__c <= :dateList[7])
                    OR (DeceasedDate__c >= :dateList[8] AND DeceasedDate__c <= :dateList[9])
                    OR (DeceasedDate__c >= :dateList[10] AND DeceasedDate__c <= :dateList[11])
                    OR (DeceasedDate__c >= :dateList[12] AND DeceasedDate__c <= :dateList[13])
                    )
                WITH SECURITY_ENFORCED
            ORDER BY 
                SurvivorHousehold__c ASC,
                SurvivorHousehold__r.PostalCode__c ASC,
                SurvivorHousehold__r.AddressAllCombined__c ASC,
                SurvivorIRelationshipFromHouseholder__c DESC,
                DeceasedDate__c DESC
        ];
    }

    // Acquire the Deceased People and their bereaved families in the order of Death date
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyDeceasedDate(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // Deceased People
                DeceasedPerson__c,
                DeceasedPerson__r.Name,
                DeceasedPerson__r.PersonNumCurrent__c,
                DeceasedPerson__r.PersonType__c,
                DeceasedDate__c,
                DeceasedPerson__r.BoneDate__c,
                DeceasedPerson__r.Remains__c,
                // Bereaved families
                SurvivorPerson__r.Name,
                SurvivorPerson__r.PersonNumCurrent__c,
                SurvivorRelationship__c,
                SurvivorPerson__r.CelestialWorshipShipment__c,
                // Households
                SurvivorHousehold__r.PostalCode__c,
                SurvivorHousehold__r.AddressAllCombined__c
            FROM DeceasedSurvivor__c 
            WHERE SurvivorDeath__c = FALSE
                AND (
                    (DeceasedDate__c >= :dateList[0] AND DeceasedDate__c <= :dateList[1])
                    OR (DeceasedDate__c >= :dateList[2] AND DeceasedDate__c <= :dateList[3])
                    OR (DeceasedDate__c >= :dateList[4] AND DeceasedDate__c <= :dateList[5])
                    OR (DeceasedDate__c >= :dateList[6] AND DeceasedDate__c <= :dateList[7])
                    OR (DeceasedDate__c >= :dateList[8] AND DeceasedDate__c <= :dateList[9])
                    OR (DeceasedDate__c >= :dateList[10] AND DeceasedDate__c <= :dateList[11])
                    OR (DeceasedDate__c >= :dateList[12] AND DeceasedDate__c <= :dateList[13])
                    )
                WITH SECURITY_ENFORCED
            ORDER BY 
                DeceasedDate__c DESC,
                DeceasedPerson__r.Name ASC
        ];
    }

    // Acquire the Deceased People and their bereaved families in the order of Bereaved family zip code, address, relationship, birthday
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyPostalcode(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // Deceased People
                DeceasedPerson__c,
                DeceasedPerson__r.Name,
                DeceasedPerson__r.PersonNumCurrent__c,
                DeceasedPerson__r.PersonType__c,
                DeceasedDate__c,
                DeceasedPerson__r.BoneDate__c,
                DeceasedPerson__r.Remains__c,
                // Bereaved families
                SurvivorPerson__r.Name,
                SurvivorPerson__r.PersonNumCurrent__c,
                SurvivorPerson__r.PersonType__c,
                SurvivorRelationship__c,
                SurvivorPerson__r.CelestialWorshipShipment__c,
                // Households
                SurvivorHousehold__r.PostalCode__c,
                SurvivorHousehold__r.AddressAllCombined__c
            FROM DeceasedSurvivor__c 
            WHERE SurvivorDeath__c = FALSE
                AND (
                    (DeceasedDate__c >= :dateList[0] AND DeceasedDate__c <= :dateList[1])
                    OR (DeceasedDate__c >= :dateList[2] AND DeceasedDate__c <= :dateList[3])
                    OR (DeceasedDate__c >= :dateList[4] AND DeceasedDate__c <= :dateList[5])
                    OR (DeceasedDate__c >= :dateList[6] AND DeceasedDate__c <= :dateList[7])
                    OR (DeceasedDate__c >= :dateList[8] AND DeceasedDate__c <= :dateList[9])
                    OR (DeceasedDate__c >= :dateList[10] AND DeceasedDate__c <= :dateList[11])
                    OR (DeceasedDate__c >= :dateList[12] AND DeceasedDate__c <= :dateList[13])
                    )
                WITH SECURITY_ENFORCED
            ORDER BY 
                SurvivorHousehold__r.PostalCode__c ASC,
                SurvivorHousehold__r.AddressAllCombined__c ASC,
                SurvivorPerson__r.RelationshipFromHouseholder__c ASC,
                SurvivorPerson__r.Birthday__c ASC
        ];
    }
}