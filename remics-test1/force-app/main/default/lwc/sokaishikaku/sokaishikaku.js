import { LightningElement, api, wire, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom Method
import getQualifiedDonorsByDate from '@salesforce/apex/PersonDao.getQualifiedDonorsByDate';
import getUnqualifiedDonorsByDate from '@salesforce/apex/PersonDao.getUnqualifiedDonorsByDate';
import updatePersons from '@salesforce/apex/PersonDao.updatePersons';

// Person Object Custom Item
import PARLIAMENTARYQUALIFICATION_FIELD from '@salesforce/schema/Person__c.ParliamentaryQualification__c';
import NAME_FIELD from '@salesforce/schema/Person__c.Name';
import FURIGANA_FIELD from '@salesforce/schema/Person__c.WholeNameFurigana__c';
import PERSONTYPE_FIELD from '@salesforce/schema/Person__c.PersonType__c';
import RELATIONSHIP_FIELD from '@salesforce/schema/Person__c.RelationshipFromHouseholder__c';
import DONATIONUNITCLASS_FIELD from '@salesforce/schema/Person__c.DonationUnitClass__c';
import DECEASED_FIELD from '@salesforce/schema/Person__c.Deceased__c';
import POSTALCODE_FIELD from '@salesforce/schema/Person__c.PostalCode__c';
import ADDRESS_FIELD from '@salesforce/schema/Person__c.AddressAllCombined__c';

// Qualified Person Candidate List Item
const TABLE_COLUMNS = [
    { label: '総会議員資格あり', fieldName: PARLIAMENTARYQUALIFICATION_FIELD.fieldApiName, type: 'boolean', editable: true },
    { label: '名前', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: 'ふりがな', fieldName: FURIGANA_FIELD.fieldApiName, type: 'text' },
    { label: '会員区分', fieldName: PERSONTYPE_FIELD.fieldApiName, type: 'text' },
    { label: '世帯主から見た続柄', fieldName: RELATIONSHIP_FIELD.fieldApiName, type: 'text' },
    { label: '献金単位区分', fieldName: DONATIONUNITCLASS_FIELD.fieldApiName, type: 'text' },
    { label: '期間内の月次献金数', fieldName: 'DonationNum', type: 'text' },
    { label: '召天', fieldName: DECEASED_FIELD.fieldApiName, type: 'text' },
    { label: '郵便番号', fieldName: POSTALCODE_FIELD.fieldApiName, type: 'text' },
    { label: '住所', fieldName: ADDRESS_FIELD.fieldApiName, type: 'text' }
];

export default class Sokaishikaku extends LightningElement {
    // Donation Record Search Form
    @api dateFrom;
    @api dateTo;

    // Qualified Person Candidate List
    @track qualifiedPersonData;
    @track unQualifiedPersonData;
    tableColumns = TABLE_COLUMNS;
    draftValues = [];

    getQualifiedPerson() {
        getQualifiedDonorsByDate({ dateFrom: this.dateFrom, dateTo: this.dateTo }).then(data => {
            let tempPersonList = [];

            data.forEach((record) => {
                let tempPerson = Object.assign({}, record);
                // Calc and store the number of monthly donations during the period
                tempPerson.DonationNum = tempPerson.DonorRef__r.length;
                tempPersonList.push(tempPerson);
            });

            this.qualifiedPersonData = tempPersonList;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '総会議員資格 候補者一覧表の取得中にエラーが発生しました',
                    message: error.message,
                    variant: 'error',
                    mode: 'sticky'
                })
          );
        });
    };

    getUnqualifiedPerson() {
        getUnqualifiedDonorsByDate({ dateFrom: this.dateFrom, dateTo: this.dateTo }).then(data => {
            let tempPersonList = [];

            data.forEach((record) => {
                let tempPerson = Object.assign({}, record);
                tempPerson.DonationNum = tempPerson.DonorRef__r ? tempPerson.DonorRef__r.length : 0;
                tempPersonList.push(tempPerson);
            });

            this.unQualifiedPersonData = tempPersonList;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '総会議員資格 非候補者一覧表の取得中にエラーが発生しました',
                    message: error.message,
                    variant: 'error',
                    mode: 'sticky'
                })
          );
        });
    };

    onChangeDateFromField(event) {
        this.dateFrom = event.detail.value;
        this.getQualifiedPerson();
        this.getUnqualifiedPerson();
    };

    onChangeDateToField(event) {
        this.dateTo = event.detail.value;
        this.getQualifiedPerson();
        this.getUnqualifiedPerson();
    };

    // When you click the Save Btn of Qualified Person Candidate List
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        try {
            // Pass edited fields to the updatePersons Apex controller
            const result = await updatePersons({data: updatedFields});
            console.log(JSON.stringify("Apex updatePersons result: "+ result));

            // Display fresh data in the datatable
            await this.getQualifiedPerson();
            await this.getUnqualifiedPerson();
            this.draftValues = [];

            this.dispatchEvent(
                new ShowToastEvent({
                    title: '「総会議員資格あり」欄の更新',
                    message: '「総会議員資格あり」欄の更新に成功しました',
                    variant: 'success'
                })
            );
       } catch(error) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: '「総会議員資格あり」欄の更新または再描画中にエラーが発生しました',
                       message: 'Message:{0},  Stacktrace:{1}',
                       messageData: [error.message, error.stack],
                       variant: 'error',
                       mode: 'sticky'
                   })
             );
        };
    };

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.draftValues = [];
    }
}