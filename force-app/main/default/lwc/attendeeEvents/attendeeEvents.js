import { LightningElement, api } from 'lwc';

import upcomingEvents from "@salesforce/apex/AttendeeEventsService.upcomingEvents";
import pastEvents from "@salesforce/apex/AttendeeEventsService.pastEvents";

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

export default class AttendeeEvents extends LightningElement {

    @api recordId;
    selectedEvents;
    upcomingEvents;
    pastEvents;

    columnsList = COLUMNS;
    errors;
    retrievedRecordId = false;

    renderedCallback(){
        console.log("renderedCallback");
        if (!this.retrievedRecordId && this.recordId) {
            // Escape case from recursion
            this.retrievedRecordId = true;

            console.log("found recordId:" + this.recordId);

            this.upcomingEventsFromApex();
            this.pastEventsFromApex();
        }
    }

    upcomingEventsFromApex(){
        upcomingEvents({
            attendeeId: this.recordId
        })
        .then((result) => {
            console.log("result:" + JSON.stringify(result));

            this.upcomingEvents = [];
            this.selectedEvents = [];
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

                this.upcomingEvents.push(obj);

                if(record.isMember) this.selectedEvents.push(obj.id);
            });

            this.errors = undefined;
        })
        .catch((error) => {
            this.upcomingEvents = undefined;
            this.errors = JSON.stringify(error);
        });
    }

    pastEventsFromApex(){
        pastEvents({
            attendeeId: this.recordId
        })
        .then((result) => {
            this.pastEvents = [];
            result.forEach((record) => {
                let pastEvent = {
                    Name : record.Event__r.Name__c,
                    detailsPage : "https://" + window.location.host + "/" + record.Event__c,
                    EVNTORG : record.Event__r.EventOrganizer__r.Name,
                    StartDateTime : record.Event__r.StartDateTime__c,
                    Location : (record.Event__r.Location__c ? record.Event__r.Location__r.Name : "This is a virtual event")
                }

                this.pastEvents.push(pastEvent);
            });
            
            this.errors = undefined;
        })
        .catch((error) => {
            this.pastEvents = undefined;
            this.errors = JSON.stringify(error);
        });
    }
}