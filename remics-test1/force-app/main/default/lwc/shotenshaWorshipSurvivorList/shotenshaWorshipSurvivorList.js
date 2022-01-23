import { LightningElement, api } from 'lwc';

// カスタムメソッド
import getSurvivorHouseholdList from '@salesforce/apex/ShotenshaWorshipController.getSurvivorHouseholdList';
import getDeceasedList from '@salesforce/apex/ShotenshaWorshipController.getDeceasedList';
import getSurvivorList from '@salesforce/apex/ShotenshaWorshipController.getSurvivorList';

const ATENA_TABLE_COLUMNS = [
    { label: '世帯名', fieldName: 'SurvivorHouseholdName', type: 'text', initialWidth: 100, editable: false },
    { label: '郵便番号', fieldName: 'PostalCode', type: 'text', initialWidth: 100, editable: false },
    { label: '住所', fieldName: 'AddressAllCombined', type: 'text', initialWidth: 200, editable: false },
    { label: '世帯主名', fieldName: 'HouseholderName', type: 'text', initialWidth: 100, editable: false },
    { label: '連名1', fieldName: 'JointSignature1', type: 'text', initialWidth: 100, editable: false },
    { label: '連名2', fieldName: 'JointSignature2', type: 'text', initialWidth: 100, editable: false },
    { label: '連名3', fieldName: 'JointSignature3', type: 'text', initialWidth: 100, editable: false },

    { label: '召天者名1', fieldName: 'DeceasedPersonName1', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年1', fieldName: 'DeceasedDateCat1', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名2', fieldName: 'DeceasedPersonName2', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年2', fieldName: 'DeceasedDateCat2', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名3', fieldName: 'DeceasedPersonName3', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年3', fieldName: 'DeceasedDateCat3', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名4', fieldName: 'DeceasedPersonName4', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年4', fieldName: 'DeceasedDateCat4', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名5', fieldName: 'DeceasedPersonName5', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年5', fieldName: 'DeceasedDateCat5', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名6', fieldName: 'DeceasedPersonName6', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年6', fieldName: 'DeceasedDateCat6', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名7', fieldName: 'DeceasedPersonName7', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年7', fieldName: 'DeceasedDateCat7', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名8', fieldName: 'DeceasedPersonName8', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年8', fieldName: 'DeceasedDateCat8', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名9', fieldName: 'DeceasedPersonName9', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年9', fieldName: 'DeceasedDateCat9', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },

    { label: '召天者名10', fieldName: 'DeceasedPersonName10', type: 'text', initialWidth: 110, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天年10', fieldName: 'DeceasedDateCat10', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } }
];

const D_TABLE_COLUMNS = [
    // 召天者
    { label: '召天年', fieldName: 'DeceasedDateCat', type: 'text', initialWidth: 100, editable: false },
    { label: '召天者会員区分', fieldName: 'DeceasedPersonType', type: 'text', initialWidth: 150, editable: false },
    { label: '召天者原簿番号', fieldName: 'DeceasedPersonNumCurrent', type: 'text', initialWidth: 150, editable: false },
    { label: '召天者名', fieldName: 'DeceasedPersonName', type: 'text', initialWidth: 150, editable: false },
    { label: '召天日', fieldName: 'DeceasedDate', type: 'text', initialWidth: 100, editable: false },
    { label: '納骨日', fieldName: 'BoneDate', type: 'text', initialWidth: 100, editable: false },
    { label: '御遺影有無', fieldName: 'Remains', type: 'text', initialWidth: 100, editable: false },
    // 遺族
    { label: '遺族名', fieldName: 'SurvivorName', type: 'text', initialWidth: 150, editable: false,
    cellAttributes: { class: 'slds-theme_shade' } },
    { label: '遺族原簿番号', fieldName: 'SurvivorPersonNumCurrent', type: 'text', initialWidth: 150, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '遺族続柄', fieldName: 'SurvivorRelationship', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '遺族召天案内', fieldName: 'CelestialWorshipShipment', type: 'text', initialWidth: 150, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    // 世帯
    { label: '郵便番号', fieldName: 'PostalCode', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '住所', fieldName: 'AddressAllCombined', type: 'text', initialWidth: 400, editable: false, cellAttributes: { class: 'slds-theme_shade' } }
];

const S_TABLE_COLUMNS = [
    // 遺族
    { label: '遺族原簿番号', fieldName: 'SurvivorPersonNumCurrent', type: 'text', initialWidth: 150, editable: false },
    { label: '遺族名', fieldName: 'SurvivorName', type: 'text', initialWidth: 150, editable: false },
    { label: '遺族会員区分', fieldName: 'SurvivorPersonType', type: 'text', initialWidth: 150, editable: false },
    // 世帯
    { label: '郵便番号', fieldName: 'PostalCode', type: 'text', initialWidth: 100, editable: false },
    { label: '住所', fieldName: 'AddressAllCombined', type: 'text', initialWidth: 400, editable: false },
    { label: '遺族続柄', fieldName: 'SurvivorRelationship', type: 'text', initialWidth: 100, editable: false },
    { label: '遺族召天案内', fieldName: 'CelestialWorshipShipment', type: 'text', initialWidth: 150, editable: false },
    // 召天者
    { label: '召天年', fieldName: 'DeceasedDateCat', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天者会員区分', fieldName: 'DeceasedPersonType', type: 'text', initialWidth: 150, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天者原簿番号', fieldName: 'DeceasedPersonNumCurrent', type: 'text', initialWidth: 150, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天者名', fieldName: 'DeceasedPersonName', type: 'text', initialWidth: 150, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '召天日', fieldName: 'DeceasedDate', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '納骨日', fieldName: 'BoneDate', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } },
    { label: '御遺影有無', fieldName: 'Remains', type: 'text', initialWidth: 100, editable: false, cellAttributes: { class: 'slds-theme_shade' } }
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

    constructor(){
        super();
        this.onChangeYear();
    }

    // 「処理年度」欄を変更したとき
    async onChangeYear(event) {
        await this.fillThisYear(event);
        this.fillYearInputs();
    };

    async fillThisYear(event){
        if(event && event.detail.value){
            this.year = event.detail.value;
        } else {
            this.year = new Date().getFullYear();
        }
    }

    fillYearInputs(){
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
    }

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

    // 遺族宛案内 送付先世帯 一覧
    @api atenaListTableData;
    aTableColumns = ATENA_TABLE_COLUMNS;

    // 召天者-遺族 一覧
    @api deceasedListTableData;
    dTableColumns = D_TABLE_COLUMNS;

    // 遺族-召天者 一覧
    @api survivorListTableData;
    sTableColumns = S_TABLE_COLUMNS;

    async search() {
        const dateArray = [ this.thisYearFrom, this.thisYearTo, this.lastYearFrom, this.lastYearTo, this.fiveYearFrom, this.fiveYearTo, this.tenYearFrom, this.tenYearTo, this.fifteenYearFrom, this.fifteenYearTo, this.twentyYearFrom, this.twentyYearTo, this.twentyFiveYearFrom, this.twentyFiveYearTo ];

        await getSurvivorHouseholdList({
            dateList: dateArray,
            isForView: true
        })
        .then(result => {
            this.atenaListTableData = result;
        })
        .catch(error => {
            console.log(error);
        });

        await getDeceasedList({
            dateList: dateArray,
            isForView: true
        })
        .then(result => {
            this.deceasedListTableData = result;
        })
        .catch(error => {
            console.log(error);
        });

        await getSurvivorList({
            dateList: dateArray,
            isForView: true
        })
        .then(result => {
            this.survivorListTableData = result;
        })
        .catch(error => {
            console.log(error);
        });
    }

    // 遺族宛案内 送付先世帯 一覧を出力
    exportAtenaCsv(){
       let url = '/apex/shotenshaWorshipSurvivorList';
       window.open(url, '_blank');
    };

    // 召天者-遺族 一覧を出力
    exportDeceasedListCsv(){
       let url = '/apex/deceasedList';
       window.open(url, '_blank');
    };

    // 遺族-召天者 一覧を出力
    exportSurvivorListCsv(){
       let url = '/apex/survivorList';
       window.open(url, '_blank');
    };

}