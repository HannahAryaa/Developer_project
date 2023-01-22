public with sharing class EventDetailsController {
    
    @AuraEnabled
    public static List<EventSpeaker__c> getSpeakers(String eventId) {
        return [SELECT Id, Name, Speaker__c, Speaker__r.Name, Speaker__r.Phone__c, Speaker__r.Email__c,
                       Speaker__r.Company__c, Speaker__r.Picture__c, Speaker__r.AboutMe__c
                FROM EventSpeaker__c
                WHERE Event__c = :eventId
                WITH SECURITY_ENFORCED
               ];
    }

    @AuraEnabled
    public static Event__c getLocationDetails(String eventId) {
        return [SELECT Id, Name__c, Location__c, Location__r.Name, Location__r.City__c, Location__r.Country__c,
                       Location__r.LandMark__c, Location__r.PostalCode__c, Location__r.State__c, Location__r.Street__c
                FROM Event__c
                WHERE Id = :eventId
                WITH SECURITY_ENFORCED
               ];
    }

    @AuraEnabled
    public static List<EventAttendee__c> getAttendees(String eventId) {
        return [SELECT Id, Name, Attendee__c, Attendee__r.Name, Attendee__r.Email__c, Attendee__r.CompanyName__c,
                       Attendee__r.Location__c, Attendee__r.Location__r.Name
                FROM EventAttendee__c
                WHERE Event__c = :eventId
                WITH SECURITY_ENFORCED
               ];
    }

}