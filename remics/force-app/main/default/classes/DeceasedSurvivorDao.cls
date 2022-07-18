public with sharing class DeceasedSurvivorDao {

    // 指定期間に召天した召天者とその遺族を世帯順に取得
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyHousehold(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // 遺族
                SurvivorPerson__r.Name,
                SurvivorIRelationshipFromHouseholder__c,
                // 世帯
                SurvivorHousehold__c,
                SurvivorHousehold__r.Name,
                SurvivorHousehold__r.PostalCode__c,
                SurvivorHousehold__r.AddressAllCombined__c,
                SurvivorHousehold__r.HouseholderName__c,
                SurvivorHousehold__r.JointSignature1__c,
                SurvivorHousehold__r.JointSignature2__c,
                SurvivorHousehold__r.JointSignature3__c,
                // 召天者
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
                    OR (DeceasedDate__c >= :dateList[14] AND DeceasedDate__c <= :dateList[15])
                    OR (DeceasedDate__c >= :dateList[16] AND DeceasedDate__c <= :dateList[17])
                    OR (DeceasedDate__c >= :dateList[18] AND DeceasedDate__c <= :dateList[19])
                    OR (DeceasedDate__c >= :dateList[20] AND DeceasedDate__c <= :dateList[21])
                    OR (DeceasedDate__c >= :dateList[22] AND DeceasedDate__c <= :dateList[23])
                    OR (DeceasedDate__c >= :dateList[24] AND DeceasedDate__c <= :dateList[25])
                    OR (DeceasedDate__c >= :dateList[26] AND DeceasedDate__c <= :dateList[27])
                    OR (DeceasedDate__c >= :dateList[28] AND DeceasedDate__c <= :dateList[29])
                    OR (DeceasedDate__c >= :dateList[30] AND DeceasedDate__c <= :dateList[31])
                    OR (DeceasedDate__c >= :dateList[32] AND DeceasedDate__c <= :dateList[33])
                    OR (DeceasedDate__c >= :dateList[34] AND DeceasedDate__c <= :dateList[35])
                    OR (DeceasedDate__c >= :dateList[36] AND DeceasedDate__c <= :dateList[37])
                    OR (DeceasedDate__c >= :dateList[38] AND DeceasedDate__c <= :dateList[39])
                    OR (DeceasedDate__c >= :dateList[40] AND DeceasedDate__c <= :dateList[41])
                    OR (DeceasedDate__c >= :dateList[42] AND DeceasedDate__c <= :dateList[43])
                    OR (DeceasedDate__c >= :dateList[44] AND DeceasedDate__c <= :dateList[45])
                    OR (DeceasedDate__c >= :dateList[46] AND DeceasedDate__c <= :dateList[47])
                    OR (DeceasedDate__c >= :dateList[48] AND DeceasedDate__c <= :dateList[49])
                    OR (DeceasedDate__c >= :dateList[50] AND DeceasedDate__c <= :dateList[51])
                    OR (DeceasedDate__c >= :dateList[52] AND DeceasedDate__c <= :dateList[53])
                    OR (DeceasedDate__c >= :dateList[54] AND DeceasedDate__c <= :dateList[55])
                    OR (DeceasedDate__c >= :dateList[56] AND DeceasedDate__c <= :dateList[57])
                    OR (DeceasedDate__c >= :dateList[58] AND DeceasedDate__c <= :dateList[59])
                    OR (DeceasedDate__c >= :dateList[60] AND DeceasedDate__c <= :dateList[61])
                    OR (DeceasedDate__c >= :dateList[62] AND DeceasedDate__c <= :dateList[63])
                    OR (DeceasedDate__c >= :dateList[64] AND DeceasedDate__c <= :dateList[65])
                    OR (DeceasedDate__c >= :dateList[66] AND DeceasedDate__c <= :dateList[67])
                    OR (DeceasedDate__c >= :dateList[68] AND DeceasedDate__c <= :dateList[69])
                    OR (DeceasedDate__c >= :dateList[70] AND DeceasedDate__c <= :dateList[71])
                    OR (DeceasedDate__c >= :dateList[72] AND DeceasedDate__c <= :dateList[73])
                    OR (DeceasedDate__c >= :dateList[74] AND DeceasedDate__c <= :dateList[75])
                    OR (DeceasedDate__c >= :dateList[76] AND DeceasedDate__c <= :dateList[77])
                    OR (DeceasedDate__c >= :dateList[78] AND DeceasedDate__c <= :dateList[79])
                    OR (DeceasedDate__c >= :dateList[80] AND DeceasedDate__c <= :dateList[81])
                    OR (DeceasedDate__c >= :dateList[82] AND DeceasedDate__c <= :dateList[83])
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

    // 指定期間に召天した召天者とその遺族を召天年度順に取得
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyDeceasedDate(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // 召天者
                DeceasedPerson__c,
                DeceasedPerson__r.Name,
                DeceasedPerson__r.PersonNumCurrent__c,
                DeceasedPerson__r.PersonType__c,
                DeceasedDate__c,
                DeceasedPerson__r.BoneDate__c,
                DeceasedPerson__r.Remains__c,
                // 遺族
                SurvivorPerson__r.Name,
                SurvivorPerson__r.PersonNumCurrent__c,
                SurvivorRelationship__c,
                SurvivorPerson__r.CelestialWorshipShipment__c,
                // 世帯
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
                    OR (DeceasedDate__c >= :dateList[14] AND DeceasedDate__c <= :dateList[15])
                    OR (DeceasedDate__c >= :dateList[16] AND DeceasedDate__c <= :dateList[17])
                    OR (DeceasedDate__c >= :dateList[18] AND DeceasedDate__c <= :dateList[19])
                    OR (DeceasedDate__c >= :dateList[20] AND DeceasedDate__c <= :dateList[21])
                    OR (DeceasedDate__c >= :dateList[22] AND DeceasedDate__c <= :dateList[23])
                    OR (DeceasedDate__c >= :dateList[24] AND DeceasedDate__c <= :dateList[25])
                    OR (DeceasedDate__c >= :dateList[26] AND DeceasedDate__c <= :dateList[27])
                    OR (DeceasedDate__c >= :dateList[28] AND DeceasedDate__c <= :dateList[29])
                    OR (DeceasedDate__c >= :dateList[30] AND DeceasedDate__c <= :dateList[31])
                    OR (DeceasedDate__c >= :dateList[32] AND DeceasedDate__c <= :dateList[33])
                    OR (DeceasedDate__c >= :dateList[34] AND DeceasedDate__c <= :dateList[35])
                    OR (DeceasedDate__c >= :dateList[36] AND DeceasedDate__c <= :dateList[37])
                    OR (DeceasedDate__c >= :dateList[38] AND DeceasedDate__c <= :dateList[39])
                    OR (DeceasedDate__c >= :dateList[40] AND DeceasedDate__c <= :dateList[41])
                    OR (DeceasedDate__c >= :dateList[42] AND DeceasedDate__c <= :dateList[43])
                    OR (DeceasedDate__c >= :dateList[44] AND DeceasedDate__c <= :dateList[45])
                    OR (DeceasedDate__c >= :dateList[46] AND DeceasedDate__c <= :dateList[47])
                    OR (DeceasedDate__c >= :dateList[48] AND DeceasedDate__c <= :dateList[49])
                    OR (DeceasedDate__c >= :dateList[50] AND DeceasedDate__c <= :dateList[51])
                    OR (DeceasedDate__c >= :dateList[52] AND DeceasedDate__c <= :dateList[53])
                    OR (DeceasedDate__c >= :dateList[54] AND DeceasedDate__c <= :dateList[55])
                    OR (DeceasedDate__c >= :dateList[56] AND DeceasedDate__c <= :dateList[57])
                    OR (DeceasedDate__c >= :dateList[58] AND DeceasedDate__c <= :dateList[59])
                    OR (DeceasedDate__c >= :dateList[60] AND DeceasedDate__c <= :dateList[61])
                    OR (DeceasedDate__c >= :dateList[62] AND DeceasedDate__c <= :dateList[63])
                    OR (DeceasedDate__c >= :dateList[64] AND DeceasedDate__c <= :dateList[65])
                    OR (DeceasedDate__c >= :dateList[66] AND DeceasedDate__c <= :dateList[67])
                    OR (DeceasedDate__c >= :dateList[68] AND DeceasedDate__c <= :dateList[69])
                    OR (DeceasedDate__c >= :dateList[70] AND DeceasedDate__c <= :dateList[71])
                    OR (DeceasedDate__c >= :dateList[72] AND DeceasedDate__c <= :dateList[73])
                    OR (DeceasedDate__c >= :dateList[74] AND DeceasedDate__c <= :dateList[75])
                    OR (DeceasedDate__c >= :dateList[76] AND DeceasedDate__c <= :dateList[77])
                    OR (DeceasedDate__c >= :dateList[78] AND DeceasedDate__c <= :dateList[79])
                    OR (DeceasedDate__c >= :dateList[80] AND DeceasedDate__c <= :dateList[81])
                    OR (DeceasedDate__c >= :dateList[82] AND DeceasedDate__c <= :dateList[83])
                    )
                WITH SECURITY_ENFORCED
            ORDER BY 
                DeceasedDate__c DESC,
                DeceasedPerson__r.Name ASC
        ];
    }

    // 指定期間に召天した召天者とその遺族を遺族郵便番号・住所・続柄・誕生日順に取得
    @AuraEnabled(cacheable=true)
    public static List<DeceasedSurvivor__c> getDeceasedSurvivorByDateOrderbyPostalcode(List<Date> dateList) {
        return [
            SELECT 
                Id,
                Name,
                // 召天者
                DeceasedPerson__c,
                DeceasedPerson__r.Name,
                DeceasedPerson__r.PersonNumCurrent__c,
                DeceasedPerson__r.PersonType__c,
                DeceasedDate__c,
                DeceasedPerson__r.BoneDate__c,
                DeceasedPerson__r.Remains__c,
                // 遺族
                SurvivorPerson__r.Name,
                SurvivorPerson__r.PersonNumCurrent__c,
                SurvivorPerson__r.PersonType__c,
                SurvivorRelationship__c,
                SurvivorPerson__r.CelestialWorshipShipment__c,
                // 世帯
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
                    OR (DeceasedDate__c >= :dateList[14] AND DeceasedDate__c <= :dateList[15])
                    OR (DeceasedDate__c >= :dateList[16] AND DeceasedDate__c <= :dateList[17])
                    OR (DeceasedDate__c >= :dateList[18] AND DeceasedDate__c <= :dateList[19])
                    OR (DeceasedDate__c >= :dateList[20] AND DeceasedDate__c <= :dateList[21])
                    OR (DeceasedDate__c >= :dateList[22] AND DeceasedDate__c <= :dateList[23])
                    OR (DeceasedDate__c >= :dateList[24] AND DeceasedDate__c <= :dateList[25])
                    OR (DeceasedDate__c >= :dateList[26] AND DeceasedDate__c <= :dateList[27])
                    OR (DeceasedDate__c >= :dateList[28] AND DeceasedDate__c <= :dateList[29])
                    OR (DeceasedDate__c >= :dateList[30] AND DeceasedDate__c <= :dateList[31])
                    OR (DeceasedDate__c >= :dateList[32] AND DeceasedDate__c <= :dateList[33])
                    OR (DeceasedDate__c >= :dateList[34] AND DeceasedDate__c <= :dateList[35])
                    OR (DeceasedDate__c >= :dateList[36] AND DeceasedDate__c <= :dateList[37])
                    OR (DeceasedDate__c >= :dateList[38] AND DeceasedDate__c <= :dateList[39])
                    OR (DeceasedDate__c >= :dateList[40] AND DeceasedDate__c <= :dateList[41])
                    OR (DeceasedDate__c >= :dateList[42] AND DeceasedDate__c <= :dateList[43])
                    OR (DeceasedDate__c >= :dateList[44] AND DeceasedDate__c <= :dateList[45])
                    OR (DeceasedDate__c >= :dateList[46] AND DeceasedDate__c <= :dateList[47])
                    OR (DeceasedDate__c >= :dateList[48] AND DeceasedDate__c <= :dateList[49])
                    OR (DeceasedDate__c >= :dateList[50] AND DeceasedDate__c <= :dateList[51])
                    OR (DeceasedDate__c >= :dateList[52] AND DeceasedDate__c <= :dateList[53])
                    OR (DeceasedDate__c >= :dateList[54] AND DeceasedDate__c <= :dateList[55])
                    OR (DeceasedDate__c >= :dateList[56] AND DeceasedDate__c <= :dateList[57])
                    OR (DeceasedDate__c >= :dateList[58] AND DeceasedDate__c <= :dateList[59])
                    OR (DeceasedDate__c >= :dateList[60] AND DeceasedDate__c <= :dateList[61])
                    OR (DeceasedDate__c >= :dateList[62] AND DeceasedDate__c <= :dateList[63])
                    OR (DeceasedDate__c >= :dateList[64] AND DeceasedDate__c <= :dateList[65])
                    OR (DeceasedDate__c >= :dateList[66] AND DeceasedDate__c <= :dateList[67])
                    OR (DeceasedDate__c >= :dateList[68] AND DeceasedDate__c <= :dateList[69])
                    OR (DeceasedDate__c >= :dateList[70] AND DeceasedDate__c <= :dateList[71])
                    OR (DeceasedDate__c >= :dateList[72] AND DeceasedDate__c <= :dateList[73])
                    OR (DeceasedDate__c >= :dateList[74] AND DeceasedDate__c <= :dateList[75])
                    OR (DeceasedDate__c >= :dateList[76] AND DeceasedDate__c <= :dateList[77])
                    OR (DeceasedDate__c >= :dateList[78] AND DeceasedDate__c <= :dateList[79])
                    OR (DeceasedDate__c >= :dateList[80] AND DeceasedDate__c <= :dateList[81])
                    OR (DeceasedDate__c >= :dateList[82] AND DeceasedDate__c <= :dateList[83])
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