public with sharing class DonationDao {
    
    @AuraEnabled(cacheable=false)
    public static List<Donation__c> getDonationsByDonorId(Id donorId, Date donationDateFrom, Date donationDateTo) {
        if(donorId == null){
            return null;
        }
        return [
            SELECT
                Id,
                Name,
                DonationDate__c,
                DonationType__c,
                DonationAmount__c,
                DonationAverageAmount__c,
                Donor__c,
                DonationUnitClass__c,
                DonationSpouseName__c,
                DonationFamilyName__c,
                DonationStartDate__c,
                DonationFinishDate__c,
                DonationYearMonth__c,
                DonationNo__c,
                DonationMainOrSub__c,
                AccountingUnit__c,
                ParentDonation__c,
                NotUsedForAggregation__c,
                DonationNote__c
            FROM
                Donation__c
            WHERE
                Donor__c = :donorId
                AND DonationDate__c >= :donationDateFrom
                AND DonationDate__c <= :donationDateTo
                WITH SECURITY_ENFORCED
            ORDER BY DonationDate__c ASC, Name ASC
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Donation__c> getDonationsByDate(Date donationDateFrom, Date donationDateTo) {
        return [
            SELECT
                Id,
                Name,
                DonationDate__c,
                toLabel(DonationType__c) DonationType__c,
                DonationAmount__c,
                DonorName__c,
                DonationUnitClass__c,
                DonationSpouseName__c,
                DonationFamilyName__c,
                DonationStartDate__c,
                DonationFinishDate__c,
                DonationMonthStr__c,
                DonationMainOrSub__c,
                DonationNote__c
            FROM
                Donation__c
            WHERE
                DonationMainOrSub__c <> 'サブ献金'
                AND Donor__r.PersonType__c IN ('現住陪餐会員','陪餐会員')
                AND DonationDate__c >= :donationDateFrom
                AND DonationDate__c <= :donationDateTo
                WITH SECURITY_ENFORCED
            ORDER BY DonationType__c ASC, DonationDate__c ASC, DonorName__c ASC, DonationMonthStr__c ASC
        ];
    }

    public static List<AggregateResult> getDonationsByDateAggregate(Date donationDateFrom, Date donationDateTo) {
        return [
            SELECT 
                DonationType__c,
                Donor__r.Name DonorName,
                DonationMonthStr__c,
                MAX(DonationSpouseName__c) DonationSpouseName,
                MAX(DonationFamilyName__c) DonationFamilyName,
                MAX(DonationNote__c) DonationNote
            FROM
                Donation__c
            WHERE
                DonationMainOrSub__c <> 'サブ献金'
                AND Donor__r.PersonType__c IN ('現住陪餐会員','陪餐会員')
                AND DonationDate__c >= :donationDateFrom
                AND DonationDate__c <= :donationDateTo
                WITH SECURITY_ENFORCED
            GROUP BY DonationType__c, Donor__r.Name, DonationMonthStr__c
            ORDER BY DonationType__c ASC, Donor__r.Name ASC, DonationMonthStr__c ASC
        ];
    }

    public static List<Donation__c> getMonthlyDonationsByDonorId(Id donorId, ID id) {
        if(donorId == null){
            return null;
        }
        return [
            SELECT
                Id,
                name,
                DonationYearMonth__c,
                DonationStartDate__c,
                DonationFinishDate__c
            FROM
                Donation__c
            WHERE
                Donor__c = :donorId
                AND Id != :id
                AND DonationType__c = '1'
                WITH SECURITY_ENFORCED
            ORDER BY DonationFinishDate__c DESC
        ];
    }

    public static List<AggregateResult> getJornalKaikeiListAggregate(Date donationDateFrom, Date donationDateTo, Boolean isKaikei) {

        List<String> accountingUnitList = new List<String>();
        if (isKaikei) {
            // 「KAIKEI_IF.csv」の出力対象の会計単位
            accountingUnitList.add('教会通常会計');
        } else {
            // 「SIEN_IF.csv」の出力対象の会計単位
            accountingUnitList.add('支援と発展会計');
            accountingUnitList.add('ハルモニウム特別会計');
        }

        return [
            SELECT
                DonationDate__c,
                tolabel(DonationType__c) dTypeStr,
                MAX(DebitCode__c) DebitCode,
                MAX(CreditCode__c) CreditCode,
                SUM(DonationAmount__c) DonationAmountSum,
                COUNT(Id) RecordNum
            From
                Donation__c
            WHERE
                DonationMainOrSub__c <> 'サブ献金'
                AND AccountingUnit__c IN :accountingUnitList
                AND DonationDate__c >= :donationDateFrom
                AND DonationDate__c <= :donationDateTo
                WITH SECURITY_ENFORCED
            GROUP BY
                DonationDate__c, DonationType__c
            ORDER BY DonationDate__c ASC, DonationType__c ASC
        ];
    }

    @AuraEnabled
    public static void updateDonations(Object data) {
        List<Donation__c> donationsForUpdate = (List<Donation__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Donation__c>.class
        );
        update donationsForUpdate;
        System.debug('DonationDao#updateDonations Done Successfully');
    }

    @AuraEnabled
    public static String deleteDonationById(Id id){
        Donation__c donation = [
            SELECT Id, Name 
            FROM Donation__c
            WHERE Id = :id 
            WITH SECURITY_ENFORCED LIMIT 1
            ]; 
        delete donation;

        String msg = 'DonationDao#deleteDonationById Done Successfully (ID: ' + id + ')';
        System.debug(msg);
        return msg;
    } 
}