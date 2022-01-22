public with sharing class ShuhoDataPrintUtil {

/*
    指定された週に献金した教会員の一覧をテキスト出力するクラス
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

    // 「献金種類」項目のMap(key: 選択肢API参照名, value: 選択肢表示ラベル)
    private static Map<String, String> donaitonTypeMap = new Map<String, String>();

    //「献金種類」項目の選択肢API参照名List
    private static List<String> donationTypeList = new List<String>();

    /* 
        献金種類別の献金者名Listを格納するMap
        key:「献金種類」項目の選択肢のAPI参照名
        value: その種類の献金をした献金者名のList
    */
    private static Map<String, List<String>> dTypeDonorListMap = new Map<String, List<String>>();

    // 初期化コード
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
            dTypeDonorListMap.put(dType, new List<String>());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getShuhoData(Date donationDateFrom, Date donationDateTo){
        // 検索期間に納入された献金一覧を取得
        List<AggregateResult> dList = DonationDao.getDonationsByDateAggregate(donationDateFrom, donationDateTo);

        // 献金者名を取得して献金種類別にListに格納
        for (AggregateResult d : dList) {
            String dType = String.valueOf(d.get('DonationType__c'));
            List<String> donorList = dTypeDonorListMap.get(dType);

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

            // 献金者名・献金者配偶者名・献金者家族名・摘要を結合してListに格納
            donorList.add(donorNameStr);
        }

        List<String> dTypeAndDonorList = new List<String>();

        for(String dType : donationTypeList){
            List<String> donorList = dTypeDonorListMap.get(dType);
            if (donorList.isEmpty()) {
                // 献金者が存在しなかった献金種類はスキップする
                continue;
            }
            // すべての献金者名を結合
            String donorStr = String.join(donorList, '、');

            // 行頭文字を作成
            String dTypeStr = '◇' + donaitonTypeMap.get(dType);

            // 行頭文字+全献金者名を結合
            // 例：◇月次献金　佐藤麻衣子、山田大地、佐藤正雄
            String dTypeAndDonorStr = dTypeStr + '　' + donorStr;

            dTypeAndDonorList.add(dTypeAndDonorStr);
        }

        String result = String.join(dTypeAndDonorList, '<br/>');
        return result;
    }
}