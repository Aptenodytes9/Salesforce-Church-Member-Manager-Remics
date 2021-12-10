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
    static void getDonationsByDonorIdTest() {
        Person__c p = [SELECT Id, Name FROM Person__c LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(1, dList.size(), 'DonationDaoTest.getDonationsByDonorIdTest Error');
        Test.stopTest();
    }

    @isTest
    static void getDonationsByDonorIdTest_Null() {
        Person__c p = [SELECT Id, Name FROM Person__c LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(null, dateFrom, dateTo);

        Test.startTest();
        System.assert(dList == null, 'DonationDaoTest.getDonationsByDonorIdTest Error');
        Test.stopTest();
    }

    @isTest
    static void updateDonationsTest() {
        Person__c p = [SELECT Id, Name FROM Person__c LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        dList[0].DonationDate__c = Date.newInstance(2022, 12, 15);
        dList[0].DonationNote__c = 'new value';
        DonationDao.updateDonations(dList);
        List<Donation__c> newDList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(1, newDList.size(), 'DonationDaoTest.updateDonations Size Error');
        System.assertEquals('2022/12/15', newDList[0].DonationDate__c.format(), 'DonationDaoTest.updateDonations DonationDate__c Error');
        System.assertEquals('new value', newDList[0].DonationNote__c, 'DonationDaoTest.updateDonations DonationNote__c Error');
        Test.stopTest();
    }

    @isTest
    static void deleteDonationByIdTest() {
        Person__c p = [SELECT Id, Name FROM Person__c LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Donation__c donation = dList[0];
        String msg = DonationDao.deleteDonationById(donation.Id);
        List<Donation__c> deletedDList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(0, deletedDList.size(), 'DonationDaoTest.deleteDonationByIdTest Error');
        System.assert(msg.contains('DonationDao#deleteDonationById Done Successfully'), 'DonationDaoTest.deleteDonationByIdTest Error');
        Test.stopTest();
    }
}
