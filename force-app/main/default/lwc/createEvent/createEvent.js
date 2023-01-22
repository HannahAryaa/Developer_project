import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

import EVENT_OBJECT from '@salesforce/schema/Event__c';
import Name_F from '@salesforce/schema/Event__c.Name__c';
import EventOrganizer__c from '@salesforce/schema/Event__c.EventOrganizer__c';
import StartDateTime__c from '@salesforce/schema/Event__c.StartDateTime__c';
import EndDateTime__c from '@salesforce/schema/Event__c.EndDateTime__c';
import MaxSeats__c from '@salesforce/schema/Event__c.MaxSeats__c';
import Location__c from '@salesforce/schema/Event__c.Location__c';
import EventDetail__c from '@salesforce/schema/Event__c.EventDetail__c';
import Status__c from '@salesforce/schema/Event__c.Status__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateEvent extends NavigationMixin(LightningElement) {

    @track eventRecord = {
        Name__c: '',
        EventOrganizer__c: '',
        StartDateTime__c: null,
        EndDateTime__c: null,
        MaxSeats__c: null,
        Location__c: '',
        EventDetail__c: ''
    }

    @track errors;

    handleChange(event) {
        let value = event.target.value;
        let name = event.target.name;
        this.eventRecord[name] = value;
    }

    handleLookup(event) {
        let selectedRecId = event.detail.selectedRecordId;
        let parentField = event.detail.parentfield;
        this.eventRecord[parentField] = selectedRecId;
    }

    handleClick() {
        const fields = {};
        fields[Name_F.fieldApiName] = this.eventRecord.Name__c;
        fields[EventOrganizer__c.fieldApiName] = this.eventRecord.EventOrganizer__c;
        fields[StartDateTime__c.fieldApiName] = this.eventRecord.StartDateTime__c;
        fields[EndDateTime__c.fieldApiName] = this.eventRecord.EndDateTime__c;
        fields[MaxSeats__c.fieldApiName] = this.eventRecord.MaxSeats__c;
        fields[Location__c.fieldApiName] = this.eventRecord.Location__c;
        fields[EventDetail__c.fieldApiName] = this.eventRecord.EventDetail__c;
        fields[Status__c.fieldApiName] = 'Created';

        const eventRecord = {
            apiName: EVENT_OBJECT.objectApiName,
            fields
        };

        createRecord(eventRecord)
        .then((eventRec) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Record Saved',
                message: 'Event Draft is Ready',
                variant: 'success'
            }));
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    actionName: "view",
                    recordId: eventRec.id
                }
            });
        }).catch((err) => {
            this.errors = JSON.stringify(err);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Occured',
                message: this.errors,
                variant: 'error'
            }));
        });
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                actionName: "home",
                objectApiName: "Event__c"
            }
        });
    }

}