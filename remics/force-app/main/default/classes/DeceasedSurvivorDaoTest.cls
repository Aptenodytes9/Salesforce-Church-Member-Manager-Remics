@isTest
public with sharing class DeceasedSurvivorDaoTest {

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

        // 召天した人レコードの作成
        Person__c pDeceased = pList[3];
        pDeceased.Deceased__c = true;
        pDeceased.DeceasedDate__c = Date.newInstance(2020, 12, 1);
        
        update pList;

        // 召天者×遺族レコードの作成
        List<DeceasedSurvivor__c> dList = new List<DeceasedSurvivor__c>();

        for (Integer i = 0; i < 3; i++) {
            DeceasedSurvivor__c d = new DeceasedSurvivor__c(
                DeceasedPerson__c = pDeceased.Id,
                SurvivorPerson__c = pList[i].Id
            );
            dList.add(d);
        }

        insert dList;
    }

    @isTest
    static void getDeceasedSurvivorByDateOrderbyHouseholdTest() {
        List<Date> dateList = setDateList();

        List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyHousehold(dateList);

        Test.startTest();
        System.assertEquals(3, dList.size(), 'DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyHousehold Error');
        Test.stopTest();
    }

    @isTest
    static void getDeceasedSurvivorByDateOrderbyDeceasedDateTest() {
        List<Date> dateList = setDateList();

        List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyDeceasedDate(dateList);

        Test.startTest();
        System.assertEquals(3, dList.size(), 'DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyDeceasedDate Error');
        Test.stopTest();
    }

    @isTest
    static void getDeceasedSurvivorByDateOrderbyPostalcodeTest() {
        List<Date> dateList = setDateList();

        List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyPostalcode(dateList);

        Test.startTest();
        System.assertEquals(3, dList.size(), 'DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyPostalcode Error');
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