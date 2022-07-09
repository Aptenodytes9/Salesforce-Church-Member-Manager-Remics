import { LightningElement, api, wire, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// カスタムメソッド
import getDonationsByDonorId from '@salesforce/apex/DonationDao.getDonationsByDonorId';
import updateDonations from '@salesforce/apex/DonationDao.updateDonations';
import deleteDonationById from '@salesforce/apex/DonationDao.deleteDonationById';
import getAlivePersonByPersonNumCurrent from '@salesforce/apex/PersonDao.getAlivePersonByPersonNumCurrent';
import getPersonById from '@salesforce/apex/PersonDao.getPersonById';

// 献金オブジェクト
import DONATION_OBJECT from '@salesforce/schema/Donation__c';

// 献金オブジェクト カスタム項目
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

// 行アクション
const actions = [
    { label: 'この行を削除', name: 'delete' }
];

// 現在日付を文字列[yyyy-mm-dd]にフォーマットする
var today = new Date();
var formattedToday = `
${today.getFullYear()}-
${(today.getMonth()+1).toString().padStart(2, '0')}-
${today.getDate().toString().padStart(2, '0')}
`.replace(/\n|\r/g, '');

// 献金一覧表 項目
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
                { label: 'ハルモニウム特別献金', value: '34' },
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
    // 献金者検索フォーム
    @api donorId;
    @api personNumCurrent;
    @api donationUnitClass;
    @api boxNum;
    @api shelfNum;

    DonationObjectName = DONATION_OBJECT;
    donorNameField = DONOR_FIELD;

    // 「原籍番号（現在）」欄を変更したとき
    async onChangePersonNumCurrentField(event) {
        this.personNumCurrent = event.target.value;

        if (!this.personNumCurrent) { return; }

        // 原籍番号からレコードIDを取得
        await getAlivePersonByPersonNumCurrent({ personNumCurrent: this.personNumCurrent }).then(record => {
            this.donorId = record.Id;
            this.donationUnitClass = record.DonationUnitClass__c;
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

    // 「献金者」欄を変更したとき
    onChangeDonorNameField(event) {
        this.donorId = event.detail.value[0];

        if (!this.donorId) { return; }

        // レコードIDから原籍番号を取得
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

    // 新規献金レコード入力フォーム
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

    // 「献金種類」欄（数字）を変更したとき
    onChangeDonationTypeNumField(event) {
        this.donationTypeVal = event.target.value;
    };

    // 「献金額」欄を変更したとき
    onChangeDonationAmountField(event) {
        const donationAmount = this.template.querySelector('.donationAmount').value;
        const donationMonthNum = this.template.querySelector('.donationMonthNum').value;

        if(!donationAmount || !donationMonthNum || donationMonthNum == 0) { 
            this.donationAmountAveVal = 0;
        }

        // 「献金額（月当たり）」を計算
        this.donationAmountAveVal = (donationAmount / donationMonthNum);
    };

    // 「開始日」「終了日」欄を変更したとき
    onChangeDonationStartOrFinishdate() {
        const startdateStr = this.template.querySelector('.donationStartdate').value;
        const finishdateStr = this.template.querySelector('.donationFinishdate').value;
        if(!startdateStr || !finishdateStr) {return;}

        const startdate = new Date(startdateStr);
        const finishdate = new Date(finishdateStr);
        const startMonth = startdate.getFullYear() * 12 + startdate.getMonth();
        const finishMonth = finishdate.getFullYear() * 12 + finishdate.getMonth();
       
        this.donationMonthNumVal = finishMonth - startMonth + 1;

        const donationAmount = this.template.querySelector('.donationAmount').value;

        if(!donationAmount || !this.donationMonthNumVal || this.donationMonthNumVal == 0) { 
            this.donationAmountAveVal = 0;
        }

        // 「献金額（月当たり）」を計算
        this.donationAmountAveVal = (donationAmount / this.donationMonthNumVal);
    };
    
    // 新規献金レコードの作成に成功したとき
    async handleInsertSuccess(event) {
        // Display fresh data in the datatable
        await this.fetchTableData();
        this.draftValues = [];

        // 開始日・終了日・献金額・摘要の各入力欄をリセット
        // reset method をcallできるのはlightning-input-field tagのみ
        // lightning-input tagを利用している項目は不可
        const inputFields = this.template.querySelectorAll('.resetField');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        // 月数・献金額（月当たり）欄をリセット
        this.donationMonthNumVal = 1;
        this.donationAmountAveVal = 0;

        this.dispatchEvent(
            new ShowToastEvent({
                title: "新規献金レコードの登録",
                message: "新規献金レコードに成功しました(レコード名:{0}, 献金額:{1})",
                messageData: [event.detail.fields.Name.value, event.detail.fields.DonationAmount__c.displayValue],
                variant: "success",
                mode: "pester"
            })
        );

        // 「原籍番号（現在）」欄にフォーカスをセット
        this.template.querySelector('.personNumCurrent').focus();
    };

    // 献金一覧表
    @api donationDateFrom = formattedToday;
    @api donationDateTo = formattedToday;

    // 献金額合計
    @api donationSum = 0;
    
    // 献金一覧表のデータ
    @api tableData;

    tableColumns = TABLE_COLUMNS;
    draftValues = [];
    lastSavedData = [];

    // 献金額合計を計算
    calcDonationSum() {
        let sum = 0;
        for (const record of this.tableData) {
            sum += Number(record.DonationAmount__c);
          }
        this.donationSum = sum;
    }

    // 献金一覧表のデータを取得
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

    // 「納入日（から）」欄を変更したとき
    onChangeDonationDateFromField(event) {
        this.donationDateFrom = event.detail.value;
        this.fetchTableData();
    };
    // 「納入日（まで）」欄を変更したとき
    onChangeDonationDateToField(event) {
        this.donationDateTo = event.detail.value;
        this.fetchTableData();
    };

    // 献金一覧表のインライン編集の保存が成功したとき
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

            // 「原籍番号（現在）」欄にフォーカスをセット
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

    handleCancel(event) {
        //remove draftValues & revert data changes
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

    // 選択リスト項目「献金種類」の値を変更したとき
    // sent from DatatablePicklist.js
    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, DonationType__c: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    // インライン編集をしたとき
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    // 献金一覧表の行削除
    @track isDialogVisible = false;
    @track deletingRecordId;
    @track displayMessage = 'この献金レコードを削除してよろしいでしょうか？';
    @track displayMessage2;

    // 献金一覧表の行アクション
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

    // 献金レコード削除確認ダイアログをクリックしたとき
    clickConfirmDialog(event){
        if(event.target.name === 'confirmModal'){

            //when user clicks outside of the dialog area, the event is dispatched with detail value as 1
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

            // 「原籍番号（現在）」欄にフォーカスをセット
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