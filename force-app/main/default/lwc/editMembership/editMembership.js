import { LightningElement, api } from 'lwc';

import findEvents from "@salesforce/apex/EditMembershipService.findEvents";
import manageMembership from "@salesforce/apex/EditMembershipService.manageMembership";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: "Event Name",
        fieldName: "detailsPage",
        type: "url",
        wrapText: "true",
        typeAttributes: {
            label: {
                fieldName: "Name"
            }
        }
    },
    {
        label: "Name",
        fieldName: "EVNTORG",
        cellAttributes: {
            iconName: "standard:user",
            iconPosition: "left"
        }
    },
    {
        label: "Event Date",
        fieldName: "StartDateTime",
        type: "date",
        typeAttributes: {
            weekday: "long",
            year: "numeric",
            month: "long"
        }
    },
    {
        label: "Location",
        fieldName: "Location",
        type: "text",
        cellAttributes: {
            iconName: "utility:location",
            iconPosition: "left"
        }
    }
];

export default class EditMembership extends LightningElement {

    // to be set by flow
    @api recordId;
    @api selection; // "add" or "clear" meaning insert or delete

    errors;
    events;
    columnsList = COLUMNS;

    retrievedRecordId = false;

    renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            console.log("recordId:" + this.recordId);
            console.log("selection:" + this.selection);

            // Escape case from recursion
            this.retrievedRecordId = true;

            console.log("found recordId:" + this.recordId);

            this.workOnEvents();
        }
    }

    workOnEvents(){
        findEvents({
            attendeeId: this.recordId,
            selection: this.selection
        })
        .then((result) => {
            this.events = [];
            result.forEach((record) => {
                let obj = new Object();
                obj.id = record.eventId;
                obj.Name = record.event.Name__c;
                obj.detailsPage = "https://" + window.location.host + "/" + record.event.Id;
                obj.EVNTORG = record.event.EventOrganizer__r.Name;
                obj.StartDateTime = record.event.StartDateTime__c;
                
                if (record.event.Location__c) {
                    obj.Location = record.event.Location__r.Name;
                } else {
                    obj.Location = "This is a virtual event";
                }

                this.events.push(obj);
            });

            this.errors = undefined;
        })
        .catch((error) => {
            this.events = undefined;
            this.errors = error.message;
        });
    }

    handleClick(event){
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();  
        console.log('selectedRecords' + JSON.stringify(selectedRecords));

        let ids = [];
        selectedRecords.forEach((line) => {
            ids.push(line.id);
        });

        console.log('ids:' + ids);

        manageMembership({
            attendeeId: this.recordId,
            eventIds: ids,
            selection: this.selection
        })
        .then((result) => {
            console.log('result:' + result);

            if(result){
                this.showNotification('Successful Operation', 'That worked great', 'success');
                
            }
            else{
                this.showNotification('Error', 'Opppss', 'error');
            }
        })
        .catch((error) => {
            this.errors = error.message;
            this.showNotification('Error', error.message, 'error');
        });
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}