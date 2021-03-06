@isTest
public with sharing class ShotenshaWorshipControllerTest {

    @testSetup
    static void setup() {

        // Creating household records
        List<Household__c> hList = new List<Household__c>();
        Household__c h1 = new Household__c(
            Name = '佐藤家',
            PostalCode__c = '1070052',
            Prefecture__c = '東京都',
            Municipalities__c = '港区',
            HouseNumber__c = '赤坂1-2-3'
        );
        Household__c h2 = new Household__c(
            Name = '後藤家',
            Prefecture__c = '東京都',
            PostalCode__c = '1100000',
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
                PersonNumCurrent__c = 5000 + i,
                CelestialWorshipShipment__c = '希望有',
                Birthday__c = Date.newInstance(1960, 12, i+1),
                Household__c = h1.Id
            );
            pList.add(p);
        }
        for (Integer i = 0; i < 7; i++) {
            Person__c p = new Person__c(
                Name = '後藤真紀子' + String.valueOf(i),
                PersonType__c = '現住陪餐会員',
                FamilyName__c = '後藤',
                ForeName__c = '真紀子' + i,
                FamilyNameFurigana__c = 'ごとう',
                ForeNameFurigana__c = 'まきこ' + String.valueOf(i),
                RelationshipFromHouseholder__c = '本人',
                DonationUnitClass__c = '個人',
                PersonNumCurrent__c = 5100 + i,
                CelestialWorshipShipment__c = '希望無',
                Birthday__c = Date.newInstance(1961, 12, i+1),
                Household__c = h2.Id
            );
            pList.add(p);
        }
        insert pList;

        // Creating a record of dead people

        // [佐藤家/佐藤一郎3]当年度に召天
        Person__c pDeceased3 = pList[3];
        pDeceased3.Deceased__c = true;
        pDeceased3.DeceasedDate__c = Date.newInstance(2022, 10, 1);
        pDeceased3.BoneDate__c = Date.newInstance(2022, 10, 1);
        pDeceased3.Remains__c = '有';
        pDeceased3.MainBoneType__c = '本骨';
        pDeceased3.OfficiantPastorName__c = 'その他';

        // [佐藤家/佐藤一郎4]1年前に召天
        Person__c pDeceased4 = pList[4];
        pDeceased4.Deceased__c = true;
        pDeceased4.DeceasedDate__c = Date.newInstance(2021, 10, 1);
        pDeceased4.BoneDate__c = Date.newInstance(2021, 10, 1);
        pDeceased4.Remains__c = '有';
        pDeceased4.MainBoneType__c = '本骨';
        pDeceased4.OfficiantPastorName__c = 'その他';

        // [佐藤家/佐藤一郎5]5年前に召天
        Person__c pDeceased5 = pList[5];
        pDeceased5.Deceased__c = true;
        pDeceased5.DeceasedDate__c = Date.newInstance(2017, 12, 1);
        pDeceased5.BoneDate__c = Date.newInstance(2017, 12, 1);
        pDeceased5.Remains__c = '無';
        pDeceased5.MainBoneType__c = '本骨';
        pDeceased5.OfficiantPastorName__c = 'その他';

        // [後藤家/後藤真紀子3]10年前に召天
        Person__c pDeceased9 = pList[9];
        pDeceased9.Deceased__c = true;
        pDeceased9.DeceasedDate__c = Date.newInstance(2012, 12, 1);
        pDeceased9.BoneDate__c = Date.newInstance(2012, 12, 1);
        pDeceased9.Remains__c = '有';
        pDeceased9.MainBoneType__c = '本骨';
        pDeceased9.OfficiantPastorName__c = 'その他';

        // [後藤家/後藤真紀子4]15年前に召天
        Person__c pDeceased10 = pList[10];
        pDeceased10.Deceased__c = true;
        pDeceased10.DeceasedDate__c = Date.newInstance(2007, 12, 1);
        pDeceased10.BoneDate__c = Date.newInstance(2007, 12, 1);
        pDeceased10.Remains__c = '有';
        pDeceased10.MainBoneType__c = '本骨';
        pDeceased10.OfficiantPastorName__c = 'その他';

        // [後藤家/後藤真紀子5]20年前に召天
        Person__c pDeceased11 = pList[11];
        pDeceased11.Deceased__c = true;
        pDeceased11.DeceasedDate__c = Date.newInstance(2002, 12, 1);
        pDeceased11.BoneDate__c = Date.newInstance(2002, 12, 1);
        pDeceased11.Remains__c = '無';
        pDeceased11.MainBoneType__c = '本骨';
        pDeceased11.OfficiantPastorName__c = 'その他';

        // [後藤家/後藤真紀子6]25年前に召天
        Person__c pDeceased12 = pList[12];
        pDeceased12.Deceased__c = true;
        pDeceased12.DeceasedDate__c = Date.newInstance(1997, 12, 1);
        pDeceased12.BoneDate__c = Date.newInstance(1997, 12, 1);
        pDeceased12.Remains__c = '無';
        pDeceased12.MainBoneType__c = '本骨';
        pDeceased12.OfficiantPastorName__c = 'その他';
        
        update pList;

        // Creating DeceasedSurvivor Object Records
        List<DeceasedSurvivor__c> dList = new List<DeceasedSurvivor__c>();

        for (Integer i = 3; i < 6; i++) {
            Person__c pDeceased = pList[i];
            for (Integer j = 0; j < 3; j++) {
                DeceasedSurvivor__c d = new DeceasedSurvivor__c(
                    DeceasedPerson__c = pDeceased.Id,
                    SurvivorPerson__c = pList[j].Id
                );
                dList.add(d);
            }
        }

        for (Integer i = 9; i < 13; i++) {
            Person__c pDeceased = pList[i];
            for (Integer j = 6; j < 9; j++) {
                DeceasedSurvivor__c d = new DeceasedSurvivor__c(
                    DeceasedPerson__c = pDeceased.Id,
                    SurvivorPerson__c = pList[j].Id
                );
                dList.add(d);
            }
        }

        insert dList;
    }

    @isTest
    static void getSurvivorHouseholdListTest() {
        List<Date> dateList = setDateList();

        List<Map<String, Object>> dList = ShotenshaWorshipController.getSurvivorHouseholdList(dateList, true);

        Test.startTest();
        System.assertEquals(2, dList.size(), 'ShotenshaWorshipController.getSurvivorHouseholdList Error');
        System.assertEquals('佐藤家,1070052,東京都港区赤坂1-2-3,佐藤一郎5,,,,佐藤一郎3,当年,佐藤一郎4,1年,佐藤一郎5,5年', String.join(dList[0].values(), ','), 'ShotenshaWorshipController.getSurvivorHouseholdList Error');
        System.assertEquals('後藤家,1100000,東京都台東区浅草1-2-3,後藤真紀子6,,,,後藤真紀子3,10年,後藤真紀子4,15年,後藤真紀子5,20年,後藤真紀子6,25年', String.join(dList[1].values(), ','), 'ShotenshaWorshipController.getSurvivorHouseholdList Error');
        Test.stopTest();
    }

    @isTest
    static void createAtenaCsvDataTest() {
        List<Date> dateList = setDateList();

        List<Map<String, Object>> dList = ShotenshaWorshipController.getSurvivorHouseholdList(dateList, true);

        ShotenshaWorshipController.createAtenaCsvData();
        List<String> csvList = ShotenshaWorshipController.csvData.split('\r\n');

        Test.startTest();
        System.assertEquals('世帯名,郵便番号,住所,世帯主名,連名1,連名2,連名3,召天者名1,召天年1,召天者名2,召天年2,召天者名3,召天年3,召天者名4,召天年4,召天者名5,召天年5,召天者名6,召天年6,召天者名7,召天年7,召天者名8,召天年8,召天者名9,召天年9,召天者名10,召天年10', csvList[0], 'ShotenshaWorshipController.createAtenaCsvData Error');
        System.assertEquals('佐藤家,1070052,東京都港区赤坂1-2-3,佐藤一郎5,,,,佐藤一郎3,当年,佐藤一郎4,1年,佐藤一郎5,5年', csvList[1], 'ShotenshaWorshipController.createAtenaCsvData Error');
        System.assertEquals('後藤家,1100000,東京都台東区浅草1-2-3,後藤真紀子6,,,,後藤真紀子3,10年,後藤真紀子4,15年,後藤真紀子5,20年,後藤真紀子6,25年', csvList[2], 'ShotenshaWorshipController.createAtenaCsvData Error');
        Test.stopTest();
    }

    @isTest
    static void getDeceasedListTest() {
        List<Date> dateList = setDateList();

        List<Map<String, Object>> dList = ShotenshaWorshipController.getDeceasedList(dateList, true);

        Test.startTest();
        System.assertEquals(21, dList.size(), 'ShotenshaWorshipController.getDeceasedList Error');
        System.assertEquals('当年,現住陪餐会員,5003,佐藤一郎3,Sat Oct 01 00:00:00 GMT 2022,Sat Oct 01 00:00:00 GMT 2022,有,佐藤一郎0,5000,,希望有,1070052,東京都港区赤坂1-2-3', String.join(dList[0].values(), ','), 'ShotenshaWorshipController.getDeceasedList Error');
        System.assertEquals('当年,現住陪餐会員,5003,佐藤一郎3,Sat Oct 01 00:00:00 GMT 2022,Sat Oct 01 00:00:00 GMT 2022,有,佐藤一郎1,5001,,希望有,1070052,東京都港区赤坂1-2-3', String.join(dList[1].values(), ','), 'ShotenshaWorshipController.getDeceasedList Error');
        Test.stopTest();
    }

    @isTest
    static void createDeceasedListCsvDataTest() {
        List<Date> dateList = setDateList();
        List<Map<String, Object>> dList = ShotenshaWorshipController.getDeceasedList(dateList, true);

        ShotenshaWorshipController.createDeceasedListCsvData();
        List<String> csvList = ShotenshaWorshipController.csvData.split('\r\n');

        Test.startTest();
        System.assertEquals('召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無,遺族名,遺族原簿番号,遺族続柄,遺族召天案内,郵便番号,住所', csvList[0], 'ShotenshaWorshipController.createDeceasedListCsvData Error');
        System.assertEquals('不明,現住陪餐会員,5003,佐藤一郎3,2022-10-01,2022-10-01,有,佐藤一郎0,5000,,希望有,1070052,東京都港区赤坂1-2-3', csvList[1], 'ShotenshaWorshipController.createDeceasedListCsvData Error');
        System.assertEquals('不明,現住陪餐会員,5003,佐藤一郎3,2022-10-01,2022-10-01,有,佐藤一郎1,5001,,希望有,1070052,東京都港区赤坂1-2-3', csvList[2], 'ShotenshaWorshipController.createDeceasedListCsvData Error');
        Test.stopTest();
    }

    @isTest
    static void createSurvivorListCsvDataTest() {
        List<Date> dateList = setDateList();

        List<Map<String, Object>> dList = ShotenshaWorshipController.getSurvivorList(dateList, true);

        ShotenshaWorshipController.createSurvivorListCsvData();
        List<String> csvList = ShotenshaWorshipController.csvData.split('\r\n');

        Test.startTest();
        System.assertEquals('遺族原簿番号,遺族名,遺族会員区分,郵便番号,住所,遺族続柄,遺族召天案内,召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無', csvList[0], 'ShotenshaWorshipController.createSurvivorListCsvData Error');
        System.assertEquals('5000,佐藤一郎0,現住陪餐会員,1070052,東京都港区赤坂1-2-3,,希望有,不明,現住陪餐会員,5003,佐藤一郎3,2022-10-01,2022-10-01,有', csvList[1], 'ShotenshaWorshipController.createSurvivorListCsvData Error');
        System.assertEquals('5000,佐藤一郎0,現住陪餐会員,1070052,東京都港区赤坂1-2-3,,希望有,不明,現住陪餐会員,5005,佐藤一郎5,2017-12-01,2017-12-01,無', csvList[2], 'ShotenshaWorshipController.createSurvivorListCsvData Error');
        Test.stopTest();
    }

    public static List<Date> setDateList(){
        List<Date> dateList = new List<Date>();

        // 0, 1年目のDateは日付が特殊なので下記For文とは別に作成
        dateList.add(Date.newInstance(2021, 11, 1));
        dateList.add(Date.newInstance(2022, 10, 31));
        dateList.add(Date.newInstance(2020, 11, 1));
        dateList.add(Date.newInstance(2021, 10, 31));

        // 5年目から200年目まで5年刻みでDateを作成する
        // ex: 2017, 2012, 2007, ... , 1827, 1822]
        for(Integer i = 5 ; i <= 200; i = i + 5) {
            Integer year = 2022 - i;
            dateList.add(Date.newInstance(year, 1, 1));
            dateList.add(Date.newInstance(year, 12, 31));
        }

        return dateList;
    }
}