import { LightningElement, api, wire, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom method
import getDonationsByDonorId from '@salesforce/apex/DonationDao.getDonationsByDonorId';
import updateDonations from '@salesforce/apex/DonationDao.updateDonations';
import deleteDonationById from '@salesforce/apex/DonationDao.deleteDonationById';
import getPersonByPersonNumCurrent from '@salesforce/apex/PersonDao.getPersonByPersonNumCurrent';
import getPersonById from '@salesforce/apex/PersonDao.getPersonById';

// Donation Object
import DONATION_OBJECT from '@salesforce/schema/Donation__c';

// Donation Object Custom Item
import NAME_FIELD from '@salesforce/schema/Donation__c.Name';
import DONOR_FIELD from '@salesforce/schema/Donation__c.Donor__c';
import DONATIONTYPE_FIELD from '@salesforce/schema/Donation__c.DonationType__c';
import DONATIONDATE_FIELD from '@salesforce/schema/Donation__c.DonationDate__c';
import DONATIONAMOUNT_FIELD from '@salesforce/schema/Donation__c.DonationAmount__c';
import DONATIONSTARTDATE_FIELD from '@salesforce/schema/Donation__c.DonationStartDate__c';
import DONATIONFINISHDATE_FIELD from '@salesforce/schema/Donation__c.DonationFinishDate__c';
import DONATIONYEARMONTH_FIELD from '@salesforce/schema/Donation__c.DonationYearMonth__c';
import DONATIONNOTE_FIELD from '@salesforce/schema/Donation__c.DonationNote__c';
import ACCOUNTINGUNIT_FIELD from '@salesforce/schema/Donation__c.AccountingUnit__c';

// Row Acrtions
const actions = [
    { label: 'この行を削除', name: 'delete' }
];

// Format the current date to the string [yyyy-mm-dd]
var today = new Date();
var formattedToday = `
${today.getFullYear()}-
${(today.getMonth()+1).toString().padStart(2, '0')}-
${today.getDate().toString().padStart(2, '0')}
`.replace(/\n|\r/g, '');

// Donation List Item
const TABLE_COLUMNS = [
    { label: '献金', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: '納入日', fieldName: DONATIONDATE_FIELD.fieldApiName, type: 'date-local', editable: true },
    {
        label: '献金種類', fieldName: DONATIONTYPE_FIELD.fieldApiName, type: 'picklist', typeAttributes: {
            placeholder: '選択してください', options: [
                { label: '月次献金', value: '1' },
                { label: '夏季特別献金', value: '2' },
                { label: '冬季特別献金', value: '3' },
                { label: '多摩墓地献金', value: '4' },
                { label: '式典献金', value: '5' },
                { label: '指定献金', value: '6' },
                { label: 'イースター献金', value: '7' },
                { label: 'ペンテコステ献金', value: '8' },
                { label: '振起日献金', value: '9' },
                { label: 'クリスマス献金', value: '10' },
                { label: '誕生日献金', value: '11' },
                { label: '受洗記念日献金', value: '12' },
                { label: '結婚記念日献金', value: '13' },
                { label: '召天記念日献金', value: '14' },
                { label: 'その他感謝献金', value: '15' },
                { label: '朝礼拝', value: '18' },
                { label: '夕礼拝', value: '19' },
                { label: '伝道支援献金', value: '20' },
                { label: '会堂保全献金', value: '31' },
                { label: '愛の業献金', value: '32' },
                { label: '隠遁牧師謝恩献金', value: '33' },
                { label: '東日本大震災被災教会', value: '35' },
            ]
            , value: { fieldName: DONATIONTYPE_FIELD.fieldApiName } 
            , context: { fieldName: 'Id' }
        }
    },
    { label: '献金額', fieldName: DONATIONAMOUNT_FIELD.fieldApiName, type: 'currency', typeAttributes: { currencyCode: 'JPY', step: '1' },editable: true },
    { label: '開始日', fieldName: DONATIONSTARTDATE_FIELD.fieldApiName, type: 'date-local', editable: true },
    { label: '終了日', fieldName: DONATIONFINISHDATE_FIELD.fieldApiName, type: 'date-local', editable: true },
    { label: '献金年月', fieldName: DONATIONYEARMONTH_FIELD.fieldApiName, type: 'text', editable: false },
    { label: '摘要', fieldName: DONATIONNOTE_FIELD.fieldApiName, type: 'text', editable: true },
    { label: '会計単位', fieldName: ACCOUNTINGUNIT_FIELD.fieldApiName, type: 'text', editable: false },
    { type: 'action', typeAttributes: { rowActions: actions } }
];

export default class DonationCreationLwc extends LightningElement {
    // Donor Search Form
    @api donorId;
    @api personNumCurrent;
    @api boxNum;
    @api shelfNum;

    DonationObjectName = DONATION_OBJECT;
    donorNameField = DONOR_FIELD;

    async onChangePersonNumCurrentField(event) {
        this.personNumCurrent = event.target.value;

        if (!this.personNumCurrent) { return; }

        await getPersonByPersonNumCurrent({ personNumCurrent: this.personNumCurrent }).then(record => {
            this.donorId = record.Id;
            this.boxNum = record.WeeklyReportBoxNum__c;
            this.shelfNum = record.ShelfNum__c;
            this.fetchTableData();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '入力した「原籍番号（現在）」に該当する人は存在しません',
                    message: error.message,
                    variant: 'error',
                    mode: 'dismissible'
                })
          );
        });
    };

    onChangeDonorNameField(event) {
        this.donorId = event.detail.value[0];

        if (!this.donorId) { return; }

        getPersonById({ id: this.donorId }).then(record => {
            this.personNumCurrent = record.PersonNumCurrent__c;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '入力した「レコードID」に該当する人は存在しません',
                    message: error.message,
                    variant: 'error',
                    mode: 'dismissible'
                })
          );
        });
    };

    // New Donation Record Input Form
    donationFields = [NAME_FIELD, DONOR_FIELD, DONATIONTYPE_FIELD, DONATIONDATE_FIELD, DONATIONAMOUNT_FIELD, DONATIONSTARTDATE_FIELD, DONATIONFINISHDATE_FIELD, DONATIONNOTE_FIELD];
    donationTypeField = DONATIONTYPE_FIELD;
    donationDateField = DONATIONDATE_FIELD;
    donationAmountField = DONATIONAMOUNT_FIELD;
    donationStartdateField = DONATIONSTARTDATE_FIELD;
    donationFinishdateField = DONATIONFINISHDATE_FIELD;
    donationNoteField = DONATIONNOTE_FIELD;

    @api donationTypeVal;
    @api donationMonthNumVal = 1;
    @api donationAmountAveVal = 0;

    onChangeDonationTypeNumField(event) {
        this.donationTypeVal = event.target.value;
    };

    onChangeDonationAmountField(event) {
        const donationAmount = this.template.querySelector('.donationAmount').value;
        const donationMonthNum = this.template.querySelector('.donationMonthNum').value;

        if(!donationAmount || !donationMonthNum || donationMonthNum == 0) { 
            this.donationAmountAveVal = 0;
        }

        this.donationAmountAveVal = (donationAmount / donationMonthNum);
    };

    onChangeDonationStartOrFinishdate() {
        const startdateStr = this.template.querySelector('.donationStartdate').value;
        const finishdateStr = this.template.querySelector('.donationFinishdate').value;
        if(!startdateStr || !finishdateStr) {return;}

        const startdate = new Date(startdateStr);
        const finishdate = new Date(finishdateStr);
        const startMonth = startdate.getFullYear() * 12 + startdate.getMonth();
        const finishMonth = finishdate.getFullYear() * 12 + finishdate.getMonth();
       
        this.donationMonthNumVal = finishMonth - startMonth + 1;

        this.onChangeDonationAmountField();
    };
    
    async handleInsertSuccess(event) {
        // Display fresh data in the datatable
        await this.fetchTableData();
        this.draftValues = [];

        const inputFields = this.template.querySelectorAll('.resetField');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: "新規献金レコードの登録",
                message: "新規献金レコードに成功しました(レコード名:{0}, 献金額:{1})",
                messageData: [event.detail.fields.Name.value, event.detail.fields.DonationAmount__c.displayValue],
                variant: "success",
                mode: "pester"
            })
        );

        this.template.querySelector('.personNumCurrent').focus();
    };

    // Donation List
    @api donationDateFrom = formattedToday;
    @api donationDateTo = formattedToday;
    @api donationSum = 0;

    // Data of Donation List
    @api tableData;

    tableColumns = TABLE_COLUMNS;
    draftValues = [];
    lastSavedData = [];

    calcDonationSum() {
        let sum = 0;
        for (const record of this.tableData) {
            sum += Number(record.DonationAmount__c);
          }
        this.donationSum = sum;
    }

    async fetchTableData(){
        await getDonationsByDonorId({ donorId: this.donorId, donationDateFrom: this.donationDateFrom, donationDateTo: this.donationDateTo })
            .then( result => {
                this.tableData = result;
                this.calcDonationSum();
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '献金一覧表データの取得に失敗しました',
                        message: error.message,
                        variant: 'error',
                        mode: 'dismissible'
                    })
                );
            });
    };

    onChangeDonationDateFromField(event) {
        this.donationDateFrom = event.detail.value;
        this.fetchTableData();
    };

    onChangeDonationDateToField(event) {
        this.donationDateTo = event.detail.value;
        this.fetchTableData();
    };

    // When the inline edit of the donation list is saved successfully
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
        try {
            // Pass edited fields to the updateDonations Apex controller
            const result = await updateDonations({data: updatedFields});
            console.log(JSON.stringify("Apex updateDonations result: "+ result));
    
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);

            // Display fresh data in the datatable
            await this.fetchTableData();

            // Clear all draft values in the datatable
            this.draftValues = [];
            this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: '献金一覧の更新',
                    message: '献金一覧の更新に成功しました',
                    variant: 'success',
                    mode: "pester"
                })
            );

            this.template.querySelector('.personNumCurrent').focus();
       } catch(error) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: '献金一覧の更新または再描画中にエラーが発生しました',
                       message: 'Message:{0},  Stacktrace:{1}',
                       messageData: [error.body.message, error.body.stackTrace],
                       variant: 'error',
                       mode: 'sticky'
                   })
             );
        };
    };

    // Remove draftValues & revert data changes
    handleCancel(event) {
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.tableData));
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    if(field !== 'Id'){
                        item[field] = updateItem[field];
                    }
                }
            }
        });

        //write changes back to original data
        this.tableData = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        // store changed value to do operations on save.
        // This will enable inline editing & show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    // When the item "Donation type" is changed
    // Sent from DatatablePicklist.js
    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, DonationType__c: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    // When doing inline editing
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    // Deleted a row in the donation list
    @track isDialogVisible = false;
    @track deletingRecordId;
    @track displayMessage = 'この献金レコードを削除してよろしいでしょうか？';
    @track displayMessage2;

    // Row action of Donation list
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'delete':
                this.deletingRecordId = event.detail.row.Id;
                this.isDialogVisible = true;
                this.displayMessage2 = '[ レコード名:' + event.detail.row.Name + ' | 納入日:' + event.detail.row.DonationDate__c + ' | 献金額:' + event.detail.row.DonationAmount__c + '円 ]';
                break;
            default:
        }
    }

    // When you click the donation record deletion confirmation dialog
    clickConfirmDialog(event){
        if(event.target.name === 'confirmModal'){

            // When user clicks outside of the dialog area,
            // the event is dispatched with detail value as 1
            if(event.detail !== 1){
                console.log('[ConfirmDialog] Status: ' + event.detail.status + ', DeletingRecordId: ' + JSON.stringify(event.detail.originalMessage) + '.');

                if(event.detail.status === 'confirm') {
                    this.deleteRow(event.detail.originalMessage);
                }
            }

            this.isDialogVisible = false;
        }
    }

    async deleteRow(id) {
        try {
            const result = await deleteDonationById({id: id});
            console.log("[Apex result] " + result);

            // Display fresh data in the datatable
            await this.fetchTableData();
            this.draftValues = [];

            this.dispatchEvent(
                new ShowToastEvent({
                    title: '献金レコードの削除',
                    message: '献金レコードの削除に成功しました',
                    variant: 'success',
                    mode: "pester"
                })
            );

            this.template.querySelector('.personNumCurrent').focus();
        } catch(error) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: '献金レコードの削除中にエラーが発生しました',
                       message: 'Message:{0},  Stacktrace:{1}',
                       messageData: [error.body.message, error.body.stackTrace],
                       variant: 'error',
                       mode: 'sticky'
                   })
             );
        };
    }
}