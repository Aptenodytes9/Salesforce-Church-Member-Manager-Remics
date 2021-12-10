import { LightningElement, track } from 'lwc';

export default class Hellolwc extends LightningElement {
    name = 'Light!';
    onNameChanged(){
        this.name = this.template.querySelector('input').value;

    }
    // @track isChecked = false;
    // onChangeCheckbox() {
    //     this.isChecked = this.template.querySelector('input').checked;
    // }
    // @track members = [
    //     {
    //         id: "1",
    //         name: "Satto"
    //     },
    //     {
    //         id: "2",
    //         name: "Suzuki"
    //     },
    //     {
    //         id: "3",
    //         name: "Tanaka"
    //     }
    // ]
}