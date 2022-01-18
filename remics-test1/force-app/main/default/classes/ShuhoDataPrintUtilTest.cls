@isTest
public with sharing class ShuhoDataPrintUtilTest {

    @testSetup
    static void setup() {

        // 世帯レコードの作成
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
                DonationUnitClass__c = '個人',
                Household__c = h1.Id
            );
            pList.add(p);
        }
        insert pList;

        // 献金単位区分=「夫婦」の人レコードの作成
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

        // 献金単位区分=「家族」の人レコードの作成
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

        // 会員区分=「非会員」の人レコードの作成
        Person__c pHikaiin = pList[5];
        pHikaiin.PersonType__c = '非会員';
        
        update pList;

        List<Donation__c> dList = new List<Donation__c>();
        
        // 献金レコードの作成
        for(Person__c p : pList){
            // 献金単位区分=「夫婦」の場合の配偶者や、献金単位区分=「家族」の場合の家族は
            // 単独で献金するケースはないので除外する
            if(p.Id == pWife.Id || p.Id == pSon.Id){
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
        String expectedStr = '◇月次献金　佐藤一郎0、佐藤夫1・妻2、佐藤父3・息子4<br/>◇冬季特別献金　佐藤一郎0（感謝）、佐藤夫1・妻2（感謝）、佐藤父3・息子4（感謝）<br/>◇朝礼拝　佐藤一郎0、佐藤夫1・妻2、佐藤父3・息子4';

        Test.startTest();
        System.assertEquals(expectedStr, actualStr, 'ShuhoDataPrintUtilTest.getDonationsByDateAggregate Error');
        Test.stopTest();
    }
}