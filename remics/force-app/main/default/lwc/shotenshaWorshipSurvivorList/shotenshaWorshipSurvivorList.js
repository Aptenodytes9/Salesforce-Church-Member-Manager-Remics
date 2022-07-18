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
    @api YearFrom0;
    @api YearTo0;
    @api YearFrom1;
    @api YearTo1;
    @api YearFrom5;
    @api YearTo5;
    @api YearFrom10;
    @api YearTo10;
    @api YearFrom15;
    @api YearTo15;
    @api YearFrom20;
    @api YearTo20;
    @api YearFrom25;
    @api YearTo25;
    @api YearFrom30;
    @api YearTo30;
    @api YearFrom35;
    @api YearTo35;
    @api YearFrom40;
    @api YearTo40;
    @api YearFrom45;
    @api YearTo45;
    @api YearFrom50;
    @api YearTo50;
    @api YearFrom55;
    @api YearTo55;
    @api YearFrom60;
    @api YearTo60;
    @api YearFrom65;
    @api YearTo65;
    @api YearFrom70;
    @api YearTo70;
    @api YearFrom75;
    @api YearTo75;
    @api YearFrom80;
    @api YearTo80;
    @api YearFrom85;
    @api YearTo85;
    @api YearFrom90;
    @api YearTo90;
    @api YearFrom95;
    @api YearTo95;
    @api YearFrom100;
    @api YearTo100;
    @api YearFrom105;
    @api YearTo105;
    @api YearFrom110;
    @api YearTo110;
    @api YearFrom115;
    @api YearTo115;
    @api YearFrom120;
    @api YearTo120;
    @api YearFrom125;
    @api YearTo125;
    @api YearFrom130;
    @api YearTo130;
    @api YearFrom135;
    @api YearTo135;
    @api YearFrom140;
    @api YearTo140;
    @api YearFrom145;
    @api YearTo145;
    @api YearFrom150;
    @api YearTo150;
    @api YearFrom155;
    @api YearTo155;
    @api YearFrom160;
    @api YearTo160;
    @api YearFrom165;
    @api YearTo165;
    @api YearFrom170;
    @api YearTo170;
    @api YearFrom175;
    @api YearTo175;
    @api YearFrom180;
    @api YearTo180;
    @api YearFrom185;
    @api YearTo185;
    @api YearFrom190;
    @api YearTo190;
    @api YearFrom195;
    @api YearTo195;
    @api YearFrom200;
    @api YearTo200;

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
        this.YearFrom0 = (this.year - 1) + '-11-01';
        this.YearTo0 = this.year + '-10-31';

        this.YearFrom1 = (this.year - 2) + '-11-01';
        this.YearTo1 = (this.year - 1) + '-10-31';

        this.YearFrom5 = (this.year - 5) + '-01-01';
        this.YearTo5 = (this.year - 5) + '-12-31';

        this.YearFrom10 = (this.year - 10) + '-01-01';
        this.YearTo10 = (this.year - 10) + '-12-31';

        this.YearFrom15 = (this.year - 15) + '-01-01';
        this.YearTo15 = (this.year - 15) + '-12-31';
        
        this.YearFrom20 = (this.year - 20) + '-01-01';
        this.YearTo20 = (this.year - 20) + '-12-31';

        this.YearFrom25 = (this.year - 25) + '-01-01';
        this.YearTo25 = (this.year - 25) + '-12-31';

        this.YearFrom30 = (this.year - 30) + '-01-01';
        this.YearTo30 = (this.year - 30) + '-12-31';

        this.YearFrom35 = (this.year - 35) + '-01-01';
        this.YearTo35 = (this.year - 35) + '-12-31';

        this.YearFrom40 = (this.year - 40) + '-01-01';
        this.YearTo40 = (this.year - 40) + '-12-31';

        this.YearFrom45 = (this.year - 45) + '-01-01';
        this.YearTo45 = (this.year - 45) + '-12-31';

        this.YearFrom50 = (this.year - 50) + '-01-01';
        this.YearTo50 = (this.year - 50) + '-12-31';

        this.YearFrom55 = (this.year - 55) + '-01-01';
        this.YearTo55 = (this.year - 55) + '-12-31';

        this.YearFrom60 = (this.year - 60) + '-01-01';
        this.YearTo60 = (this.year - 60) + '-12-31';

        this.YearFrom65 = (this.year - 65) + '-01-01';
        this.YearTo65 = (this.year - 65) + '-12-31';

        this.YearFrom70 = (this.year - 70) + '-01-01';
        this.YearTo70 = (this.year - 70) + '-12-31';

        this.YearFrom75 = (this.year - 75) + '-01-01';
        this.YearTo75 = (this.year - 75) + '-12-31';

        this.YearFrom80 = (this.year - 80) + '-01-01';
        this.YearTo80 = (this.year - 80) + '-12-31';

        this.YearFrom85 = (this.year - 85) + '-01-01';
        this.YearTo85 = (this.year - 85) + '-12-31';

        this.YearFrom90 = (this.year - 90) + '-01-01';
        this.YearTo90 = (this.year - 90) + '-12-31';

        this.YearFrom95 = (this.year - 95) + '-01-01';
        this.YearTo95 = (this.year - 95) + '-12-31';

        this.YearFrom100 = (this.year - 100) + '-01-01';
        this.YearTo100 = (this.year - 100) + '-12-31';

        this.YearFrom105 = (this.year - 105) + '-01-01';
        this.YearTo105 = (this.year - 105) + '-12-31';

        this.YearFrom110 = (this.year - 110) + '-01-01';
        this.YearTo110 = (this.year - 110) + '-12-31';

        this.YearFrom115 = (this.year - 115) + '-01-01';
        this.YearTo115 = (this.year - 115) + '-12-31';

        this.YearFrom120 = (this.year - 120) + '-01-01';
        this.YearTo120 = (this.year - 120) + '-12-31';

        this.YearFrom125 = (this.year - 125) + '-01-01';
        this.YearTo125 = (this.year - 125) + '-12-31';

        this.YearFrom130 = (this.year - 130) + '-01-01';
        this.YearTo130 = (this.year - 130) + '-12-31';

        this.YearFrom135 = (this.year - 135) + '-01-01';
        this.YearTo135 = (this.year - 135) + '-12-31';

        this.YearFrom140 = (this.year - 140) + '-01-01';
        this.YearTo140 = (this.year - 140) + '-12-31';

        this.YearFrom145 = (this.year - 145) + '-01-01';
        this.YearTo145 = (this.year - 145) + '-12-31';

        this.YearFrom150 = (this.year - 150) + '-01-01';
        this.YearTo150 = (this.year - 150) + '-12-31';

        this.YearFrom155 = (this.year - 155) + '-01-01';
        this.YearTo155 = (this.year - 155) + '-12-31';

        this.YearFrom160 = (this.year - 160) + '-01-01';
        this.YearTo160 = (this.year - 160) + '-12-31';

        this.YearFrom165 = (this.year - 165) + '-01-01';
        this.YearTo165 = (this.year - 165) + '-12-31';

        this.YearFrom170 = (this.year - 170) + '-01-01';
        this.YearTo170 = (this.year - 170) + '-12-31';

        this.YearFrom175 = (this.year - 175) + '-01-01';
        this.YearTo175 = (this.year - 175) + '-12-31';

        this.YearFrom180 = (this.year - 180) + '-01-01';
        this.YearTo180 = (this.year - 180) + '-12-31';

        this.YearFrom185 = (this.year - 185) + '-01-01';
        this.YearTo185 = (this.year - 185) + '-12-31';

        this.YearFrom190 = (this.year - 190) + '-01-01';
        this.YearTo190 = (this.year - 190) + '-12-31';

        this.YearFrom195 = (this.year - 195) + '-01-01';
        this.YearTo195 = (this.year - 195) + '-12-31';

        this.YearFrom200 = (this.year - 200) + '-01-01';
        this.YearTo200 = (this.year - 200) + '-12-31';
    }

    onChangeYearFrom0(event) {
        this.YearFrom0 = event.detail.value;
    };

    onChangeYearTo0(event) {
        this.YearTo0 = event.detail.value;
    };

    onChangeYearFrom1(event) {
        this.YearFrom1 = event.detail.value;
    };

    onChangeYearTo1(event) {
        this.YearTo0 = event.detail.value;
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
        const dateArray = [ this.YearFrom0, this.YearTo0, this.YearFrom1, this.YearTo1, this.YearFrom5, this.YearTo5, this.YearFrom10, this.YearTo10, this.YearFrom15, this.YearTo15, this.YearFrom20, this.YearTo20, this.YearFrom25, this.YearTo25, this.YearFrom30, this.YearTo30, this.YearFrom35, this.YearTo35, this.YearFrom40, this.YearTo40, this.YearFrom45, this.YearTo45, this.YearFrom50, this.YearTo50, this.YearFrom55, this.YearTo55, this.YearFrom60, this.YearTo60, this.YearFrom65, this.YearTo65, this.YearFrom70, this.YearTo70, this.YearFrom75, this.YearTo75, this.YearFrom80, this.YearTo80, this.YearFrom85, this.YearTo85, this.YearFrom90, this.YearTo90, this.YearFrom95, this.YearTo95, this.YearFrom100, this.YearTo100, this.YearFrom105, this.YearTo105, this.YearFrom110, this.YearTo110, this.YearFrom115, this.YearTo115, this.YearFrom120, this.YearTo120, this.YearFrom125, this.YearTo125, this.YearFrom130, this.YearTo130, this.YearFrom135, this.YearTo135, this.YearFrom140, this.YearTo140, this.YearFrom145, this.YearTo145, this.YearFrom150, this.YearTo150, this.YearFrom155, this.YearTo155, this.YearFrom160, this.YearTo160, this.YearFrom165, this.YearTo165, this.YearFrom170, this.YearTo170, this.YearFrom175, this.YearTo175, this.YearFrom180, this.YearTo180, this.YearFrom185, this.YearTo185, this.YearFrom190, this.YearTo190, this.YearFrom195, this.YearTo195, this.YearFrom200, this.YearTo200 ];

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