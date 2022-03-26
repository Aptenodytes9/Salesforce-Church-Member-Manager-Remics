public with sharing class ShotenshaWorshipController {

    public static String csvData { get; set; }

    public static void createAtenaCsvData() {

      // Get the last search date the user searched from the custom settings
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

      // Get the data that is the basis of CSV data
      List<Map<String, Object>> survivorHouseholdList = getSurvivorHouseholdList(dateList, false);

      List<String> rowList = new List<String>();

      // Create header line
      rowList.add('世帯名,郵便番号,住所,世帯主名,連名1,連名2,連名3,召天者名1,召天年1,召天者名2,召天年2,召天者名3,召天年3,召天者名4,召天年4,召天者名5,召天年5,召天者名6,召天年6,召天者名7,召天年7,召天者名8,召天年8,召天者名9,召天年9,召天者名10,召天年10');

      // Create a row of data
      for(Map<String, Object> shMap : survivorHouseholdList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      csvData = String.join(rowList, '\r\n');
      csvData += '\r\n';
    }

    public static void createDeceasedListCsvData() {

      // Get the last search date the user searched from the custom settings
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

      // Get the data that is the basis of CSV data
      List<Map<String, Object>> deceasedList = getDeceasedList(dateList, false);

      List<String> rowList = new List<String>();

      // Create header line
      rowList.add('召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無,遺族名,遺族原簿番号,遺族続柄,遺族召天案内,郵便番号,住所');

      // Create a row of data
      for(Map<String, Object> shMap : deceasedList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      csvData = String.join(rowList, '\r\n');
      csvData += '\r\n';
    }

    public static void createSurvivorListCsvData() {

      // Get the last search date the user searched from the custom settings
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

      // Get the data that is the basis of CSV data
      List<Map<String, Object>> survivorList = getSurvivorList(dateList, false);

      List<String> rowList = new List<String>();

      // Create header line
      rowList.add('遺族原簿番号,遺族名,遺族会員区分,郵便番号,住所,遺族続柄,遺族召天案内,召天年,召天者会員区分,召天者原簿番号,召天者名,召天日,納骨日,御遺影有無');

      // Create a row of data
      for(Map<String, Object> shMap : survivorList) {
        rowList.add(String.join(shMap.values(), ','));
      }

      csvData = String.join(rowList, '\r\n');
      csvData += '\r\n';
    }

    // Output the bereaved family and their households that send information on the memorial service for the celestial people on a household basis
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSurvivorHouseholdList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyHousehold(dateList);

      // key: Household ID, value: Map of bereaved families and their celestials
      Map<String, Map<String, Object>> dataMap = new Map<String, Map<String, Object>>();

      for (DeceasedSurvivor__c d : dList) {
        if(dataMap.containsKey(d.SurvivorHousehold__c)){
          addNewDeceasedPersonToRecord(dataMap, d, dateList);
        } else {
          addNewHouseholdRecord(dataMap, d, dateList);
        }
      }

      // Get the Map List of bereaved families and their deceased
      List<Map<String, Object>> dataList = dataMap.values();

      for (Map<String, Object> data : dataList){
  
        // Get the Map List of the deceased person
        List<Map<String, String>> deceasedPersonMapList = (List<Map<String, String>>)data.get('deceasedPersonMapList');

        for (Integer i = 0; i < deceasedPersonMapList.size(); i++) {
          String nameKeyStr = 'DeceasedPersonName' + String.valueOf(i+1);
          String nameKeyVal = deceasedPersonMapList[i].get('DeceasedPersonName');
          data.put(nameKeyStr, nameKeyVal);

          String dateKeyStr = 'DeceasedDateCat' + String.valueOf(i+1);
          String dateKeyVal = deceasedPersonMapList[i].get('DeceasedDateCat');
          data.put(dateKeyStr, dateKeyVal);
        }

        // Removed deceasedPersonMapList and elements just to create it
        data.remove('deceasedPersonMapList');
        data.remove('DeceasedPersonIdStr');
      }

      // Save last user search date in custom settings
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

    // Create a new household row
    private static void addNewHouseholdRecord(Map<String, Map<String, Object>> dataMap, DeceasedSurvivor__c d, List<Date> dateList){
        Map<String, Object> data = new Map<String, Object>();

        data.put('SurvivorHouseholdName', d.SurvivorHousehold__r.Name == null ? '' : d.SurvivorHousehold__r.Name);
        data.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c == null ? '' : d.SurvivorHousehold__r.PostalCode__c);
        data.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c == null ? '' : d.SurvivorHousehold__r.AddressAllCombined__c);
        data.put('HouseholderName', d.SurvivorHousehold__r.HouseholderName__c == null ? '' : d.SurvivorHousehold__r.HouseholderName__c);
        data.put('JointSignature1', d.SurvivorHousehold__r.JointSignature1__c == null ? '' : d.SurvivorHousehold__r.JointSignature1__c);
        data.put('JointSignature2', d.SurvivorHousehold__r.JointSignature2__c == null ? '' : d.SurvivorHousehold__r.JointSignature2__c);
        data.put('JointSignature3', d.SurvivorHousehold__r.JointSignature3__c == null ? '' : d.SurvivorHousehold__r.JointSignature3__c);

        List<Map<String, String>> deceasedPersonMapList = new List<Map<String, String>>();
        Map<String, String> deceasedPersonMap = new Map<String, String>();
        deceasedPersonMap.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        deceasedPersonMap.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        deceasedPersonMapList.add(deceasedPersonMap);
        data.put('deceasedPersonMapList', deceasedPersonMapList);

        // Record the deceased person ID to make it easy to understand which deceased person info was stored.
        data.put('DeceasedPersonIdStr', d.DeceasedPerson__c);

        dataMap.put(d.SurvivorHousehold__c, data);
    }

    // Added deceased people info to existing household records
    private static void addNewDeceasedPersonToRecord(Map<String, Map<String, Object>> dataMap, DeceasedSurvivor__c d, List<Date> dateList){

        // Get the target household row
        Map<String, Object> data = dataMap.get(d.SurvivorHousehold__c);

        String deceasedPersonIdStr = (String)data.get('DeceasedPersonIdStr');
        String deceasedPersonId = d.DeceasedPerson__c;

        // Check needs to store new information
        if(!String.isEmpty(deceasedPersonIdStr) && deceasedPersonIdStr.contains(deceasedPersonId)){
          // The deceased of this record is already stored, so skip it
          return;
        }

        deceasedPersonIdStr += ',' + deceasedPersonId;
        data.put('DeceasedPersonIdStr', deceasedPersonIdStr);

        // Newly stores deceased information
        Map<String, String> deceasedPersonMap = new Map<String, String>();
        deceasedPersonMap.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        deceasedPersonMap.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));

        List<Map<String, String>> deceasedPersonMapList = (List<Map<String, String>>)data.get('deceasedPersonMapList');
        deceasedPersonMapList.add(deceasedPersonMap);
    }

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

    // get the deceased people and their bereaved families who are the targets of the celestial worship service in units of deceased people.
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getDeceasedList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyDeceasedDate(dateList);
  
      List<Map<String, Object>> dataList = new List<Map<String, Object>>();

      for (DeceasedSurvivor__c d : dList) {
        Map<String, Object> m = new Map<String, Object>();

        // deceased people
        m.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        m.put('DeceasedPersonType', d.DeceasedPerson__r.PersonType__c);
        m.put('DeceasedPersonNumCurrent', d.DeceasedPerson__r.PersonNumCurrent__c);
        m.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        if(isForView){
          m.put('DeceasedDate', d.DeceasedDate__c);
          m.put('BoneDate', d.DeceasedPerson__r.BoneDate__c);
        } else {
          // Format the date when outputting CSV (because it is output in UTC format)
          m.put('DeceasedDate', String.valueOf(d.DeceasedDate__c));
          m.put('BoneDate', String.valueOf(d.DeceasedPerson__r.BoneDate__c));
        }
        m.put('Remains', d.DeceasedPerson__r.Remains__c);
        // bereaved families
        m.put('SurvivorName', d.SurvivorPerson__r.Name);
        m.put('SurvivorPersonNumCurrent', d.SurvivorPerson__r.PersonNumCurrent__c);
        m.put('SurvivorRelationship', d.SurvivorRelationship__c);
        m.put('CelestialWorshipShipment', d.SurvivorPerson__r.CelestialWorshipShipment__c);
        // households
        m.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c);
        m.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c);

        dataList.add(m);
      }

      return dataList;
    }

    // get the deceased people and their bereaved families who are the targets of the celestial worship service in units of bereaved families.
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSurvivorList(List<Date> dateList, Boolean isForView){
      List<DeceasedSurvivor__c> dList = DeceasedSurvivorDao.getDeceasedSurvivorByDateOrderbyPostalcode(dateList);
  
      List<Map<String, Object>> dataList = new List<Map<String, Object>>();

      for (DeceasedSurvivor__c d : dList) {
        Map<String, Object> m = new Map<String, Object>();

        // bereaved families
        m.put('SurvivorPersonNumCurrent', d.SurvivorPerson__r.PersonNumCurrent__c);
        m.put('SurvivorName', d.SurvivorPerson__r.Name);
        m.put('SurvivorPersonType', d.SurvivorPerson__r.PersonType__c);
        // households
        m.put('PostalCode', d.SurvivorHousehold__r.PostalCode__c);
        m.put('AddressAllCombined', d.SurvivorHousehold__r.AddressAllCombined__c);
        m.put('SurvivorRelationship', d.SurvivorRelationship__c);
        m.put('CelestialWorshipShipment', d.SurvivorPerson__r.CelestialWorshipShipment__c);
        // deceased people
        m.put('DeceasedDateCat', decideDeceasedDateCategory(d.DeceasedDate__c, dateList));
        m.put('DeceasedPersonType', d.DeceasedPerson__r.PersonType__c);
        m.put('DeceasedPersonNumCurrent', d.DeceasedPerson__r.PersonNumCurrent__c);
        m.put('DeceasedPersonName', d.DeceasedPerson__r.Name);
        if(isForView){
          m.put('DeceasedDate', d.DeceasedDate__c);
          m.put('BoneDate', d.DeceasedPerson__r.BoneDate__c);
        } else {
          // Format the date when outputting CSV (because it is output in UTC format)
          m.put('DeceasedDate', String.valueOf(d.DeceasedDate__c));
          m.put('BoneDate', String.valueOf(d.DeceasedPerson__r.BoneDate__c));
        }
        m.put('Remains', d.DeceasedPerson__r.Remains__c);

        dataList.add(m);
      }

      return dataList;
    }
}