@RestResource(urlMapping='/EventDetails/*')
global with sharing class WsEventDetails {

    // https://mshnema-dev-ed.my.salesforce.com/services/apexrest/EventDetails/
    @HttpGet
    global static List<EventWrapper> getEventDetails(){
        List<EventWrapper> events = new List<EventWrapper>();
        for(Event__c ev : [SELECT Id, Name, Name__c, StartDateTime__c, EndDateTime__c, EventType__c, EventOrganizer__r.Name
                           FROM Event__c
                           WHERE Live__c = true
                           AND StartDateTime__c >= TODAY
                           WITH SECURITY_ENFORCED
                          ])
        {
            events.add(new EventWrapper(ev));
        }

        return events;
    }

    global class EventWrapper {

        global String eventId;
        global String stdName;
        global String name;
        global String startDate;
        global Datetime endDate;
        global String eventType;
        global String organizer;

        global EventWrapper(Event__c event){
            this.eventId = String.valueOf(event.Id);
            this.stdName = event.Name;
            this.name = event.Name__c;
            this.startDate = event.StartDateTime__c.format('yyyy-MM-dd HH:mm');
            this.endDate = event.EndDateTime__c;
            this.eventType = event.EventType__c;
            this.organizer = event.EventOrganizer__r.Name;
        }

    }
    
}