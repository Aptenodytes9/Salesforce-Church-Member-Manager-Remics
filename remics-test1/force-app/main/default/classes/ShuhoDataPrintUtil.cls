public with sharing class ShuhoDataPrintUtil {

/*
    指定された週に献金した教会員の一覧をテキスト出力するクラス
    週報の原稿に使用する
    テキストのフォーマットは下記の通り

    ┌────────────────　フォーマット　─────────────────────┐
    ｜◇{献金種類}　{献金者1}、{献金者2}、....　　　　　　　　　｜
    └──────────────────────────────────────────────────┘
    ┌────────────────────　例　─────────────────────────┐
    ｜◇月次献金　佐藤麻衣子、山田大地（以上1月分）　 　　　　　　｜
    ｜　佐藤正雄、佐藤一郎（以上１〜３月分） 　　　　　　　　　　｜
    ｜　山田恵（２〜３月分）　　　　　　 　　　　　　　　　　　　｜
    ｜◇式典献金　佐藤麻衣子　　　　　　　　　　　　　　　　　　　｜
    ｜◇クリスマス献金　山田大地　　　　　　　　　　　　　　　　　｜
    ｜◇その他感謝献金　山田大地（会場利用）　　　　　　　　　　　｜
    └──────────────────────────────────────────────────┘

    【出力仕様】
    ・下記条件をすべて満たす献金レコードが出力対象（DonationDao#getDonationsByDateAggregate参照）
        ・検索期間内に納入日が含まれる
        ・「メイン／サブ献金」＝「メイン献金」
        ・献金者の会員区分＝「現住陪餐会員」「陪餐会員」
    ・献金種類ごとに、献金者名を記載する
    ・献金レコードの「献金者配偶者名」「献金者家族名」に値が登録されている場合は、中点（・）を挟んで続けて記載する
    ・献金レコードの「摘要」欄に値が登録されている場合は、献金者名のあとに括弧内で記載する
    ・月次献金の場合のみ
        ・献金種別に続けて、さらに献金レコードの「献金月」ごとに分類する
        ・献金月は献金者名のあとに括弧内で記載する
        ・当該献金月の献金者が1名のみの場合は、括弧内に「以上」を記載する
*/

    // 「献金種類」項目のMap(key: 選択肢API参照名, value: 選択肢表示ラベル)
    private static Map<String, String> donaitonTypeMap = new Map<String, String>();

    //「献金種類」項目の選択肢API参照名List
    private static List<String> donationTypeList = new List<String>();

    /* 
        献金種類別の献金者名Listを格納するMap
        key:「献金種類」項目の選択肢のAPI参照名
        value: その種類の献金をした献金者名のSet
    */
    private static Map<String, Set<String>> dTypeDonorSetMap = new Map<String, Set<String>>();

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
            dTypeDonorSetMap.put(dType, new Set<String>());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getShuhoData(Date donationDateFrom, Date donationDateTo){
        // 検索期間に納入された献金一覧を取得
        List<AggregateResult> dList = DonationDao.getDonationsByDateAggregate(donationDateFrom, donationDateTo);

        // 【月次献金専用】献金者格納Map
        // key: 月次献金の月名（例：『１〜３月分』）
        // value: 献金者名List（例：『佐藤麻衣子、山田大地、佐藤正雄、…』）
        Map<String, List<String>> monthDonationMap = new Map<String, List<String>>();

        // 献金者名を取得して献金種類別にListに格納
        for (AggregateResult d : dList) {
            String dType = String.valueOf(d.get('DonationType__c'));
            Set<String> donorSet = dTypeDonorSetMap.get(dType);

            String donorNameStr = String.valueOf(d.get('DonorName'));
            String donationSpouseName = String.valueOf(d.get('DonationSpouseName'));
            String donationFamilyName = String.valueOf(d.get('DonationFamilyName'));
            String donationNote = String.valueOf(d.get('DonationNote'));

            // 献金者名・献金者配偶者名・献金者家族名・摘要を結合（例：『佐藤健志・正雄・麻衣子』）
            if(!String.isEmpty(donationSpouseName)){
                donorNameStr += '・' + donationSpouseName;
            } else if (!String.isEmpty(donationFamilyName)) {
                donorNameStr += '・' + donationFamilyName;
            }
            if(!String.isEmpty(donationNote) && !'1'.equals(dType)){
                // 「摘要」内容を括弧書きで連結（月次献金の場合は括弧内に月名を記載するためスキップ）
                donorNameStr += '（' + donationNote + '）';
            }

            // 月次献金の場合
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
                    // 献金者が存在しなかった場合はスキップする
                    continue;
                }

                List<String> donorAndMonthList = new List<String>();

                for(String month : monthDonationMap.keySet()){
                    List<String> monthDonorList = monthDonationMap.get(month);
                    String monthDonorsStr = String.join(monthDonorList, '、');
                    String connector = monthDonorList.size() == 1 ? '（' : '（以上';

                    // 献金月名と、その献金月の全献金者名の文字列を生成
                    // 例：『佐藤正雄、佐藤一郎（以上１〜３月分）』
                    String donorAndMonth = monthDonorsStr + connector + month + '）';
                    donorAndMonthList.add(donorAndMonth);
                }

                allDonorsStr = String.join(donorAndMonthList, '</br>　');
            } else {
                Set<String> donorSet = dTypeDonorSetMap.get(dType);
                if (donorSet.isEmpty()) {
                    // 献金者が存在しなかった献金種類はスキップする
                    continue;
                }
                // すべての献金者名を結合
                List<String> donorList = new List<String>(donorSet);
                allDonorsStr = String.join(donorList, '、');
            }

            // 行頭文字を作成
            String dTypeStr = '◇' + '<b>' + donaitonTypeMap.get(dType) + '</b>';

            // 行頭文字+全献金者名を結合
            // 例：『◇月次献金　佐藤麻衣子、山田大地、佐藤正雄（以上１〜３月分）』
            String dTypeAndDonorStr = dTypeStr + '　' + allDonorsStr;

            dTypeAndDonorList.add(dTypeAndDonorStr);
        }

        String result = String.join(dTypeAndDonorList, '<br/>');
        return result;
    }
}