import { LightningElement, api } from 'lwc';

export default class RecordList extends LightningElement {

    @api rec;
    @api iconName = 'standard:event';

    handleSelect() {
        let selectEvent = new CustomEvent('select', {
            detail: {
                selRec : this.rec
            }
        });

        this.dispatchEvent( selectEvent );
    }

    handleRemove() {
        let selectEvent = new CustomEvent('select',{
            detail: {
                selRec : undefined
            }
        });
        
        this.dispatchEvent( selectEvent );
    }

}