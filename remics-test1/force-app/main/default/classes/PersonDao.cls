public with sharing class PersonDao {

    // 総会議員資格を満たしている教会員を取得
    @AuraEnabled(cacheable=false)
    public static List<Person__c> getQualifiedDonorsByDate(Date dateFrom, Date dateTo) {
        return [
            SELECT 
                Id,
                Name,
                FamilyName__c,
                ForeName__c,
                FamilyNameFurigana__c,
                ForeNameFurigana__c,
                WholeNameFurigana__c,
                PersonType__c,
                RelationshipFromHouseholder__c,
                DonationUnitClass__c,
                PostalCode__c,
                AddressAllCombined__c,
                ParliamentaryQualification__c,
                Deceased__c,
                (SELECT 
                    Id, 
                    Name, 
                    DonationDate__c 
                FROM 
                    DonorRef__r
                WHERE 
                    DonationType__c = '月次献金' 
                    AND DonationDate__c >= :dateFrom 
                    AND DonationDate__c <= :dateTo)
            FROM Person__c 
            WHERE Id IN (SELECT 
                            Donor__c 
                        FROM 
                            Donation__c 
                        WHERE 
                            DonationType__c = '月次献金' 
                            AND DonationDate__c >= :dateFrom 
                            AND DonationDate__c <= :dateTo)
                AND PersonType__c IN ('現住陪餐会員', '陪餐会員')
                AND Deceased__c = FALSE
                WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    }

    // 「総会議員資格あり」= True にも関わらず、総会議員資格を満たしていない教会員を取得
    @AuraEnabled(cacheable=false)
    public static List<Person__c> getUnqualifiedDonorsByDate(Date dateFrom, Date dateTo) {

        // 判定対象期間の間に「月次献金」を1回でも行っている教会員のSetを作成
        List<Donation__c> donationList = [
            SELECT 
                Donor__r.Id
            FROM 
                Donation__c 
            WHERE 
                DonationType__c = '月次献金' 
                AND DonationDate__c >= :dateFrom 
                AND DonationDate__c <= :dateTo
                WITH SECURITY_ENFORCED
        ];
        Set<Id> donorIdSet = new Set<Id>();
        for(Donation__c d : donationList){
            donorIdSet.add(d.Donor__r.Id);
        }

        return [
            SELECT 
                Id,
                Name,
                FamilyName__c,
                ForeName__c,
                FamilyNameFurigana__c,
                ForeNameFurigana__c,
                WholeNameFurigana__c,
                PersonType__c,
                RelationshipFromHouseholder__c,
                DonationUnitClass__c,
                PostalCode__c,
                AddressAllCombined__c,
                ParliamentaryQualification__c,
                Deceased__c,
                (SELECT 
                    Id, 
                    Name, 
                    DonationDate__c 
                FROM 
                    DonorRef__r
                WHERE 
                    DonationType__c = '月次献金' 
                    AND DonationDate__c >= :dateFrom 
                    AND DonationDate__c <= :dateTo)
            FROM Person__c 
            WHERE 
                ParliamentaryQualification__c = TRUE
                AND (
                    Id NOT IN :donorIdSet
                    OR PersonType__c NOT IN ('現住陪餐会員', '陪餐会員')
                    OR Deceased__c = TRUE
                )
                WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    }

    @AuraEnabled
    public static void updatePersons(Object data) {
        List<Person__c> personsForUpdate = (List<Person__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Person__c>.class
        );
        update personsForUpdate;
        System.debug('DonationDao#updatePersons Done Successfully');
    }
}