@isTest
public with sharing class DonationDaoTest {

    @testSetup
    static void setup() {

        // 世帯レコードの作成
        Household__c h = new Household__c(
            Name = '佐藤家',
            Prefecture__c = '東京都',
            Municipalities__c = '港区',
            HouseNumber__c = '赤坂1-2-3'
        );
        insert h;

        // 人レコード(教会員)の作成
        List<Person__c> pList = new List<Person__c>();
        for (Integer i = 0; i < 4; i++) {
            Person__c p = new Person__c(
                Name = '佐藤一郎' + String.valueOf(i),
                PersonType__c = '現住陪餐会員',
                FamilyName__c = '佐藤',
                ForeName__c = '一郎' + i,
                FamilyNameFurigana__c = 'さとう',
                ForeNameFurigana__c = 'いちろう' + String.valueOf(i),
                RelationshipFromHouseholder__c = '本人',
                DonationUnitClass__c = '個人',
                Household__c = h.Id
            );
            pList.add(p);
        }
        insert pList;

        // 献金単位区分=「夫婦」の人レコードの作成
        Person__c pHusband = pList[1];
        Person__c pWife = pList[2];
        
        pHusband.DonationUnitClass__c = '夫婦';
        pHusband.Spouse__c = pWife.Id;

        pWife.Name = '佐藤妻子2';
        pWife.ForeName__c = '妻子2';
        pWife.DonationUnitClass__c = '夫婦';
        pWife.Spouse__c = pHusband.Id;
        pWife.RelationshipFromHouseholder__c = '配偶者';

        // 会員区分=「非会員」の人レコードの作成
        Person__c pHikaiin = pList[3];
        pHikaiin.PersonType__c = '非会員';
        
        update pList;

        List<Donation__c> dList = new List<Donation__c>();
        
        // 献金レコードの作成
        for(Person__c p : pList){
            // 献金単位区分=「夫婦」の場合、その配偶者が単独で献金するケースはないので除外する
            if(p.Id == pWife.Id){
                continue;
            }

            Donation__c dGetsuji = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 1),
                DonationStartDate__c = Date.newInstance(2022, 12, 1),
                DonationFinishDate__c = Date.newInstance(2023, 1, 31),
                Donor__c = p.Id,
                DonationAmount__c = 10000,
                DonationType__c = '1' // 月次献金
            );
            Donation__c dGetsuji2 = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 1),
                DonationStartDate__c = Date.newInstance(2022, 2, 1),
                DonationFinishDate__c = Date.newInstance(2023, 3, 31),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '1' // 月次献金
            );
            Donation__c dToki = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '3', // 冬期特別献金
                DonationNote__c = '感謝'
            );
            Donation__c dToki2 = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 10000,
                DonationType__c = '3', // 冬期特別献金
                DonationNote__c = '感謝'
            );
            Donation__c dOnline = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 30000,
                DonationType__c = '18' // オンライン礼拝献金
            );
            Donation__c dDendo = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 40000,
                DonationType__c = '20' // 伝道支援献金
            );
            Donation__c dKaido = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 50000,
                DonationType__c = '31' // 会堂保全献金
            );
            Donation__c dIntai = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 60000,
                DonationType__c = '33' // 隠退教師謝恩献金
            );
            dList.add(dGetsuji);
            dList.add(dGetsuji2);
            dList.add(dToki);
            dList.add(dToki2);
            dList.add(dOnline);
            dList.add(dDendo);
            dList.add(dKaido);
            dList.add(dIntai);
        }
        insert dList;
    }

    @isTest
    static void getDonationsByDonorIdTest() {
        Person__c p = [SELECT Id, Name FROM Person__c WHERE Name = '佐藤一郎1' LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(8, dList.size(), 'DonationDaoTest.getDonationsByDonorIdTest Error');
        Test.stopTest();
    }

    @isTest
    static void getDonationsByDonorIdNullTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(null, dateFrom, dateTo);

        Test.startTest();
        System.assert(dList == null, 'DonationDaoTest.getDonationsByDonorIdTest Error');
        Test.stopTest();
    }

    @isTest
    static void getDonationsByDateTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDate(dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(16, dList.size(), 'DonationDaoTest.getDonationsByDateTest Error');
        Test.stopTest();
    }

    @isTest
    static void getDonationsByDateAggregateTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<AggregateResult> dList = DonationDao.getDonationsByDateAggregate(dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(14, dList.size(), 'DonationDaoTest.getDonationsByDateAggregate Error');
        Test.stopTest();
    }

    @isTest
    static void getJornalKaikeiListAggregateTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<AggregateResult> dKList = DonationDao.getJornalKaikeiListAggregate(dateFrom, dateTo, true);
        List<AggregateResult> dSList = DonationDao.getJornalKaikeiListAggregate(dateFrom, dateTo, false);

        Test.startTest();
        System.assertEquals(3, dKList.size(), 'DonationDaoTest.getJornalKaikeiListAggregate Error');
        System.assertEquals(3, dKList.size(), 'DonationDaoTest.getJornalKaikeiListAggregate Error');
        Test.stopTest();
    }

    @isTest
    static void updateDonationsTest() {
        Person__c p = [SELECT Id, Name FROM Person__c WHERE Name = '佐藤一郎1' LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        dList[0].DonationNote__c = 'new value';
        DonationDao.updateDonations(dList);
        List<Donation__c> newDList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(8, newDList.size(), 'DonationDaoTest.updateDonations Size Error');
        System.assertEquals('new value', newDList[0].DonationNote__c, 'DonationDaoTest.updateDonations DonationNote__c Error');
        Test.stopTest();
    }

    @isTest
    static void deleteDonationByIdTest() {
        Person__c p = [SELECT Id, Name FROM Person__c WHERE Name = '佐藤一郎1' LIMIT 1];
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Donation__c> dList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Donation__c donation = dList[0];
        String msg = DonationDao.deleteDonationById(donation.Id);
        List<Donation__c> deletedDList = DonationDao.getDonationsByDonorId(p.Id, dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(7, deletedDList.size(), 'DonationDaoTest.deleteDonationByIdTest Error');
        System.assert(msg.contains('DonationDao#deleteDonationById Done Successfully'), 'DonationDaoTest.deleteDonationByIdTest Error');
        Test.stopTest();
    }
}