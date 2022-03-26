@isTest
public with sharing class DuplicateDonationUtilTest {

    static void setup(Boolean isInsertDuplicateDonation) {

        // Creating household records
        Household__c h = new Household__c(
            Name = '佐藤家',
            Prefecture__c = '東京都',
            Municipalities__c = '港区',
            HouseNumber__c = '赤坂1-2-3'
        );
        insert h;

        // Creating person records (member of the church)
        Person__c p = new Person__c(
            Name = '佐藤一郎',
            PersonType__c = '現住陪餐会員',
            FamilyName__c = '佐藤',
            ForeName__c = '一郎',
            FamilyNameFurigana__c = 'さとう',
            ForeNameFurigana__c = 'いちろう',
            RelationshipFromHouseholder__c = '本人',
            DonationUnitClass__c = '個人',
            Household__c = h.Id
        );
        insert p;

        // Creating onation records
        List<Donation__c> dList = new List<Donation__c>();

        Donation__c dGetsuji = new Donation__c(
            DonationDate__c = Date.newInstance(2022, 12, 1),
            DonationStartDate__c = Date.newInstance(2022, 12, 1),
            DonationFinishDate__c = Date.newInstance(2023, 1, 31),
            Donor__c = p.Id,
            DonationAmount__c = 10000,
            DonationType__c = '1' // Monthly donations
        );
        Donation__c dGetsuji2 = new Donation__c(
            DonationDate__c = Date.newInstance(2022, 12, 1),
            DonationStartDate__c = Date.newInstance(2023, 2, 1),
            DonationFinishDate__c = Date.newInstance(2023, 3, 31),
            Donor__c = p.Id,
            DonationAmount__c = 20000,
            DonationType__c = '1' // Monthly donations
        );
        Donation__c dToki = new Donation__c(
            DonationDate__c = Date.newInstance(2022, 12, 1),
            DonationStartDate__c = Date.newInstance(2022, 12, 1),
            DonationFinishDate__c = Date.newInstance(2023, 1, 31),
            Donor__c = p.Id,
            DonationAmount__c = 20000,
            DonationType__c = '3', // Special winter donations
            DonationNote__c = '感謝'
        );
        Donation__c dToki2 = new Donation__c(
            DonationDate__c = Date.newInstance(2022, 12, 1),
            DonationStartDate__c = Date.newInstance(2022, 12, 1),
            DonationFinishDate__c = Date.newInstance(2023, 1, 31),
            Donor__c = p.Id,
            DonationAmount__c = 10000,
            DonationType__c = '3', // Special winter donations
            DonationNote__c = '感謝'
        );
        dList.add(dGetsuji);
        dList.add(dGetsuji2);
        dList.add(dToki);
        dList.add(dToki2);

        insert dList;

        if(isInsertDuplicateDonation){
            Donation__c dGetsujiDuplicate = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 1),
                DonationStartDate__c = Date.newInstance(2023, 2, 1),
                DonationFinishDate__c = Date.newInstance(2023, 3, 31),
                Donor__c = p.Id,
                DonationAmount__c = 30000,
                DonationType__c = '1' // Monthly donations
            );
            insert dGetsujiDuplicate;
        }
    }

    @isTest
    static void successCurrectDonationInsertTest() {
        Boolean expectedExceptionThrown = false;
        try {
            setup(false);
        } catch(Exception e) {
            expectedExceptionThrown =  e.getMessage().contains('献金月が同じ月次献金レコードがすでに存在します');
        }
        System.assertEquals(false, expectedExceptionThrown, 'DuplicateDonationUtilTest.successCurrectDonationInsertTest Error');
    }

    @isTest
    static void failDupliDonationInsertTest() {
        Boolean expectedExceptionThrown = false;
        try {
            setup(true);
        } catch(Exception e) {
            System.debug('fail');
            System.debug(e.getMessage());
            expectedExceptionThrown =  e.getMessage().contains('献金月が同じ月次献金レコードがすでに存在します');
        }
        System.assertEquals(true, expectedExceptionThrown, 'DuplicateDonationUtilTest.failDupliDonationInsertTest Error');
    }

    // Confirmation of the "donation date" change trigger not working when updating without changing the "start date" and "end date"
    @isTest
    static void unTriggerDonationUpdateTest() {
        setup(false);

        Donation__c dBeforeUpdate = [SELECT Id, Name, DonationYearMonth__c, DonationNote__c FROM Donation__c WHERE DonationType__c = '1' LIMIT 1];
        String donationYearMonth = dBeforeUpdate.DonationYearMonth__c;
        Id id = dBeforeUpdate.Id;
        dBeforeUpdate.DonationNote__c = 'test';
        update dBeforeUpdate;

        Donation__c dAfterUpdate = [SELECT Id, Name, DonationYearMonth__c, DonationNote__c FROM Donation__c WHERE Id = :id LIMIT 1];

        System.assertEquals(id, dAfterUpdate.Id, 'DuplicateDonationUtilTest.unTriggerDonationUpdateTest Error');
        System.assertEquals(donationYearMonth, dAfterUpdate.DonationYearMonth__c, 'DuplicateDonationUtilTest.unTriggerDonationUpdateTest Error');
        System.assertEquals('test', dAfterUpdate.DonationNote__c, 'DuplicateDonationUtilTest.unTriggerDonationUpdateTest Error');
    }

    // Saving Confirmation of Updating the "start date" and "end date" to Empty
    @isTest
    static void nullDateUpdateTest() {
        setup(false);

        Donation__c dBeforeUpdate = [SELECT Id, Name, DonationStartDate__c, DonationFinishDate__c FROM Donation__c WHERE DonationType__c = '3' LIMIT 1];
        Id id = dBeforeUpdate.Id;
        dBeforeUpdate.DonationStartDate__c = null;
        dBeforeUpdate.DonationFinishDate__c = null;
        update dBeforeUpdate;

        Donation__c dAfterUpdate = [SELECT Id, Name, DonationStartDate__c, DonationFinishDate__c, DonationYearMonth__c FROM Donation__c WHERE Id = :id LIMIT 1];

        System.assertEquals(id, dAfterUpdate.Id, 'DuplicateDonationUtilTest.nullDateUpdateTest Error');
        System.assertEquals(null, dAfterUpdate.DonationStartDate__c, 'DuplicateDonationUtilTest.nullDateUpdateTest Error');
        System.assertEquals(null, dAfterUpdate.DonationFinishDate__c, 'DuplicateDonationUtilTest.nullDateUpdateTest Error');
        System.assertEquals(null, dAfterUpdate.DonationYearMonth__c, 'DuplicateDonationUtilTest.nullDateUpdateTest Error');
    }
}
