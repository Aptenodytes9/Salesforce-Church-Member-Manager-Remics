import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './customDataTable.html';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomDataTable';

export default class CustomDataTable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context'],
        },

    };

    constructor() {
        super();
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => {})
    }
}