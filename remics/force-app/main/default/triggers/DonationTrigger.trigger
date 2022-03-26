trigger DonationTrigger on Donation__c (before insert, before update) {

    for(Donation__c d : Trigger.New) {

        Boolean isInsert = Trigger.isInsert;
        Boolean isUpdateDate;
        if(Trigger.isUpdate){
            Donation__c oldDonation = Trigger.oldMap.get(d.id);
            isUpdateDate = (oldDonation.DonationStartDate__c != d.DonationStartDate__c) || (oldDonation.DonationFinishDate__c != d.DonationFinishDate__c);
        }
        Boolean isMain = d.DonationMainOrSub__c == 'メイン献金';

        /*
          Operate only when
            - creating or updating either "start date" or "end date"
            - "DonationMainOrSub__c" = "main donation"
         */
        Boolean isTriggerOn = (isInsert || isUpdateDate) && isMain;
        if(!isTriggerOn){
            continue;
        }

        d.DonationYearMonth__c = DuplicateDonationUtil.createDonationYearMonth(d);

        System.debug('Donation DonationYearMonth: ' + d.DonationYearMonth__c);

        // Only for monthly donations
        if('1'.equals(d.DonationType__c)){
            List<Donation__c> duplicateDList = DuplicateDonationUtil.getDuplicateDonation(d);

            if(duplicateDList.size() > 0){
                d.addError('献金月が同じ月次献金レコードがすでに存在します');
            } else {
                System.debug('Not Exist DuplicateDonation');
            }
        }
    } 
}