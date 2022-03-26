import { LightningElement, api } from 'lwc';

// Custom Method
import getJornalList from '@salesforce/apex/JornalExportController.getJornalList';
import getLastExportCondition from '@salesforce/apex/JornalExportController.getLastExportCondition';
import updateLastExportDatetime from '@salesforce/apex/JornalExportController.updateLastExportDatetime';

// Format the current date to the string [yyyy-mm-dd]
var today = new Date();
var firstDateOfMonth = `${today.getFullYear()}-${(today.getMonth()+1).toString().padStart(2, '0')}-01`;
var formattedToday = `${today.getFullYear()}-${(today.getMonth()+1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`;

const TABLE_COLUMNS = [
    { label: '納入日', fieldName: 'DonationDate', type: 'date', initialWidth: 100, editable: false },
    { label: '日付No', fieldName: 'DateNo', type: 'text', initialWidth: 100, editable: false },
    { label: 'No', fieldName: 'No', type: 'number', initialWidth: 100, editable: false },
    { label: '借方コード', fieldName: 'DebitCode', type: 'number', initialWidth: 200, editable: false },
    { label: '貸方コード', fieldName: 'CreditCode', type: 'number', initialWidth: 200, editable: false },
    { label: '献金額合計', fieldName: 'DonationAmountSum', type: 'currency', initialWidth: 200, editable: false },
    { label: '摘要', fieldName: 'DonationNote', type: 'text', initialWidth: 300, editable: false },
];

export default class JournalExport extends LightningElement {
    @api donationDateFrom = firstDateOfMonth;
    @api donationDateTo = formattedToday;

    // Journal Data "KAIKEI_IF" List
    @api kaikeiData;
    tableColumns = TABLE_COLUMNS;

    // Journal Data "SIEN_IF" List
    @api sienData;

    // Last exported datetime & search conditions
    @api lastExportDatetime;
    @api lastExportDonationDateFrom;
    @api lastExportDonationDateTo;

    constructor(){
        super();
        this.fetchLastExportCondition(true);
    }

    fetchLastExportCondition(isConstructor) {
        getLastExportCondition()
        .then(result => {
            this.lastExportDatetime = result['lastExportDatetime'];
            this.lastExportDonationDateFrom = result['donationDateFrom'];
            this.lastExportDonationDateTo = result['donationDateTo'];
            if(isConstructor && result['donationDateToTomorrow']){
                this.donationDateFrom = result['donationDateToTomorrow'];
            }
        })
        .catch(error => {
            console.log(error);
        });
    };

    onChangeDateFrom(event){
        this.donationDateFrom = event.detail.value;
    }

    onChangeDateTo(event){
        this.donationDateTo = event.detail.value;
    }

    async search() {
        await getJornalList({
            donationDateFrom: this.donationDateFrom,
            donationDateTo: this.donationDateTo,
            isKaikei: true,
            isForView: true
        })
        .then(result => {
            this.kaikeiData = result;
        })
        .catch(error => {
            console.log(error);
        });

        await getJornalList({
            donationDateFrom: this.donationDateFrom,
            donationDateTo: this.donationDateTo,
            isKaikei: false,
            isForView: true
        })
        .then(result => {
            this.sienData = result;
        })
        .catch(error => {
            console.log(error);
        });
    }

    async exportKaikeiCsv(){
        await updateLastExportDatetime({
            donationDateFrom: this.donationDateFrom,
            donationDateTo: this.donationDateTo
        });
        this.fetchLastExportCondition(false);
        let url = '/apex/journalExportKaikei';
        window.open(url, '_blank');
    };

    async exportSienCsv(){
        await updateLastExportDatetime({
            donationDateFrom: this.donationDateFrom,
            donationDateTo: this.donationDateTo
        });
        this.fetchLastExportCondition(false);
        let url = '/apex/journalExportSien';
        window.open(url, '_blank');
    };

}