public with sharing class ShotenshaWorshipController {

    // CSVデータ
    public static String csvData { get; set; }

    // 遺族宛案内 送付先世帯一覧 CSVデータを作成
    public static void createAtenaCsvData() {

      // CSVデータのもととなるデータを取得
      List<Date> dateList = fetchLastSearchDateCondition();
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

      // CSVデータのもととなるデータを取得
      List<Date> dateList = fetchLastSearchDateCondition();
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

      // CSVデータのもととなるデータを取得
      List<Date> dateList = fetchLastSearchDateCondition();
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
        saveLastSearchDateCondition(dateList);
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
      } else if (deceasedDate >= dateList[12] && deceasedDate <= dateList[13] ) {
        return '25年';
      } else if (deceasedDate >= dateList[14] && deceasedDate <= dateList[15] ) {
        return '30年';
      } else if (deceasedDate >= dateList[16] && deceasedDate <= dateList[17] ) {
        return '35年';
      } else if (deceasedDate >= dateList[18] && deceasedDate <= dateList[19] ) {
        return '40年';
      } else if (deceasedDate >= dateList[20] && deceasedDate <= dateList[21] ) {
        return '45年';
      } else if (deceasedDate >= dateList[22] && deceasedDate <= dateList[23] ) {
        return '50年';
      } else if (deceasedDate >= dateList[24] && deceasedDate <= dateList[25] ) {
        return '55年';
      } else if (deceasedDate >= dateList[26] && deceasedDate <= dateList[27] ) {
        return '60年';
      } else if (deceasedDate >= dateList[28] && deceasedDate <= dateList[29] ) {
        return '65年';
      } else if (deceasedDate >= dateList[30] && deceasedDate <= dateList[31] ) {
        return '70年';
      } else if (deceasedDate >= dateList[32] && deceasedDate <= dateList[33] ) {
        return '75年';
      } else if (deceasedDate >= dateList[34] && deceasedDate <= dateList[35] ) {
        return '80年';
      } else if (deceasedDate >= dateList[36] && deceasedDate <= dateList[37] ) {
        return '85年';
      } else if (deceasedDate >= dateList[38] && deceasedDate <= dateList[39] ) {
        return '90年';
      } else if (deceasedDate >= dateList[40] && deceasedDate <= dateList[41] ) {
        return '95年';
      } else if (deceasedDate >= dateList[42] && deceasedDate <= dateList[43] ) {
        return '100年';
      } else if (deceasedDate >= dateList[44] && deceasedDate <= dateList[45] ) {
        return '105年';
      } else if (deceasedDate >= dateList[46] && deceasedDate <= dateList[47] ) {
        return '110年';
      } else if (deceasedDate >= dateList[48] && deceasedDate <= dateList[49] ) {
        return '115年';
      } else if (deceasedDate >= dateList[50] && deceasedDate <= dateList[51] ) {
        return '120年';
      } else if (deceasedDate >= dateList[52] && deceasedDate <= dateList[53] ) {
        return '125年';
      } else if (deceasedDate >= dateList[54] && deceasedDate <= dateList[55] ) {
        return '130年';
      } else if (deceasedDate >= dateList[56] && deceasedDate <= dateList[57] ) {
        return '135年';
      } else if (deceasedDate >= dateList[58] && deceasedDate <= dateList[59] ) {
        return '140年';
      } else if (deceasedDate >= dateList[60] && deceasedDate <= dateList[61] ) {
        return '145年';
      } else if (deceasedDate >= dateList[62] && deceasedDate <= dateList[63] ) {
        return '150年';
      } else if (deceasedDate >= dateList[64] && deceasedDate <= dateList[65] ) {
        return '155年';
      } else if (deceasedDate >= dateList[66] && deceasedDate <= dateList[67] ) {
        return '160年';
      } else if (deceasedDate >= dateList[68] && deceasedDate <= dateList[69] ) {
        return '165年';
      } else if (deceasedDate >= dateList[70] && deceasedDate <= dateList[71] ) {
        return '170年';
      } else if (deceasedDate >= dateList[72] && deceasedDate <= dateList[73] ) {
        return '175年';
      } else if (deceasedDate >= dateList[74] && deceasedDate <= dateList[75] ) {
        return '180年';
      } else if (deceasedDate >= dateList[76] && deceasedDate <= dateList[77] ) {
        return '185年';
      } else if (deceasedDate >= dateList[78] && deceasedDate <= dateList[79] ) {
        return '190年';
      } else if (deceasedDate >= dateList[80] && deceasedDate <= dateList[81] ) {
        return '195年';
      } else if (deceasedDate >= dateList[82] && deceasedDate <= dateList[83] ) {
        return '200年';
      } else {
        return '不明';
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

    // 最後にユーザーが検索した検索日付をカスタム設定から取得
    public static List<Date> fetchLastSearchDateCondition(){
      ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();

      List<Date> dateList = new List<Date>();
      dateList.add(sws.YearFrom0__c);
      dateList.add(sws.YearTo0__c);
      dateList.add(sws.YearFrom1__c);
      dateList.add(sws.YearTo1__c);
      dateList.add(sws.YearFrom5__c);
      dateList.add(sws.YearTo5__c);
      dateList.add(sws.YearFrom10__c);
      dateList.add(sws.YearTo10__c);
      dateList.add(sws.YearFrom15__c);
      dateList.add(sws.YearTo15__c);
      dateList.add(sws.YearFrom20__c);
      dateList.add(sws.YearTo20__c);
      dateList.add(sws.YearFrom25__c);
      dateList.add(sws.YearTo25__c);
      dateList.add(sws.YearFrom30__c);
      dateList.add(sws.YearTo30__c);
      dateList.add(sws.YearFrom35__c);
      dateList.add(sws.YearTo35__c);
      dateList.add(sws.YearFrom40__c);
      dateList.add(sws.YearTo40__c);
      dateList.add(sws.YearFrom45__c);
      dateList.add(sws.YearTo45__c);
      dateList.add(sws.YearFrom50__c);
      dateList.add(sws.YearTo50__c);
      dateList.add(sws.YearFrom55__c);
      dateList.add(sws.YearTo55__c);
      dateList.add(sws.YearFrom60__c);
      dateList.add(sws.YearTo60__c);
      dateList.add(sws.YearFrom65__c);
      dateList.add(sws.YearTo65__c);
      dateList.add(sws.YearFrom70__c);
      dateList.add(sws.YearTo70__c);
      dateList.add(sws.YearFrom75__c);
      dateList.add(sws.YearTo75__c);
      dateList.add(sws.YearFrom80__c);
      dateList.add(sws.YearTo80__c);
      dateList.add(sws.YearFrom85__c);
      dateList.add(sws.YearTo85__c);
      dateList.add(sws.YearFrom90__c);
      dateList.add(sws.YearTo90__c);
      dateList.add(sws.YearFrom95__c);
      dateList.add(sws.YearTo95__c);
      dateList.add(sws.YearFrom100__c);
      dateList.add(sws.YearTo100__c);
      dateList.add(sws.YearFrom105__c);
      dateList.add(sws.YearTo105__c);
      dateList.add(sws.YearFrom110__c);
      dateList.add(sws.YearTo110__c);
      dateList.add(sws.YearFrom115__c);
      dateList.add(sws.YearTo115__c);
      dateList.add(sws.YearFrom120__c);
      dateList.add(sws.YearTo120__c);
      dateList.add(sws.YearFrom125__c);
      dateList.add(sws.YearTo125__c);
      dateList.add(sws.YearFrom130__c);
      dateList.add(sws.YearTo130__c);
      dateList.add(sws.YearFrom135__c);
      dateList.add(sws.YearTo135__c);
      dateList.add(sws.YearFrom140__c);
      dateList.add(sws.YearTo140__c);
      dateList.add(sws.YearFrom145__c);
      dateList.add(sws.YearTo145__c);
      dateList.add(sws.YearFrom150__c);
      dateList.add(sws.YearTo150__c);
      dateList.add(sws.YearFrom155__c);
      dateList.add(sws.YearTo155__c);
      dateList.add(sws.YearFrom160__c);
      dateList.add(sws.YearTo160__c);
      dateList.add(sws.YearFrom165__c);
      dateList.add(sws.YearTo165__c);
      dateList.add(sws.YearFrom170__c);
      dateList.add(sws.YearTo170__c);
      dateList.add(sws.YearFrom175__c);
      dateList.add(sws.YearTo175__c);
      dateList.add(sws.YearFrom180__c);
      dateList.add(sws.YearTo180__c);
      dateList.add(sws.YearFrom185__c);
      dateList.add(sws.YearTo185__c);
      dateList.add(sws.YearFrom190__c);
      dateList.add(sws.YearTo190__c);
      dateList.add(sws.YearFrom195__c);
      dateList.add(sws.YearTo195__c);
      dateList.add(sws.YearFrom200__c);
      dateList.add(sws.YearTo200__c);

      return dateList;
    }

    // 最後にユーザーが検索した検索日付をカスタム設定に保存
    public static void saveLastSearchDateCondition(List<Date> dateList){
      ShotenshaWorshipSurvivorList__c sws = ShotenshaWorshipSurvivorList__c.getInstance();

      sws.YearFrom0__c = dateList[0];
      sws.YearTo0__c = dateList[1];
      sws.YearFrom1__c = dateList[2];
      sws.YearTo1__c = dateList[3];
      sws.YearFrom5__c = dateList[4];
      sws.YearTo5__c = dateList[5];
      sws.YearFrom10__c = dateList[6];
      sws.YearTo10__c = dateList[7];
      sws.YearFrom15__c = dateList[8];
      sws.YearTo15__c = dateList[9];
      sws.YearFrom20__c = dateList[10];
      sws.YearTo20__c = dateList[11];
      sws.YearFrom25__c = dateList[12];
      sws.YearTo25__c = dateList[13];
      sws.YearFrom30__c = dateList[14];
      sws.YearTo30__c = dateList[15];
      sws.YearFrom35__c = dateList[16];
      sws.YearTo35__c = dateList[17];
      sws.YearFrom40__c = dateList[18];
      sws.YearTo40__c = dateList[19];
      sws.YearFrom45__c = dateList[20];
      sws.YearTo45__c = dateList[21];
      sws.YearFrom50__c = dateList[22];
      sws.YearTo50__c = dateList[23];
      sws.YearFrom55__c = dateList[24];
      sws.YearTo55__c = dateList[25];
      sws.YearFrom60__c = dateList[26];
      sws.YearTo60__c = dateList[27];
      sws.YearFrom65__c = dateList[28];
      sws.YearTo65__c = dateList[29];
      sws.YearFrom70__c = dateList[30];
      sws.YearTo70__c = dateList[31];
      sws.YearFrom75__c = dateList[32];
      sws.YearTo75__c = dateList[33];
      sws.YearFrom80__c = dateList[34];
      sws.YearTo80__c = dateList[35];
      sws.YearFrom85__c = dateList[36];
      sws.YearTo85__c = dateList[37];
      sws.YearFrom90__c = dateList[38];
      sws.YearTo90__c = dateList[39];
      sws.YearFrom95__c = dateList[40];
      sws.YearTo95__c = dateList[41];
      sws.YearFrom100__c = dateList[42];
      sws.YearTo100__c = dateList[43];
      sws.YearFrom105__c = dateList[44];
      sws.YearTo105__c = dateList[45];
      sws.YearFrom110__c = dateList[46];
      sws.YearTo110__c = dateList[47];
      sws.YearFrom115__c = dateList[48];
      sws.YearTo115__c = dateList[49];
      sws.YearFrom120__c = dateList[50];
      sws.YearTo120__c = dateList[51];
      sws.YearFrom125__c = dateList[52];
      sws.YearTo125__c = dateList[53];
      sws.YearFrom130__c = dateList[54];
      sws.YearTo130__c = dateList[55];
      sws.YearFrom135__c = dateList[56];
      sws.YearTo135__c = dateList[57];
      sws.YearFrom140__c = dateList[58];
      sws.YearTo140__c = dateList[59];
      sws.YearFrom145__c = dateList[60];
      sws.YearTo145__c = dateList[61];
      sws.YearFrom150__c = dateList[62];
      sws.YearTo150__c = dateList[63];
      sws.YearFrom155__c = dateList[64];
      sws.YearTo155__c = dateList[65];
      sws.YearFrom160__c = dateList[66];
      sws.YearTo160__c = dateList[67];
      sws.YearFrom165__c = dateList[68];
      sws.YearTo165__c = dateList[69];
      sws.YearFrom170__c = dateList[70];
      sws.YearTo170__c = dateList[71];
      sws.YearFrom175__c = dateList[72];
      sws.YearTo175__c = dateList[73];
      sws.YearFrom180__c = dateList[74];
      sws.YearTo180__c = dateList[75];
      sws.YearFrom185__c = dateList[76];
      sws.YearTo185__c = dateList[77];
      sws.YearFrom190__c = dateList[78];
      sws.YearTo190__c = dateList[79];
      sws.YearFrom195__c = dateList[80];
      sws.YearTo195__c = dateList[81];
      sws.YearFrom200__c = dateList[82];
      sws.YearTo200__c = dateList[83];

      upsert sws;

    }
}