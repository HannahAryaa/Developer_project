import { LightningElement, track } from 'lwc';

import upcomingEvents from "@salesforce/apex/EventDetailsService.upcomingEvents";
import searchByKeyword from "@salesforce/apex/EventDetailsService.searchByKeyword";

const COLUMNS = [
    {
        label: "View",
        fieldName: "detailsPage",
        type: "url",
        wrapText: "true",
        typeAttributes: {
            label: {
                fieldName: "Name__c"
            },
            target: "_self"
        }
    },
    {
        label: "Name",
        fieldName: "Name__c",
        wrapText: "true",
        cellAttributes: {
            iconName: "standard:event",
            iconPosition: "left"
        }
    },
    {
        label: "Event Organizer",
        fieldName: "organizer",
        wrapText: "true",
        cellAttributes: {
            iconName: "standard:user",
            iconPosition: "left"
        }
    },
    {
        label: "Location",
        fieldName: "Location",
        wrapText: "true",
        type: "text",
        cellAttributes: {
            iconName: "utility:location",
            iconPosition: "left"
        }
    }
];

export default class EventList extends LightningElement {

    columnsList = COLUMNS;
    error;

    startDateTime;

    @track result;
    @track recordsToDisplay;

    connectedCallback() {
        this.upcomingEventsFromApex();
    }

    upcomingEventsFromApex() {
        upcomingEvents()
        .then((data) => {
            console.log("data:" + JSON.stringify(data));

            data.forEach((record) => {
                record.detailsPage = "https://" + window.location.host + "/" + record.Id;
                record.organizer = record.EventOrganizer__r.Name;

                if (record.Location__c) {
                    record.Location = record.Location__r.Name;
                } else {
                    record.Location = "This is Virtual Event";
                }
            });

            this.result = data;
            this.recordsToDisplay = data;
            this.error = undefined;
        })
        .catch((err) => {
            console.log('ERR:' + JSON.stringify(err));
            this.error = JSON.stringify(err);
            this.result = undefined;
        });
    }

    handleSearch(event) {
        let keyword = event.detail.value;

        searchByKeyword({
            name : keyword
        })
        .then((data) => {
            console.log("Apexten dönen data:" + JSON.stringify(data));

            data.forEach((record) => {
                record.detailsPage = "https://" + window.location.host + "/" + record.Id;
                record.organizer = record.EventOrganizer__r.Name;
                record.Location = record.Location__c ? record.Location__r.Name : "This is Virtual Event";
            });

            this.result = data;
            this.recordsToDisplay = data;
            this.error = undefined;
        })
        .catch((err) => {
            console.log('ERR:' + JSON.stringify(err));
            this.error = JSON.stringify(err);
            this.result = undefined;
        });
    }

    handleStartDate(event) {
        let valuedatetime = event.target.value;
        console.log("selectedDate:" + valuedatetime);
        
        let filteredEvents = this.result.filter((record, index, arrayobject) => {
            return record.StartDateTime__c >= valuedatetime;
        });

        this.recordsToDisplay = filteredEvents;
    }

    handleLocationSearch(event) {
        let keyword = event.detail.value;

        let filteredEvents = this.result.filter((record, index, arrayobject) => {
            return record.Location.toLowerCase().includes(keyword.toLowerCase());
        });

        if(keyword && keyword.length >= 2) {
            this.recordsToDisplay = filteredEvents;
        } else {
            this.recordsToDisplay = this.result;
        }
    }

}