public with sharing class EditMembershipService {
    
    @AuraEnabled
    public static List<MemberWrapper> findEvents(String attendeeId, String selection){
        List<MemberWrapper> memberInfo = new List<MemberWrapper>();

        List<Event__c> events = [SELECT Id, Location__c, Location__r.Name, EventOrganizer__c,
                                    EventOrganizer__r.Name, Name__c, StartDateTime__c,
                                 (SELECT Id, Name FROM Event_Attendees__r WHERE Attendee__c =: attendeeId)
                                 FROM Event__c
                                 WHERE Live__c = true
                                 WITH SECURITY_ENFORCED
                                ];

        for(Event__c eve : events){
            MemberWrapper wrapper = new MemberWrapper();
            wrapper.isMember = eve.Event_Attendees__r.size() > 0;
            wrapper.event = eve;
            wrapper.eventId = eve.Id;
            wrapper.eventAttendee = wrapper.isMember ? eve.Event_Attendees__r[0] : null;

            if(selection.equalsIgnoreCase('delete') && wrapper.isMember){
                memberInfo.add(wrapper);
            }
            else if(selection.equalsIgnoreCase('create') && !wrapper.isMember){
                memberInfo.add(wrapper);
            }
        }
        
        return memberInfo;
    }

    @AuraEnabled
    public static Boolean manageMembership(String attendeeId, List<String> eventIds, String selection){
        System.debug('eventIds:' + eventIds);

        try {
            if(selection.equalsIgnoreCase('delete')){
                delete [SELECT Id FROM EventAttendee__c WHERE Event__c IN: eventIds AND Attendee__c =: attendeeId];
            }
            else if(selection.equalsIgnoreCase('create')){
                List<EventAttendee__c> newEventAttendees = new List<EventAttendee__c>();
                for(String eId : eventIds){
                    newEventAttendees.add(new EventAttendee__c(Event__c = eId, Attendee__c = attendeeId));
                }
    
                insert newEventAttendees;
            }
    
            return true;
        }catch(Exception exc){
            throw new AuraHandledException(exc.getMessage());
        }
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
