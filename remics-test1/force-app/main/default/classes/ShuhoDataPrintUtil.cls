public with sharing class ShuhoDataPrintUtil {

/* 指定された週に献金した教会員の一覧をテキスト出力するクラス
週報の原稿に使用する
テキストのフォーマットは下記の通り

 ┌────────────────　フォーマット　─────────────────────┐
 ｜◇{献金種類}　{献金者1}、{献金者2}、....　　　　　　　　　｜
 └──────────────────────────────────────────────────┘
 ┌────────────────────　例　─────────────────────────┐
 ｜◇月次献金　佐藤麻衣子、山田大地、佐藤正雄、佐藤一郎、山田恵｜
 ｜◇式典献金　佐藤麻衣子　　　　　　　　　　　　　　　　　　　｜
 ｜◇クリスマス献金　山田大地　　　　　　　　　　　　　　　　　｜
 └──────────────────────────────────────────────────┘

 */
    @AuraEnabled(cacheable=true)
    public static String getShuhoData(Date donationDateFrom, Date donationDateTo){
        // 検索期間に納入された献金一覧を取得
        List<AggregateResult> dList = DonationDao.getDonationsByDateAggregate(donationDateFrom, donationDateTo);

        // 献金オブジェクト「献金種類」の選択リストを取得
        List<String> dTypeList = getDonationTypeList();
        Map<String, List<String>> dTypeMap = getDonationTypeMap(dTypeList);

        // 献金者名を取得して献金種類別にListに格納
        for (AggregateResult d : dList) {
            String donorType = String.valueOf(d.get('DonationType__c'));
            List<String> donorList = dTypeMap.get(donorType);

            String donorNameStr = String.valueOf(d.get('DonorName'));
            String donationSpouseName = String.valueOf(d.get('DonationSpouseName'));
            String donationFamilyName = String.valueOf(d.get('DonationFamilyName'));
            String donationNote = String.valueOf(d.get('DonationNote'));

            if(!String.isEmpty(donationSpouseName)){
                donorNameStr += '・' + donationSpouseName;
            } else if (!String.isEmpty(donationFamilyName)) {
                donorNameStr += '・' + donationFamilyName;
            }
            if(!String.isEmpty(donationNote)){
                donorNameStr += '（' + donationNote + '）';
            }

            donorList.add(donorNameStr);
        }

        List<String> dTypeAndDonorList = new List<String>();

        for(String dType : dTypeList){
            List<String> donorList = dTypeMap.get(dType);
            if (donorList.isEmpty()) {
                // 献金者が存在しなかった献金種類はスキップする
                continue;
            }
            // すべての献金者名を結合
            String donorStr = String.join(donorList, '、');

            // 行頭文字を作成
            String dTypeStr = '◇' + dType;

            // 行頭文字+全献金者名を結合
            // 例：◇月次献金　佐藤麻衣子、山田大地、佐藤正雄
            String dTypeAndDonorStr = dTypeStr + '　' + donorStr;

            dTypeAndDonorList.add(dTypeAndDonorStr);
        }

        String result = String.join(dTypeAndDonorList, '<br/>');
        return result;
    }

    private static List<String> getDonationTypeList(){
        List<String> dTypeList = new List<String>();

        Schema.DescribeFieldResult o = Donation__c.DonationType__c.getDescribe();
        List<Schema.PicklistEntry> v = o.getPicklistValues();
        for(Schema.PicklistEntry s : v){
            if(s.isActive()){
                dTypeList.add(s.getLabel());
            }
        }

        return dTypeList;
    }
    private static Map<String, List<String>> getDonationTypeMap(List<String> dTypeList){
        Map<String, List<String>> dTypeMap = new Map<String, List<String>>();

        for(String dType : dTypeList){
            dTypeMap.put(dType, new List<String>());
        }

        return dTypeMap;
    }
}
