import { LightningElement, api } from 'lwc';

// カスタムメソッド
import getSurvivorHouseholdList from '@salesforce/apex/ShotenshaWorshipController.getSurvivorHouseholdList';

const TABLE_COLUMNS = [
    { label: '世帯名', fieldName: 'SurvivorHouseholdName', type: 'text', initialWidth: 100, editable: false },
    { label: '郵便番号', fieldName: 'PostalCode', type: 'text', initialWidth: 100, editable: false },
    { label: '住所', fieldName: 'AddressAllCombined', type: 'text', initialWidth: 200, editable: false },
    { label: '世帯主名', fieldName: 'HouseholderName', type: 'text', initialWidth: 100, editable: false },
    { label: '連名1', fieldName: 'JointSignature1', type: 'text', initialWidth: 100, editable: false },
    { label: '連名2', fieldName: 'JointSignature2', type: 'text', initialWidth: 100, editable: false },
    { label: '連名3', fieldName: 'JointSignature3', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名1', fieldName: 'DeceasedPersonName1', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年1', fieldName: 'DeceasedDateCat1', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名2', fieldName: 'DeceasedPersonName2', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年2', fieldName: 'DeceasedDateCat2', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名3', fieldName: 'DeceasedPersonName3', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年3', fieldName: 'DeceasedDateCat3', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名4', fieldName: 'DeceasedPersonName4', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年4', fieldName: 'DeceasedDateCat4', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名5', fieldName: 'DeceasedPersonName5', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年5', fieldName: 'DeceasedDateCat5', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名6', fieldName: 'DeceasedPersonName6', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年6', fieldName: 'DeceasedDateCat6', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名7', fieldName: 'DeceasedPersonName7', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年7', fieldName: 'DeceasedDateCat7', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名8', fieldName: 'DeceasedPersonName8', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年8', fieldName: 'DeceasedDateCat8', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名9', fieldName: 'DeceasedPersonName9', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年9', fieldName: 'DeceasedDateCat9', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名10', fieldName: 'DeceasedPersonName10', type: 'text', initialWidth: 110, editable: false },
    { label: '召天年10', fieldName: 'DeceasedDateCat10', type: 'text', initialWidth: 100, editable: false }
];

export default class ShotenshaWorshipSurvivorList extends LightningElement {
    // 検索日付入力フォーム
    @api year;
    @api thisYearFrom;
    @api thisYearTo;
    @api lastYearFrom;
    @api lastYearTo;
    @api fiveYearFrom;
    @api fiveYearTo;
    @api tenYearFrom;
    @api tenYearTo;
    @api fifteenYearFrom;
    @api fifteenYearTo;
    @api twentyYearFrom;
    @api twentyYearTo;
    @api twentyFiveYearFrom;
    @api twentyFiveYearTo;

    // 「処理年度」欄を変更したとき
    onChangeYear(event) {
        this.year = event.detail.value;

        this.thisYearFrom = (this.year - 1) + '-11-01';
        this.thisYearTo = this.year + '-10-31';

        this.lastYearFrom = (this.year - 2) + '-11-01';
        this.lastYearTo = (this.year - 1) + '-10-31';

        this.fiveYearFrom = (this.year - 5) + '-01-01';
        this.fiveYearTo = (this.year - 5) + '-12-31';

        this.tenYearFrom = (this.year - 10) + '-01-01';
        this.tenYearTo = (this.year - 10) + '-12-31';
        
        this.fifteenYearFrom = (this.year - 15) + '-01-01';
        this.fifteenYearTo = (this.year - 15) + '-12-31';
        
        this.twentyYearFrom = (this.year - 20) + '-01-01';
        this.twentyYearTo = (this.year - 20) + '-12-31';
        
        this.twentyFiveYearFrom = (this.year - 25) + '-01-01';
        this.twentyFiveYearTo = (this.year - 25) + '-12-31';
    };

    onChangeThisYearFrom(event) {
        this.thisYearFrom = event.detail.value;
    };

    onChangeThisYearTo(event) {
        this.thisYearTo = event.detail.value;
    };

    onChangelastYearFrom(event) {
        this.lastYearFrom = event.detail.value;
    };

    onChangelastYearTo(event) {
        this.thisYearTo = event.detail.value;
    };

    // 遺族一覧表
    @api tableData;
    tableColumns = TABLE_COLUMNS;

    search() {
        const dateArray = [ this.thisYearFrom, this.thisYearTo, this.lastYearFrom, this.lastYearTo, this.fiveYearFrom, this.fiveYearTo, this.tenYearFrom, this.tenYearTo, this.fifteenYearFrom, this.fifteenYearTo, this.twentyYearFrom, this.twentyYearTo, this.twentyFiveYearFrom, this.twentyFiveYearTo ];
        
        getSurvivorHouseholdList({
            dateList: dateArray,
            isForView: true
        })
        .then(result => {
            this.tableData = result;
        })
        .catch(error => {
            console.log(error);
        });
    }

    exportCsv(){
       let url = '/apex/shotenshaWorshipSurvivorList';
       window.open(url, '_blank');
    };

}