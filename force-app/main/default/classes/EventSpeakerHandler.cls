public with sharing class EventSpeakerHandler {
    
    public static void checkDuplicateSpeakerOnEvents(List<EventSpeaker__c> eventSpeakers){
        // Event__c + Speaker__c (a058d0000003g0rAAAa038d000002KvMzAAK)
        Map<String, EventSpeaker__c> eventSpeakersMap = new Map<String, EventSpeaker__c>();

        Set<Id> eventIds = new Set<Id>();
        Set<Id> speakerIds = new Set<Id>();
        for(EventSpeaker__c es : eventSpeakers){
            String uniqueKey = String.valueOf(es.Event__c) + String.valueOf(es.Speaker__c);
            eventSpeakersMap.put(uniqueKey, es);

            eventIds.add(es.Event__c);
            speakerIds.add(es.Speaker__c);
        }

        List<EventSpeaker__c> onSystemRecords = [SELECT Id, Event__c, Speaker__c
                                                 FROM EventSpeaker__c
                                                 WHERE Event__c IN: eventIds
                                                 AND Speaker__c IN: speakerIds
                                                ];
        for(EventSpeaker__c sys : onSystemRecords){
            String uniqueKey = String.valueOf(sys.Event__c) + String.valueOf(sys.Speaker__c);

            EventSpeaker__c checkingObject = eventSpeakersMap.get(uniqueKey);
            if(checkingObject == null) continue;

            checkingObject.addError('Found a duplicate Event Speaker record on the system with id: ' + String.valueOf(sys.Id));
        }
    }

}