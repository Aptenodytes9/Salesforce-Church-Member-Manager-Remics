public with sharing class DeceasedSurvivorDao {

    // 召天者記念礼拝の案内を送付する遺族を取得
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDate(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                SurvivorPerson__r.Name,
                SurvivorIRelationshipFromHouseholder__c,
                SurvivorHousehold__c,
                SurvivorHousehold__r.Name,
                SurvivorHousehold__r.PostalCode__c,
                SurvivorHousehold__r.AddressAllCombined__c,
                SurvivorHousehold__r.HouseholderName__c,
                SurvivorHousehold__r.JointSignature1__c,
                SurvivorHousehold__r.JointSignature2__c,
                SurvivorHousehold__r.JointSignature3__c,
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
            ORDER BY SurvivorHousehold__c ASC, SurvivorIRelationshipFromHouseholder__c DESC, DeceasedDate__c DESC
        ];
    }
}