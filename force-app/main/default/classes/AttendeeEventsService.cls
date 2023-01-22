public with sharing class AttendeeEventsService {
    
    @AuraEnabled(cacheable=true)
    public static List<MemberWrapper> upcomingEvents(String attendeeId) {
        List<Event__c> events = [SELECT Id, Location__c, Location__r.Name, EventOrganizer__c,
                                        EventOrganizer__r.Name, Name__c, StartDateTime__c,
                                  (SELECT Id, Name FROM Event_Attendees__r WHERE Attendee__c =: attendeeId)
                                 FROM Event__c
                                 WHERE StartDateTime__c >= TODAY
                                 AND Live__c = true
                                 WITH SECURITY_ENFORCED
                                ];

        List<MemberWrapper> memberInfo = new List<MemberWrapper>();
        for(Event__c eve : events){
            MemberWrapper wrapper = new MemberWrapper();
            wrapper.isMember = eve.Event_Attendees__r.size() > 0;
            wrapper.event = eve;
            wrapper.eventId = eve.Id;
            wrapper.eventAttendee = wrapper.isMember ? eve.Event_Attendees__r[0] : null;

            memberInfo.add(wrapper);
        }

        return memberInfo;
    }
  
    @AuraEnabled(cacheable=true)
    public static List<EventAttendee__c> pastEvents(String attendeeId) {
        return [SELECT Id, Name, Event__c, Event__r.Location__c, Event__r.Location__r.Name,
                       Event__r.EventOrganizer__c, Event__r.EventOrganizer__r.Name,
                       Event__r.Name__c, Event__r.StartDateTime__c
                FROM EventAttendee__c
                WHERE Attendee__c = :attendeeId
                AND Event__r.StartDateTime__c < TODAY
                WITH SECURITY_ENFORCED
               ];
    }

    public class MemberWrapper {

        @AuraEnabled
        public Boolean isMember;

        @AuraEnabled
        public String eventId;

        @AuraEnabled
        public EventAttendee__c eventAttendee;

        @AuraEnabled
        public Event__c event;
    }

}