public with sharing class DuplicateDonationUtil {
    public static String createDonationYearMonth(Donation__c d){
        if(d == null || d.DonationStartDate__c == null || d.DonationFinishDate__c == null){
            return '';
        }

        List<String> donationYearMonthList = new List<String>();

        Date startDate = d.DonationStartDate__c;
        Date finishDate = d.DonationFinishDate__c;
        while(startDate.daysBetween(finishDate) >= 0){
            String str = String.valueOf(startDate.year()) + '年' + String.valueOf(startDate.month()) + '月';
            donationYearMonthList.add(str);
            startDate = startDate.addMonths(1);
        }
        return String.join(donationYearMonthList, ',');
    }

    public static List<Donation__c> getDuplicateDonation(Donation__c d){
        List<Donation__c> duplicateDList = new List<Donation__c>();
        if(d == null || String.isEmpty(d.DonationYearMonth__c) || !'1'.equals(d.DonationType__c)){
            return duplicateDList;
        }

        List<String> yearMonthList = d.DonationYearMonth__c.split(',');
        List<Donation__c> sameDonorsMonthlyDList = DonationDao.getMonthlyDonationsByDonorId(d.Donor__c, d.Id);

        System.debug('sameDonorsMonthlyDList size: ' + sameDonorsMonthlyDList.size());

        for(Donation__c sameMonthlyDonation : sameDonorsMonthlyDList) {
            System.debug('sameMonthlyDonation Name: ' + sameMonthlyDonation.name);
            System.debug('sameMonthlyDonation DonationYearMonth: ' + sameMonthlyDonation.DonationYearMonth__c);

            String sameDYearMonth = sameMonthlyDonation.DonationYearMonth__c;
            if(sameDYearMonth == null || String.isEmpty(sameDYearMonth)){
                continue;
            }

            for(String targetYearMonth : yearMonthList){
                System.debug('targetYearMonth: ' + targetYearMonth);

                if(sameDYearMonth.contains(targetYearMonth)){
                    System.debug('contain');
                    duplicateDList.add(sameMonthlyDonation);
                    break;
                }
            }
        }

        System.debug('duplicateDList size: ' + duplicateDList.size());
        return duplicateDList;
    }
}
