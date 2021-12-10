@isTest
public with sharing class DonationDaoTest {

    @testSetup
    static void setup() {
        Person__c p = new Person__c(
            Name = '佐藤一郎',
            PersonType__c = '現住陪餐会員',
            FamilyName__c = '佐藤',
            ForeName__c = '一郎',
            FamilyNameFurigana__c = 'さとう',
            ForeNameFurigana__c = 'いちろう',
            RelationshipFromHouseholder__c = '本人',
            DonationUnitClass__c = '個人'
        );
        insert p;

        Donation__c d = new Donation__c(
            DonationDate__c = Date.newInstance(2022, 12, 1),
            Donor__c = p.Id,
            DonationAmount__c = 10000,
            DonationType__c = '月次献金'
        );
        insert d;
    }

    @isTest
    static void donationDaoSize() {
        Person__c p = [SELECT Id, Name FROM Person__c LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 1);

        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(1, dList.size(), 'DonationDaoTest.donationDaoSize Error');
        Test.stopTest();
    }
}
