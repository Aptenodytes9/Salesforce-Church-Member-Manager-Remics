import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import DONATION_OBJECT from '@salesforce/schema/Donation__c';
import NAME_FIELD from '@salesforce/schema/Donation__c.Name';
import DONATIONTYPE_FIELD from '@salesforce/schema/Donation__c.DonationType__c';
import DONATIONDATE_FIELD from '@salesforce/schema/Donation__c.DonationDate__c';
import DONOR_FIELD from '@salesforce/schema/Donation__c.Donor__c';
import DONATIONAMOUNT_FIELD from '@salesforce/schema/Donation__c.DonationAmount__c';
import DONATIONSTARTDATE_FIELD from '@salesforce/schema/Donation__c.DonationStartDate__c';
import DONATIONFINISHDATE_FIELD from '@salesforce/schema/Donation__c.DonationFinishDate__c';
import DONATIONNOTE_FIELD from '@salesforce/schema/Donation__c.DonationNote__c';


import DONOR_NAME_FIELD from '@salesforce/schema/Donation__c.Donor__c';

export default class DonationCreationLwc extends LightningElement {
    objectApiName = DONATION_OBJECT;
    fields = [NAME_FIELD, DONATIONTYPE_FIELD, DONATIONDATE_FIELD, DONOR_FIELD, DONATIONAMOUNT_FIELD, DONATIONSTARTDATE_FIELD, DONATIONFINISHDATE_FIELD, DONATIONNOTE_FIELD];

    donor_name_field = DONOR_NAME_FIELD;
    
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: "献金の登録",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    };

    onChangeDonorNameField(event) {
      // カスタムイベントから値を取得
      console.log(event.detail.value[0]);
    };
}