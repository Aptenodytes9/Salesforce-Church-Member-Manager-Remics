import { LightningElement, api, wire } from 'lwc';

// カスタムメソッド
import getDonationsByDate from '@salesforce/apex/DonationDao.getDonationsByDate';
import getShuhoData from '@salesforce/apex/ShuhoDataPrintUtil.getShuhoData';

// 献金オブジェクト
import DONATION_OBJECT from '@salesforce/schema/Donation__c';

// 献金オブジェクト カスタム項目
import NAME_FIELD from '@salesforce/schema/Donation__c.Name';
import DONATIONTYPE_FIELD from '@salesforce/schema/Donation__c.DonationType__c';
import DONATIONDATE_FIELD from '@salesforce/schema/Donation__c.DonationDate__c';
import DONORNAME_FIELD from '@salesforce/schema/Donation__c.DonorName__c';
import DONATIONSPOUSENAME_FIELD from '@salesforce/schema/Donation__c.DonationSpouseName__c';
import DONATIONFAMILYNAME__C_FIELD from '@salesforce/schema/Donation__c.DonationFamilyName__c';
import DONATIONAMOUNT_FIELD from '@salesforce/schema/Donation__c.DonationAmount__c';
import DONATIONMONTHSTR_FIELD from '@salesforce/schema/Donation__c.DonationMonthStr__c';
import DONATIONSTARTDATE_FIELD from '@salesforce/schema/Donation__c.DonationStartDate__c';
import DONATIONFINISHDATE_FIELD from '@salesforce/schema/Donation__c.DonationFinishDate__c';
import DONATIONNOTE_FIELD from '@salesforce/schema/Donation__c.DonationNote__c';
import DONATIONMAINORSUB_FIELD from '@salesforce/schema/Donation__c.DonationMainOrSub__c';

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
    { label: '献金種類', fieldName: DONATIONTYPE_FIELD.fieldApiName, type: 'text' },
    { label: '納入日', fieldName: DONATIONDATE_FIELD.fieldApiName, type: 'date-local', editable: false },
    { label: '献金者', fieldName: DONORNAME_FIELD.fieldApiName, type: 'text', editable: false },
    { label: '献金者配偶者名', fieldName: DONATIONSPOUSENAME_FIELD.fieldApiName, type: 'text', editable: false },
    { label: '献金者家族名', fieldName: DONATIONFAMILYNAME__C_FIELD.fieldApiName, type: 'text', editable: false },
    { label: '献金額', fieldName: DONATIONAMOUNT_FIELD.fieldApiName, type: 'currency', typeAttributes: { currencyCode: 'JPY', step: '1' },editable: false },
    { label: '開始日', fieldName: DONATIONSTARTDATE_FIELD.fieldApiName, type: 'date-local', editable: false },
    { label: '終了日', fieldName: DONATIONFINISHDATE_FIELD.fieldApiName, type: 'date-local', editable: false },
    { label: '献金月', fieldName: DONATIONMONTHSTR_FIELD.fieldApiName, type: 'text', editable: false },
    { label: '摘要', fieldName: DONATIONNOTE_FIELD.fieldApiName, type: 'text', editable: false },
    { label: 'メイン／サブ献金', fieldName: DONATIONMAINORSUB_FIELD.fieldApiName, type: 'text', editable: false }
];

export default class ShuhoDataPrint extends LightningElement {
    // 献金レコード検索フォーム
    @api donationDateFrom = formattedToday;
    @api donationDateTo = formattedToday;
    @api tableTitle;

    DonationObjectName = DONATION_OBJECT;

    // 要素がドキュメントに挿入されるとき
    connectedCallback(){
        this.changeTableTitle();
    }

    changeTableTitle(){
        this.tableTitle = this.donationDateFrom + "から" + this.donationDateTo + "に納入された献金の一覧";
    }

    // 「納入日（から）」欄を変更したとき
    onChangeDonationDateFromField(event) {
        this.donationDateFrom = event.detail.value;
        this.changeTableTitle();
    };
    // 「納入日（まで）」欄を変更したとき
    onChangeDonationDateToField(event) {
        this.donationDateTo = event.detail.value;
        this.changeTableTitle();
    };

    // 献金一覧表
    @wire(getDonationsByDate, { donationDateFrom: '$donationDateFrom', donationDateTo: '$donationDateTo' }) tableData;
    tableColumns = TABLE_COLUMNS;

    @wire(getShuhoData, { donationDateFrom: '$donationDateFrom', donationDateTo: '$donationDateTo' }) shuhoData;
}