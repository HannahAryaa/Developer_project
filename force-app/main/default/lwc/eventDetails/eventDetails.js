import { LightningElement, api, track, wire } from 'lwc';

import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

import getSpeakers from "@salesforce/apex/EventDetailsController.getSpeakers";
import getLocationDetails from "@salesforce/apex/EventDetailsController.getLocationDetails";
import getAttendees from "@salesforce/apex/EventDetailsController.getAttendees";

import id from "@salesforce/user/Id";
import profile from "@salesforce/schema/User.Profile.Name";

const COLUMNS = [
    {
        label: "Name",
        fieldName: "Name",
        cellAttributes: {
            iconName: "standard:user",
            iconPosition: "left"
        }
    },
    {
        label: "Email",
        fieldName: "Email",
        type: "email"
    },
    {
        label: "Company Name",
        fieldName: "CompanyName"
    },
    {
        label: "Location",
        fieldName: "Location",
        cellAttributes: {
            iconName: "utility:location",
            iconPosition: "left"
        }
    }
];

export default class EventDetails extends NavigationMixin(LightningElement) {

    @api recordId;

    @track speakerList;
    @track attendeesList;
    @track eventRec;
    @track isAdmin = false;

    errors;
    userId = id;

    columnsList = COLUMNS;

    @wire(getRecord, { recordId: '$userId', fields: [profile] })
    wiredMethod({ error, data }) {
        if(data){
            let userProfileName = data.fields.Profile.displayValue;
            this.isAdmin = userProfileName === "System Administrator";
        }

        if(error){
            console.log("Error Occurred ", JSON.stringify(error));
        }
    }

    createSpeaker(){
        const defaultValues = encodeDefaultFieldValues({
            Event__c: this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "EventSpeaker__c",
                actionName: "new"
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleSpeakerActive(){
        getSpeakers({
            eventId: this.recordId
        })
        .then((result) => {
            result.forEach((speaker) => {
                speaker.Name = speaker.Speaker__r.Name;
                speaker.Email = "*********@gmail.com";
                speaker.Phone = speaker.Speaker__r.Phone__c;
                speaker.Picture__c = speaker.Speaker__r.Picture__c;
                speaker.AboutMe__c = speaker.Speaker__r.AboutMe__c;
                speaker.CompanyName = speaker.Speaker__r.Company__c;
            });
        
            this.speakerList = result;

            this.errors = undefined;
        })
        .catch((err) => {
            this.errors = err;
            this.speakerList = undefined;
            window.console.log("ERR:", this.errors);
        });
    }

    handleLocatioDetails(){
        getLocationDetails({
            eventId: this.recordId
        })
        .then((result) => {
            if(result.Location__c){
                this.eventRec = result;
            } else {
                this.eventRec = undefined;
            }

            this.errors = undefined;
        })
        .catch((err) => {
            this.errors = err;
            this.speakerList = undefined;
        });
    }

    handleEventAttendee(){
        getAttendees({
            eventId: this.recordId
        })
        .then((result) => {
            result.forEach((att) => {
                att.Name = att.Attendee__r.Name;
                att.Email = "*********@gmail.com";
                att.CompanyName = att.Attendee__r.Company_Name__c;

                if (att.Attendee__r.Location__c) {
                    att.Location = att.Attendee__r.Location__r.Name;
                } else {
                    att.Location = "Preferred Not to Say";
                }
            });

            this.attendeesList = result;
            this.errors = undefined;
        })
        .catch((err) => {
            this.errors = err;
            this.speakerList = undefined;
        });
    }

    createAttendee(){
        const defaultValues = encodeDefaultFieldValues({
            Event__c: this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "EventAttendee__c",
                actionName: "new"
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

}