public with sharing class ShuhoDataPrintUtil {

/*
    A class that outputs a txt list of church members who donated in the specified week.
    This is used for weekly manuscripts.
    The text format is as follows.

    ┌───────────────────　format　─────────────────────┐
    ｜◇{Donation type}　{Donor 1}、{Donor 2}、....　　　 ｜
    └──────────────────────────────────────────────────┘
    ┌──────────────────　Example　─────────────────────┐
    ｜◇月次献金　佐藤麻衣子、山田大地（以上1月分）　 　　　　　　｜
    ｜　佐藤正雄、佐藤一郎（以上１〜３月分） 　　　　　　　　　　｜
    ｜　山田恵（２〜３月分）　　　　　　 　　　　　　　　　　　　｜
    ｜◇式典献金　佐藤麻衣子　　　　　　　　　　　　　　　　　　　｜
    ｜◇クリスマス献金　山田大地　　　　　　　　　　　　　　　　　｜
    ｜◇その他感謝献金　山田大地（会場利用）　　　　　　　　　　　｜
    └──────────────────────────────────────────────────┘

    [Specifications]
    -  Output targets for donation records that meet all of the following conditions（cf: DonationDao#getDonationsByDateAggregate）
        -  Delivery date is included in the search period
        -  "Main / sub donation" = "main donation"
        -  Membership classification of donors = "current communion members" and "communion members"
    -  Enter the donor name for each type of donation
    -  If a value is registered in the "donor spouse name" or "donor family name" of the donation record, enter it in succession with a midpoint (・) in between.
    -  If the value is registered in the "Summary" column of the donation record, enter it in parentheses after the donor name.
    -  Only for monthly donations
        -  Following the donation type, further classify by "donation month" of the donation record
        -  The donation month is written in parentheses after the donor's name.
        -  If there is only one donor in the month of the donation, enter "or more" in parentheses.
*/

    // Map of "donation type" (key: choice API reference name, value: choice display label)
    private static Map<String, String> donaitonTypeMap = new Map<String, String>();

    //"Donations type" option's API name List
    private static List<String> donationTypeList = new List<String>();

    /* 
        Map that stores the list of donor names by donation type
        key:"Donations type" option's API name List
        value: Set of donor names who made that type of donation
    */
    private static Map<String, Set<String>> dTypeDonorSetMap = new Map<String, Set<String>>();

    // Initialization
    static {
        Schema.DescribeFieldResult o = Donation__c.DonationType__c.getDescribe();
        List<Schema.PicklistEntry> v = o.getPicklistValues();
        for(Schema.PicklistEntry s : v){
            if(s.isActive()){
                donaitonTypeMap.put(s.getValue(), s.getLabel());
                donationTypeList.add(s.getValue());
            }
        }

        for(String dType : donationTypeList){
            dTypeDonorSetMap.put(dType, new Set<String>());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getShuhoData(Date donationDateFrom, Date donationDateTo){
        // Get a list of donations paid during the search period
        List<AggregateResult> dList = DonationDao.getDonationsByDateAggregate(donationDateFrom, donationDateTo);

        // [Monthly donation only] Donor info storage map
        // key: Monthly donation month name（ex：『１〜３月分』）
        // value: Donor Name List（ex：『佐藤麻衣子、山田大地、佐藤正雄、…』）
        Map<String, List<String>> monthDonationMap = new Map<String, List<String>>();

        // Obtain the donor name and store it in the List by donation type
        for (AggregateResult d : dList) {
            String dType = String.valueOf(d.get('DonationType__c'));
            Set<String> donorSet = dTypeDonorSetMap.get(dType);

            String donorNameStr = String.valueOf(d.get('DonorName'));
            String donationSpouseName = String.valueOf(d.get('DonationSpouseName'));
            String donationFamilyName = String.valueOf(d.get('DonationFamilyName'));
            String donationNote = String.valueOf(d.get('DonationNote'));

            // Combine donor name, donor spouse name, donor family name, and summary（ex：『佐藤健志・正雄・麻衣子』）
            if(!String.isEmpty(donationSpouseName)){
                donorNameStr += '・' + donationSpouseName;
            } else if (!String.isEmpty(donationFamilyName)) {
                donorNameStr += '・' + donationFamilyName;
            }
            if(!String.isEmpty(donationNote) && !'1'.equals(dType)){
                // Concatenate the "Summary" in parentheses (for monthly donations, skip because the month name is written in parentheses)
                donorNameStr += '（' + donationNote + '）';
            }

            // For Monthly donations
            if('1'.equals(dType)){
                String month = String.valueOf(d.get('DonationMonthStr__c'));
                if(monthDonationMap.containsKey(month)){
                    List<String> monthDonorList = monthDonationMap.get(month);
                    monthDonorList.add(donorNameStr);
                } else {
                    List<String> monthDonorList = new List<String>();
                    monthDonorList.add(donorNameStr);
                    monthDonationMap.put(month, monthDonorList);
                }
            } else {
                donorSet.add(donorNameStr);
            }
        }

        List<String> dTypeAndDonorList = new List<String>();

        for(String dType : donationTypeList){
            String allDonorsStr;

            if('1'.equals(dType)){
                if (monthDonationMap.keySet().isEmpty()) {
                    // Skip if the donor does not exist
                    continue;
                }

                List<String> donorAndMonthList = new List<String>();

                for(String month : monthDonationMap.keySet()){
                    List<String> monthDonorList = monthDonationMap.get(month);
                    String monthDonorsStr = String.join(monthDonorList, '、');
                    String connector = monthDonorList.size() == 1 ? '（' : '（以上';

                    // Generates a string of donation month names and all donor names
                    // ex：『佐藤正雄、佐藤一郎（以上１〜３月分）』
                    String donorAndMonth = monthDonorsStr + connector + month + '）';
                    donorAndMonthList.add(donorAndMonth);
                }

                allDonorsStr = String.join(donorAndMonthList, '</br>　');
            } else {
                Set<String> donorSet = dTypeDonorSetMap.get(dType);
                if (donorSet.isEmpty()) {
                    // Skip if the donor does not exist
                    continue;
                }
                // Combine all donor names
                List<String> donorList = new List<String>(donorSet);
                allDonorsStr = String.join(donorList, '、');
            }

            // Create bullet
            String dTypeStr = '◇' + '<b>' + donaitonTypeMap.get(dType) + '</b>';

            // Combine bullets and all donor names
            // ex：『◇月次献金　佐藤麻衣子、山田大地、佐藤正雄（以上１〜３月分）』
            String dTypeAndDonorStr = dTypeStr + '　' + allDonorsStr;

            dTypeAndDonorList.add(dTypeAndDonorStr);
        }

        String result = String.join(dTypeAndDonorList, '<br/>');
        return result;
    }
}