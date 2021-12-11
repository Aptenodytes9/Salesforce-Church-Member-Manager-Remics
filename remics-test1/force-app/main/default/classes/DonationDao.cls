public with sharing class DonationDao {
    
    @AuraEnabled(cacheable=true)
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
                AccountingMajorClass__c,
                AccountingMinorClass__c,
                AccountingUnit__c,
                CreditCode__c,
                DebitCode__c,
                DonationNo__c,
                DonationMainOrSub__c,
                ParentDonation__c,
                NotUsedForAggregation__c,
                DonationNote__c
            FROM
                Donation__c
            WHERE
                Donor__c = :donorId
                AND DonationDate__c >= :donationDateFrom
                AND DonationDate__c <= :donationDateTo WITH SECURITY_ENFORCED
            ORDER BY DonationDate__c DESC, Name DESC
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