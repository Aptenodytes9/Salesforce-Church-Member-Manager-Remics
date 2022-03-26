@isTest
public with sharing class PersonDaoTest {

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

        // Members who do not do monthly donations at all
        // Until last year, it is set to be qualified
        Person__c pNoDonation = pList[4];
        pNoDonation.ParliamentaryQualification__c = true;

        // Members who have not made monthly donations within the specified period
        // Until last year, it is set to be qualified
        Person__c pNoDonationWhileTerm = pList[5];
        pNoDonationWhileTerm.ParliamentaryQualification__c = true;
        
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
                DonationType__c = '18'
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

    @isTest
    static void getPersonByPersonNumCurrentTest() {
        Person__c p1 = PersonDao.getPersonByPersonNumCurrent(5000);
        Person__c p2 = PersonDao.getPersonById(p1.Id);

        Test.startTest();
        System.assertEquals('佐藤一郎0', p1.Name, 'PersonDao.getPersonByPersonNumCurrent Error');
        System.assertEquals(5000, p1.PersonNumCurrent__c, 'PersonDao.getPersonByPersonNumCurrent Error');
        
        System.assertEquals('佐藤一郎0', p2.Name, 'PersonDao.getPersonById Error');
        System.assertEquals(5000, p2.PersonNumCurrent__c, 'PersonDao.getPersonById Error');
        Test.stopTest();
    }
}