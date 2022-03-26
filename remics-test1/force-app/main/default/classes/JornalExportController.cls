public with sharing class JornalExportController {

    public static String csvData { get; set; }

    public static void createCsvData(Boolean isKaikei) {

        // Get the last search date the user searched from the custom settings
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        Date donationDateFrom = je.donationDateFrom__c;
        Date donationDateTo = je.donationDateTo__c;

        // Get the data that is the basis of CSV data
        List<Map<String, Object>> jornalKaikeiList = getJornalList(donationDateFrom, donationDateTo, isKaikei, false);

        List<String> rowList = new List<String>();

        // Create a row of data
        for(Map<String, Object> shMap : jornalKaikeiList) {
            rowList.add(String.join(shMap.values(), ','));
        }

        csvData = String.join(rowList, '\r\n');
        csvData += '\r\n';
    }

    public static void createKaikeiCsvData() {
        createCsvData(true);
    }

    public static void createSienCsvData() {
        createCsvData(false);
    }

    // Export donation data by donation type
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getJornalList(Date donationDateFrom, Date donationDateTo, Boolean isKaikei, Boolean isForView){

        List<AggregateResult> dList = DonationDao.getJornalKaikeiListAggregate(donationDateFrom, donationDateTo, isKaikei);

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
        Integer dateNoIndex = 5000;

        for (AggregateResult data : dList){
            Map<String, Object> m = new Map<String, Object>();
            dateNoIndex += 1;

            Date donationDate = Date.valueOf(data.get('DonationDate__c'));
            String donationDateStr = donationDate.format();
            String dateNoStr = String.valueOf(donationDate.month()).leftPad(2, '0') + String.valueOf(dateNoIndex);
            String donationNoteStr = String.valueOf(data.get('dTypeStr')) + String.valueOf(data.get('RecordNum')) + '口';

            if (isForView) {
                m.put('DonationDate', donationDateStr);
                m.put('DateNo', dateNoStr);
                m.put('No', 1);
                m.put('DebitCode', data.get('DebitCode'));
                m.put('CreditCode', data.get('CreditCode'));
                m.put('DonationAmountSum', Integer.valueOf(data.get('DonationAmountSum')));
                m.put('DonationNote', donationNoteStr);
            } else {
                // When outputting CSV, enclose the value in quotation marks.
                m.put('DonationDate', '"' + donationDateStr + '"');
                m.put('DateNo', '"' + dateNoStr + '"');
                m.put('No', '"' + 1 + '"');
                m.put('DebitCode', '"' + data.get('DebitCode') + '"');
                m.put('CreditCode', '"' + data.get('CreditCode') + '"');
                m.put('DonationAmountSum', '"' + Integer.valueOf(data.get('DonationAmountSum')) + '"');
                m.put('DonationNote', '"' + donationNoteStr + '"');
            }

            // Example: 2022/01/02 15001 1 1101 4101 405500 月次献金43口
            dataList.add(m);
        }

        return dataList;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getLastExportCondition(){
        Map<String, Object> dMap = new Map<String, Object>();

        // Get the date and time last exported by the user from the custom settings
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        dMap.put('lastExportDatetime', je.lastExportDatetime__c);
        dMap.put('donationDateFrom', je.donationDateFrom__c);
        dMap.put('donationDateTo', je.donationDateTo__c);
        dMap.put('donationDateToTomorrow', je.donationDateTo__c.addDays(1));
        return dMap;
    }

    @AuraEnabled(cacheable=false)
    public static void updateLastExportDatetime(Date donationDateFrom, Date donationDateTo){
        // Save last user exported date and time and search date at that time in custom settings
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        je.lastExportDatetime__c = Datetime.now();
        je.donationDateFrom__c = donationDateFrom;
        je.donationDateTo__c = donationDateTo;

        upsert je;
    }
}