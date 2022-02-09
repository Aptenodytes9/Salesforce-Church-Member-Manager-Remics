public with sharing class JornalExportController {

    public static String csvData { get; set; }

    // 仕訳CSVデータを作成
    public static void createCsvData(Boolean isKaikei) {

        // 最後にユーザーが検索した検索日付をカスタム設定から取得
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        Date donationDateFrom = je.donationDateFrom__c;
        Date donationDateTo = je.donationDateTo__c;

        // CSVデータのもととなるデータを取得
        List<Map<String, Object>> jornalKaikeiList = getJornalList(donationDateFrom, donationDateTo, isKaikei, false);

        List<String> rowList = new List<String>();

        // データ行を作成
        for(Map<String, Object> shMap : jornalKaikeiList) {
            rowList.add(String.join(shMap.values(), ','));
        }

        // １行ごとに改行を付与
        csvData = String.join(rowList, '\r\n');
        // 最終行にも改行を付加する
        csvData += '\r\n';
    }

    // 仕訳データ「KAIKEI_IF」一覧 CSVデータを作成
    public static void createKaikeiCsvData() {
        createCsvData(true);
    }

    // 仕訳データ「SIEN_IF」一覧 CSVデータを作成
    public static void createSienCsvData() {
        createCsvData(false);
    }

    // 献金データを献金種類単位で出力する
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
                // CSV出力する場合は、値を引用符で囲う
                m.put('DonationDate', '"' + donationDateStr + '"');
                m.put('DateNo', '"' + dateNoStr + '"');
                m.put('No', '"' + 1 + '"');
                m.put('DebitCode', '"' + data.get('DebitCode') + '"');
                m.put('CreditCode', '"' + data.get('CreditCode') + '"');
                m.put('DonationAmountSum', '"' + Integer.valueOf(data.get('DonationAmountSum')) + '"');
                m.put('DonationNote', '"' + donationNoteStr + '"');
            }

            // 例： 2022/01/02 15001 1 1101 4101 405500 月次献金43口
            dataList.add(m);
        }

        return dataList;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getLastExportCondition(){
        Map<String, Object> dMap = new Map<String, Object>();

        // 最後にユーザーがエクスポートした日時をカスタム設定から取得
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        dMap.put('lastExportDatetime', je.lastExportDatetime__c);
        dMap.put('donationDateFrom', je.donationDateFrom__c);
        dMap.put('donationDateTo', je.donationDateTo__c);
        dMap.put('donationDateToTomorrow', je.donationDateTo__c.addDays(1));
        return dMap;
    }

    @AuraEnabled(cacheable=false)
    public static void updateLastExportDatetime(Date donationDateFrom, Date donationDateTo){
        // 最後にユーザーがエクスポートした日時とその時の検索日付をカスタム設定に保存
        JornalExport__c je = JornalExport__c.getOrgDefaults();
        je.lastExportDatetime__c = Datetime.now();
        je.donationDateFrom__c = donationDateFrom;
        je.donationDateTo__c = donationDateTo;

        upsert je;
    }
}