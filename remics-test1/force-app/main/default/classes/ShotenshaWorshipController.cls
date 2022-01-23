public with sharing class ShotenshaWorshipController {

    // CSVデータ
    public static String csvData { get; set; }

    // 遺族宛案内 送付先世帯一覧 CSVデータを作成
    public static void createAtenaCsvData() {

      // 最後にユーザーが検索した検索日付をカスタム設定から取得
      ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();

      List<Date> dateList = new List<Date>();
      dateList.add(sws.thisYearFrom__c);
      dateList.add(sws.thisYearTo__c);
      dateList.add(sws.lastYearFrom__c);
      dateList.add(sws.lastYearTo__c);
      dateList.add(sws.fiveYearFrom__c);
      dateList.add(sws.fiveYearTo__c);
      dateList.add(sws.tenYearFrom__c);
      dateList.add(sws.tenYearTo__c);
      dateList.add(sws.fifteenYearFrom__c);
      dateList.add(sws.fifteenYearTo__c);
      dateList.add(sws.twentyYearFrom__c);
      dateList.add(sws.twentyYearTo__c);
      dateList.add(sws.twentyFiveYearFrom__c);
      dateList.add(sws.twentyFiveYearTo__c);

      // CSVデータのもととなるデータを取得
      List<Map<String, Object>> survivorHouseholdList = getSurvivorHouseholdList(dateList, false);

      List<String> rowList = new List<String>();

      // ヘッダー行を作成
      rowList.add('世帯名,郵便番号,住所,世帯主名,連名1,連名2,連名3,召天者名1,召天年1,召天者名2,召天年2,召天者名3,召天年3,召天者名4,召天年4,召天者名5,召天年5,召天者名6,召天年6,召天者名7,召天年7,召天者名8,召天年8,召天者名9,召天年9,召天者名10,召天年10');

      // データ行を作成
      for(Map<String, Object> shMap : survivorHouseholdList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      // １行ごとに改行を付与
      csvData = String.join(rowList, '\r\n');
      // 最終行にも改行を付加する
      csvData += '\r\n';
    }

    // 召天者-遺族 一覧 CSVデータを作成
    public static void createDeceasedListCsvData() {

      // 最後にユーザーが検索した検索日付をカスタム設定から取得
      ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();

      List<Date> dateList = new List<Date>();
      dateList.add(sws.thisYearFrom__c);
      dateList.add(sws.thisYearTo__c);
      dateList.add(sws.lastYearFrom__c);
      dateList.add(sws.lastYearTo__c);
      dateList.add(sws.fiveYearFrom__c);
      dateList.add(sws.fiveYearTo__c);
      dateList.add(sws.tenYearFrom__c);
      dateList.add(sws.tenYearTo__c);
      dateList.add(sws.fifteenYearFrom__c);
      dateList.add(sws.fifteenYearTo__c);
      dateList.add(sws.twentyYearFrom__c);
      dateList.add(sws.twentyYearTo__c);
      dateList.add(sws.twentyFiveYearFrom__c);
      dateList.add(sws.twentyFiveYearTo__c);

      // CSVデータのもととなるデータを取得
      List<Map<String, Object>> deceasedList = getDeceasedList(dateList, false);

      List<String> rowList = new List<String>();

      // ヘッダー行を作成
      rowList.add('召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無,遺族名,遺族原簿番号,遺族続柄,遺族召天案内,郵便番号,住所');

      // データ行を作成
      for(Map<String, Object> shMap : deceasedList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      // １行ごとに改行を付与
      csvData = String.join(rowList, '\r\n');
      // 最終行にも改行を付加する
      csvData += '\r\n';
    }

    // 遺族-召天者 一覧 CSVデータを作成
    public static void createSurvivorListCsvData() {

      // 最後にユーザーが検索した検索日付をカスタム設定から取得
      ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();

      List<Date> dateList = new List<Date>();
      dateList.add(sws.thisYearFrom__c);
      dateList.add(sws.thisYearTo__c);
      dateList.add(sws.lastYearFrom__c);
      dateList.add(sws.lastYearTo__c);
      dateList.add(sws.fiveYearFrom__c);
      dateList.add(sws.fiveYearTo__c);
      dateList.add(sws.tenYearFrom__c);
      dateList.add(sws.tenYearTo__c);
      dateList.add(sws.fifteenYearFrom__c);
      dateList.add(sws.fifteenYearTo__c);
      dateList.add(sws.twentyYearFrom__c);
      dateList.add(sws.twentyYearTo__c);
      dateList.add(sws.twentyFiveYearFrom__c);
      dateList.add(sws.twentyFiveYearTo__c);

      // CSVデータのもととなるデータを取得
      List<Map<String, Object>> survivorList = getSurvivorList(dateList, false);

      List<String> rowList = new List<String>();

      // ヘッダー行を作成
      rowList.add('遺族原簿番号,遺族名,遺族会員区分,郵便番号,住所,遺族続柄,遺族召天案内,召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無');

      // データ行を作成
      for(Map<String, Object> shMap : survivorList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      // １行ごとに改行を付与
      csvData = String.join(rowList, '\r\n');
      // 最終行にも改行を付加する
      csvData += '\r\n';
    }

    // 召天者記念礼拝の案内を送付する遺族とその世帯を世帯単位で出力する
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSurvivorHouseholdList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyHousehold(dateList);

      // key: 世帯ID, value: 遺族とその召天者のMap
      Map<String, Map<String, Object>> dataMap = new Map<String, Map<String, Object>>();

      // 召天者×遺族オブジェクトを展開
      for (DeceasedSurvivor__c d : dList) {
        if(dataMap.containsKey(d.SurvivorHousehold__c)){
          addNewDeceasedPersonToRecord(dataMap, d, dateList);
        } else {
          addNewHouseholdRecord(dataMap, d, dateList);
        }
      }

      // 遺族とその召天者のMapのListを取得
      List<Map<String, Object>> dataList = dataMap.values();

      for (Map<String, Object> data : dataList){
  
        // 召天者情報が格納されているMapのListを取得
        List<Map<String, String>> deceasedPersonMapList = (List<Map<String, String>>)data.get('deceasedPersonMapList');

        for (Integer i = 0; i < deceasedPersonMapList.size(); i++) {
          String nameKeyStr = 'DeceasedPersonName' + String.valueOf(i+1);
          String nameKeyVal = deceasedPersonMapList[i].get('DeceasedPersonName');
          data.put(nameKeyStr, nameKeyVal);

          String dateKeyStr = 'DeceasedDateCat' + String.valueOf(i+1);
          String dateKeyVal = deceasedPersonMapList[i].get('DeceasedDateCat');
          data.put(dateKeyStr, dateKeyVal);
        }

        // deceasedPersonMapList、およびそれを作成するためだけの要素を削除
        data.remove('deceasedPersonMapList');
        data.remove('DeceasedPersonIdStr');
      }

      // 最後にユーザーが検索した検索日付をカスタム設定に保存
      if(isForView){
        ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();
        sws.thisYearFrom__c = dateList[0];
        sws.thisYearTo__c = dateList[1];
        sws.lastYearFrom__c = dateList[2];
        sws.lastYearTo__c = dateList[3];
        sws.fiveYearFrom__c = dateList[4];
        sws.fiveYearTo__c = dateList[5];
        sws.tenYearFrom__c = dateList[6];
        sws.tenYearTo__c = dateList[7];
        sws.fifteenYearFrom__c = dateList[8];
        sws.fifteenYearTo__c = dateList[9];
        sws.twentyYearFrom__c = dateList[10];
        sws.twentyYearTo__c = dateList[11];
        sws.twentyFiveYearFrom__c = dateList[12];
        sws.twentyFiveYearTo__c = dateList[13];
        upsert sws;
      }

      return dataList;
    }

    // 新規世帯行を作成
    private static void addNewHouseholdRecord(Map<String, Map<String, Object>> dataMap, DeceasedSurvivor__c d, List<Date> dateList){
        Map<String, Object> data = new Map<String, Object>();

        data.put('SurvivorHouseholdName', d.SurvivorHousehold__r.Name == null ? '' : d.SurvivorHousehold__r.Name);
        data.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c == null ? '' : d.SurvivorHousehold__r.PostalCode__c);
        data.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c == null ? '' : d.SurvivorHousehold__r.AddressAllCombined__c);
        data.put('HouseholderName', d.SurvivorHousehold__r.HouseholderName__c == null ? '' : d.SurvivorHousehold__r.HouseholderName__c);
        data.put('JointSignature1', d.SurvivorHousehold__r.JointSignature1__c == null ? '' : d.SurvivorHousehold__r.JointSignature1__c);
        data.put('JointSignature2', d.SurvivorHousehold__r.JointSignature2__c == null ? '' : d.SurvivorHousehold__r.JointSignature2__c);
        data.put('JointSignature3', d.SurvivorHousehold__r.JointSignature3__c == null ? '' : d.SurvivorHousehold__r.JointSignature3__c);

        // 召天者情報を格納するListを作成
        List<Map<String, String>> deceasedPersonMapList = new List<Map<String, String>>();
        // Listに召天者情報のMapを格納
        Map<String, String> deceasedPersonMap = new Map<String, String>();
        deceasedPersonMap.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        deceasedPersonMap.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        deceasedPersonMapList.add(deceasedPersonMap);
        data.put('deceasedPersonMapList', deceasedPersonMapList);

        // どの召天者情報を格納したかわかりやすくするため、召天者IDを別途記録
        data.put('DeceasedPersonIdStr', d.DeceasedPerson__c);

        dataMap.put(d.SurvivorHousehold__c, data);
    }

    // 既存の世帯行に召天者情報を追記
    private static void addNewDeceasedPersonToRecord(Map<String, Map<String, Object>> dataMap, DeceasedSurvivor__c d, List<Date> dateList){

        // 新たに情報を格納しようとしている世帯行を取得
        Map<String, Object> data = dataMap.get(d.SurvivorHousehold__c);

        // すでに情報を格納済みの召天者IDを取得
        String deceasedPersonIdStr = (String)data.get('DeceasedPersonIdStr');
        // 新たに情報を格納しようとしている召天者IDを取得
        String deceasedPersonId = d.DeceasedPerson__c;

        // 新たに情報を格納する必要がある召天者かどうか確認
        if(!String.isEmpty(deceasedPersonIdStr) && deceasedPersonIdStr.contains(deceasedPersonId)){
          // このレコードの召天者はすでに格納済のため、スキップする
          return;
        }

        // 新たに格納する召天者IDを追記
        deceasedPersonIdStr += ',' + deceasedPersonId;
        data.put('DeceasedPersonIdStr', deceasedPersonIdStr);

        // 新たに召天者情報を格納
        Map<String, String> deceasedPersonMap = new Map<String, String>();
        deceasedPersonMap.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        deceasedPersonMap.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));

        List<Map<String, String>> deceasedPersonMapList = (List<Map<String, String>>)data.get('deceasedPersonMapList');
        deceasedPersonMapList.add(deceasedPersonMap);
    }

    // 召天年のカテゴリーを作成
    private static String decideDeceasedDateCategory(Date deceasedDate, List<Date> dateList){
      if (deceasedDate >= dateList[0] && deceasedDate <= dateList[1] ) {
        return '当年';
      } else if (deceasedDate >= dateList[2] && deceasedDate <= dateList[3] ) {
        return '1年';
      } else if (deceasedDate >= dateList[4] && deceasedDate <= dateList[5] ) {
        return '5年';
      } else if (deceasedDate >= dateList[6] && deceasedDate <= dateList[7] ) {
        return '10年';
      } else if (deceasedDate >= dateList[8] && deceasedDate <= dateList[9] ) {
        return '15年';
      } else if (deceasedDate >= dateList[10] && deceasedDate <= dateList[11] ) {
        return '20年';
      } else {
        return '25年';
      }
    }

    // 召天者記念礼拝の対象となる召天者とその遺族を召天者単位で出力する
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getDeceasedList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyDeceasedDate(dateList);
  
      // 遺族とその召天者のMapのListを取得
      List<Map<String, Object>> dataList = new List<Map<String, Object>>();

      // 召天者×遺族オブジェクトを展開
      for (DeceasedSurvivor__c d : dList) {
        Map<String, Object> m = new Map<String, Object>();

        // 召天者
        m.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        m.put('DeceasedPersonType', d.DeceasedPerson__r.PersonType__c);
        m.put('DeceasedPersonNumCurrent', d.DeceasedPerson__r.PersonNumCurrent__c);
        m.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        if(isForView){
          m.put('DeceasedDate', d.DeceasedDate__c);
          m.put('BoneDate', d.DeceasedPerson__r.BoneDate__c);
        } else {
          // CSV出力する場合は日付をフォーマットする（世界照準時形式で出力されてしまうため）
          m.put('DeceasedDate', String.valueOf(d.DeceasedDate__c));
          m.put('BoneDate', String.valueOf(d.DeceasedPerson__r.BoneDate__c));
        }
        m.put('Remains', d.DeceasedPerson__r.Remains__c);
        // 遺族
        m.put('SurvivorName', d.SurvivorPerson__r.Name);
        m.put('SurvivorPersonNumCurrent', d.SurvivorPerson__r.PersonNumCurrent__c);
        m.put('SurvivorRelationship', d.SurvivorRelationship__c);
        m.put('CelestialWorshipShipment', d.SurvivorPerson__r.CelestialWorshipShipment__c);
        // 世帯
        m.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c);
        m.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c);

        dataList.add(m);
      }

      return dataList;
    }

    // 召天者記念礼拝の対象となる召天者とその遺族を遺族単位で出力する
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSurvivorList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyPostalcode(dateList);
  
      // 遺族とその召天者のMapのListを取得
      List<Map<String, Object>> dataList = new List<Map<String, Object>>();

      // 召天者×遺族オブジェクトを展開
      for (DeceasedSurvivor__c d : dList) {
        Map<String, Object> m = new Map<String, Object>();

        // 遺族
        m.put('SurvivorPersonNumCurrent', d.SurvivorPerson__r.PersonNumCurrent__c);
        m.put('SurvivorName', d.SurvivorPerson__r.Name);
        m.put('SurvivorPersonType', d.SurvivorPerson__r.PersonType__c);
        // 世帯
        m.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c);
        m.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c);
        m.put('SurvivorRelationship', d.SurvivorRelationship__c);
        m.put('CelestialWorshipShipment', d.SurvivorPerson__r.CelestialWorshipShipment__c);
        // 召天者
        m.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        m.put('DeceasedPersonType', d.DeceasedPerson__r.PersonType__c);
        m.put('DeceasedPersonNumCurrent', d.DeceasedPerson__r.PersonNumCurrent__c);
        m.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        if(isForView){
          m.put('DeceasedDate', d.DeceasedDate__c);
          m.put('BoneDate', d.DeceasedPerson__r.BoneDate__c);
        } else {
          // CSV出力する場合は日付をフォーマットする（世界照準時形式で出力されてしまうため）
          m.put('DeceasedDate', String.valueOf(d.DeceasedDate__c));
          m.put('BoneDate', String.valueOf(d.DeceasedPerson__r.BoneDate__c));
        }
        m.put('Remains', d.DeceasedPerson__r.Remains__c);

        dataList.add(m);
      }

      return dataList;
    }
}