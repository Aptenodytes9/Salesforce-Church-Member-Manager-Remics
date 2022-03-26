@isTest
public with sharing class ShuhoDataPrintUtilTest {

    @testSetup
    static void setup() {

        // Creating household records
        List<Household__c> hList = new List<Household__c>();
        Household__c h1 = new Household__c(
            Name = '佐藤家',
            Prefecture__c = '東京都',
            Municipalities__c = '港区',
            HouseNumber__c = '赤坂1-2-3'
        );
        Household__c h2 = new Household__c(
            Name = '後藤家',
            Prefecture__c = '東京都',
            Municipalities__c = '台東区',
            HouseNumber__c = '浅草1-2-3'
        );
        hList.add(h1);
        hList.add(h2);
        insert hList;

        // Creating person records (member of the church)
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
                DonationUnitClass__c = '個人',
                Household__c = h1.Id
            );
            pList.add(p);
        }
        insert pList;

        // Creating person records (Donation unit  = "Couple")
        Person__c pHusband = pList[1];
        Person__c pWife = pList[2];

        pHusband.Name = '佐藤夫1';
        pHusband.ForeName__c = '夫1';
        pHusband.DonationUnitClass__c = '夫婦';
        pHusband.Spouse__c = pWife.Id;

        pWife.Name = '佐藤妻2';
        pWife.ForeName__c = '妻2';
        pWife.DonationUnitClass__c = '夫婦';
        pWife.Spouse__c = pHusband.Id;
        pWife.RelationshipFromHouseholder__c = '配偶者';

        // Creating person records (Donation unit  = "Family")
        Person__c pFather = pList[3];
        Person__c pSon = pList[4];

        pFather.Name = '後藤父3';
        pFather.ForeName__c = '父3';
        pFather.DonationUnitClass__c = '家族';
        pFather.Household__c = h2.Id;

        pSon.Name = '後藤息子4';
        pSon.ForeName__c = '息子4';
        pSon.DonationUnitClass__c = '家族';
        pSon.Household__c = h2.Id;
        pSon.RelationshipFromHouseholder__c = '子';

        // Creating person records (Membership category = "Non-member")
        Person__c pHikaiin = pList[5];
        pHikaiin.PersonType__c = '非会員';
        
        update pList;

        List<Donation__c> dList = new List<Donation__c>();
        
        // Creating onation records
        for(Person__c p : pList){
            // If the donation unit = "couple" or "Family", the spouse or family does not make a donation alone, so it is excluded.
            if(p.Id == pWife.Id || p.Id == pSon.Id){
                continue;
            }

            Donation__c dGetsuji = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 1),
                DonationStartDate__c = Date.newInstance(2022, 12, 1),
                DonationFinishDate__c = Date.newInstance(2023, 1, 31),
                Donor__c = p.Id,
                DonationAmount__c = 10000,
                DonationType__c = '1'
            );
            Donation__c dToki = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 15),
                Donor__c = p.Id,
                DonationAmount__c = 20000,
                DonationType__c = '3',
                DonationNote__c = '感謝'
            );
            Donation__c dAsa = new Donation__c(
                DonationDate__c = Date.newInstance(2022, 12, 31),
                Donor__c = p.Id,
                DonationAmount__c = 30000,
                DonationType__c = '19'
            );
            dList.add(dGetsuji);
            dList.add(dToki);
            dList.add(dAsa);
        }
        insert dList;
    }

    @isTest
    static void getDonationsByDateAggregateTest() {
        Date dateFrom = Date.newInstance(2022, 12, 1);
        Date dateTo = Date.newInstance(2022, 12, 31);
        String actualStr = ShuhoDataPrintUtil.getShuhoData(dateFrom, dateTo);
        String expectedStr = '◇<b>月次献金</b>　佐藤一郎0、佐藤夫1・妻2、佐藤父3・息子4（以上12〜1月分）<br/>◇<b>冬季特別献金</b>　佐藤一郎0（感謝）、佐藤夫1・妻2（感謝）、佐藤父3・息子4（感謝）<br/>◇<b>夕礼拝</b>　佐藤一郎0、佐藤夫1・妻2、佐藤父3・息子4';

        Test.startTest();
        System.assertEquals(expectedStr, actualStr, 'ShuhoDataPrintUtilTest.getDonationsByDateAggregate Error');
        Test.stopTest();
    }
}