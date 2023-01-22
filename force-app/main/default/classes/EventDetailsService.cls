public with sharing class EventDetailsService {
    
    @AuraEnabled
    public static List<Event__c> upcomingEvents(){
        return [SELECT Id, Name, Name__c, EventDetail__c, Location__c, Location__r.Name,
                       EventOrganizer__c, StartDateTime__c, EventOrganizer__r.Name
                FROM Event__c
                WHERE StartDateTime__c >= TODAY
                AND Live__c = true
                WITH SECURITY_ENFORCED
               ];
    }
    
    @AuraEnabled
    public static List<Event__c> searchByKeyword(String name){
        String nameLike = '%' + name + '%';

        return [SELECT Id, Name, Name__c, EventDetail__c, Location__c, Location__r.Name,
                       EventOrganizer__c, StartDateTime__c, EventOrganizer__r.Name
                FROM Event__c
                WHERE StartDateTime__c >= TODAY
                AND Live__c = true
                AND Name__c LIKE :nameLike
                WITH SECURITY_ENFORCED
               ];
    }

}