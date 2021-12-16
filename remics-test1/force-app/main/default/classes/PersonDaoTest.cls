@isTest
public with sharing class PersonDaoTest {

    @testSetup
    static void setup() {

        // 人レコード(教会員)の作成
        List<Person__c> pList = new List<Person__c>();
        for (Integer i = 0; i < 6; i++) {
            Person__c p = new Person__c(
                Name = '佐藤一郎' + String.valueOf(i),
                PersonType__c = '現住陪餐会員',
                FamilyName__c = '佐藤',
                ForeName__c = '一郎' + i,
                FamilyNameFurigana__c = 'さとう',
                ForeNameFurigana__c = 'いちろう' + String.valueOf(i),
                RelationshipFromHouseholder__c = '本人',
                DonationUnitClass__c = '個人'
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

        // 月次献金を全くしていない会員
        // 昨年までは総会議員資格ありの設定とする（「総会議員資格あり」= True）
        Person__c pNoDonation = pList[4];
        pNoDonation.ParliamentaryQualification__c = true;

        // 指定期間内に月次献金をしていない会員
        // 昨年までは総会議員資格ありの設定とする（「総会議員資格あり」= True）
        Person__c pNoDonationWhileTerm = pList[5];
        pNoDonationWhileTerm.ParliamentaryQualification__c = true;
        
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
                DonationType__c = '月次献金'
            );
            Donation__c dToki = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '冬季特別献金',
                DonationNote__c = '感謝'
            );
            Donation__c dAsa = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 30000,
                DonationType__c = '朝礼拝'
            );

            if(p.Id == pNoDonationWhileTerm.Id){
                dGetsuji.DonationDate__c = Date.newInstance(2022, 1, 1);
            }

            if(p.Id != pNoDonation.Id){
                dList.add(dGetsuji);
            }
            dList.add(dToki);
            dList.add(dAsa);
        }
        insert dList;
    }

    @isTest
    static void getQualifiedDonorsByDateTest() {
        Date dateFrom = Date.newInstance(2022, 6, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Person__c> pList = PersonDao.getQualifiedDonorsByDate(dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(3, pList.size(), 'PersonDao.getQualifiedDonorsByDate Error');
        System.assertEquals('佐藤一郎0', pList[0].Name, 'PersonDao.getQualifiedDonorsByDate Error');
        System.assertEquals('佐藤一郎1', pList[1].Name, 'PersonDao.getQualifiedDonorsByDate Error');
        System.assertEquals('佐藤妻子2', pList[2].Name, 'PersonDao.getQualifiedDonorsByDate Error');
        Test.stopTest();
    }

    @isTest
    static void getUnqualifiedDonorsByDateTest() {
        Date dateFrom = Date.newInstance(2022, 6, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Person__c> pList = PersonDao.getUnqualifiedDonorsByDate(dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(2, pList.size(), 'PersonDao.getQualifiedDonorsByDate Error');
        System.assertEquals('佐藤一郎4', pList[0].Name, 'PersonDao.getQualifiedDonorsByDate Error');
        System.assertEquals('佐藤一郎5', pList[1].Name, 'PersonDao.getQualifiedDonorsByDate Error');
        Test.stopTest();
    }

    @isTest
    static void updatePersonsTest() {
        Date dateFrom = Date.newInstance(2022, 6, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        List<Person__c> pList = PersonDao.getQualifiedDonorsByDate(dateFrom, dateTo);

        pList[0].ParliamentaryQualification__c = true;
        PersonDao.updatePersons(pList);
        List<Person__c> newPList = PersonDao.getQualifiedDonorsByDate(dateFrom, dateTo);

        Test.startTest();
        System.assertEquals(3, newPList.size(), 'PersonDao.updatePersonsTest Size Error');
        System.assertEquals(true, newPList[0].ParliamentaryQualification__c, 'PersonDao.updatePersonsTest ParliamentaryQualification__c Error');
        System.assertEquals(false, newPList[1].ParliamentaryQualification__c, 'PersonDao.updatePersonsTest ParliamentaryQualification__c Error');
        Test.stopTest();
    }
}
