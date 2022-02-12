trigger DonationTrigger on Donation__c (before insert, before update) {

    System.debug('DonationTrigger on');

    for(Donation__c d : Trigger.New) {

        Boolean isInsert = Trigger.isInsert;
        Boolean isUpdateDate;
        if(Trigger.isUpdate){
            Donation__c oldDonation = Trigger.oldMap.get(d.id);
            isUpdateDate = (oldDonation.DonationStartDate__c != d.DonationStartDate__c) || (oldDonation.DonationFinishDate__c != d.DonationFinishDate__c);
        }
        Boolean isMain = d.DonationMainOrSub__c == 'メイン献金';

        /*
            - 新規作成または「開始日」「終了日」のいずれかの更新のとき
            - 「メイン／サブ献金」=「メイン献金」
        のみ作動させる */
        Boolean isTriggerOn = (isInsert || isUpdateDate) && isMain;
        if(!isTriggerOn){
            continue;
        }

        // 「献金年月」項目値の作成
        System.debug('Create DonationYearMonth');
        System.debug('Donation Name: ' + d.name);

        d.DonationYearMonth__c = DuplicateDonationUtil.createDonationYearMonth(d);

        System.debug('Donation DonationYearMonth: ' + d.DonationYearMonth__c);

        // 月次献金の場合のみ
        if('1'.equals(d.DonationType__c)){

            // 献金月が同じ月次献金レコードの検索
            System.debug('Search DuplicateDonation');

            List<Donation__c> duplicateDList = DuplicateDonationUtil.getDuplicateDonation(d);

            if(duplicateDList.size() > 0){
                System.debug('Exist DuplicateDonation');
                System.debug('DuplicateDonation Name: ' + duplicateDList[0].name);

                d.addError('献金月が同じ月次献金レコードがすでに存在します');
            } else {
                System.debug('Not Exist DuplicateDonation');
            }
        }
    } 
}