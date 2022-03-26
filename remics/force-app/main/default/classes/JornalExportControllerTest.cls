@isTest
public with sharing class JornalExportControllerTest {

    @testSetup
    static void setup() {

        // Creating household records
        Household__c h = new Household__c(
            Name = '佐藤家',
            Prefecture__c = '東京都',
            Municipalities__c = '港区',
            HouseNumber__c = '赤坂1-2-3'
        );
        insert h;

        // Creating person records (member of the church)
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

        // Creating person records (Donation unit  = "Couple")
        Person__c pHusband = pList[1];
        Person__c pWife = pList[2];
        
        pHusband.DonationUnitClass__c = '夫婦';
        pHusband.Spouse__c = pWife.Id;

        pWife.Name = '佐藤妻子2';
        pWife.ForeName__c = '妻子2';
        pWife.DonationUnitClass__c = '夫婦';
        pWife.Spouse__c = pHusband.Id;
        pWife.RelationshipFromHouseholder__c = '配偶者';

        // Creating person records (Membership category = "Non-member")
        Person__c pHikaiin = pList[3];
        pHikaiin.PersonType__c = '非会員';
        
        update pList;

        List<Donation__c> dList = new List<Donation__c>();
        
        // Creating onation records
        for(Person__c p : pList){
            // If the donation unit = "couple", the spouse does not make a donation alone, so it is excluded.
            if(p.Id == pWife.Id){
                continue;
            }

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
                DonationStartDate__c = Date.newInstance(2022, 2, 1),
                DonationFinishDate__c = Date.newInstance(2023, 3, 31),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '1' // Monthly donations
            );
            Donation__c dToki = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '3', // Special winter donations
                DonationNote__c = '感謝'
            );
            Donation__c dToki2 = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 10000,
                DonationType__c = '3', // Special winter donations
                DonationNote__c = '感謝'
            );
            Donation__c dOnline = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 30000,
                DonationType__c = '18' // Online worship donations
            );
            Donation__c dDendo = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 40000,
                DonationType__c = '20' // Evangelism support donations
            );
            Donation__c dKaido = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 50000,
                DonationType__c = '31' // Hall Conservation Donation
            );
            Donation__c dIntai = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 60000,
                DonationType__c = '33' // Retirement teacher thank-you donation
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
    static void getJornalListTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Map<String, Object>> dListForView = JornalExportController.getJornalList(dateFrom, dateTo, true, true);
        List<Map<String, Object>> dListForCsv = JornalExportController.getJornalList(dateFrom, dateTo, true, false);

        Test.startTest();
        System.assertEquals(3, dListForView.size(), 'JornalExportController.getDonationsByDonorIdTest Error');
        System.assertEquals('2022/12/01,125001,1,1101,4101,90000,月次献金6口', String.join(dListForView[0].values(), ','), 'JornalExportController.getDonationsByDonorIdTest Error');

        System.assertEquals(3, dListForCsv.size(), 'JornalExportController.getDonationsByDonorIdTest Error');
        System.assertEquals('"2022/12/01","125001","1","1101","4101","90000","月次献金6口"', String.join(dListForCsv[0].values(), ','), 'JornalExportController.getDonationsByDonorIdTest Error');
        Test.stopTest();
    }

    @isTest
    static void createKaikeiCsvDataTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Map<String, Object>> dList = JornalExportController.getJornalList(dateFrom, dateTo, true, true);

        JornalExportController.createKaikeiCsvData();
        JornalExportController.updateLastExportDatetime(dateFrom, dateTo);
        List<String> csvList = JornalExportController.csvData.split('\r\n');

        Test.startTest();
        System.assertEquals('"2022/12/01","125001","1","1101","4101","90000","月次献金6口"', csvList[0], 'JornalExportController.createCsvData Error');
        System.assertEquals('"2022/12/15","125002","1","1101","4104","90000","冬季特別献金6口"', csvList[1], 'JornalExportController.createCsvData Error');
        Test.stopTest();
    }

    @isTest
    static void createSienCsvDataTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Map<String, Object>> dList = JornalExportController.getJornalList(dateFrom, dateTo, true, true);

        JornalExportController.createSienCsvData();
        JornalExportController.updateLastExportDatetime(dateFrom, dateTo);
        List<String> csvList = JornalExportController.csvData.split('\r\n');

        Test.startTest();
        System.assertEquals('"2022/12/31","125001","1","1101","4101","120000","伝道支援献金3口"', csvList[0], 'JornalExportController.createCsvData Error');
        System.assertEquals('"2022/12/31","125002","1","1101","4102","150000","会堂保全献金3口"', csvList[1], 'JornalExportController.createCsvData Error');
        Test.stopTest();
    }

    @isTest
    static void getLastExportConditionTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Map<String, Object>> dList = JornalExportController.getJornalList(dateFrom, dateTo, true, true);

        JornalExportController.createSienCsvData();
        JornalExportController.updateLastExportDatetime(dateFrom, dateTo);
        Map<String, Object> dMap = JornalExportController.getLastExportCondition();

        Test.startTest();
        System.assertEquals('2022-12-01 00:00:00', String.valueOf(dMap.get('donationDateFrom')), 'JornalExportController.createCsvData Error');
        System.assertEquals('2022-12-31 00:00:00', String.valueOf(dMap.get('donationDateTo')), 'JornalExportController.createCsvData Error');
        Test.stopTest();
    }
}