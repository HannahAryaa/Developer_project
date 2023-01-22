@isTest
private class TestEventSpeakerHandler {
    
    @testSetup
    static void prepareData(){
        EventOrganizer__c organizer = new EventOrganizer__c(Name = 'Organizer 1',
                                                            Email__c = 'testorganizer1@test.com',
                                                            Phone__c = '234567876543'
                                                           );
        insert organizer;

        Event__c event = new Event__c(EventOrganizer__c = organizer.Id,
                                      Name__c = 'Test Event',
                                      Status__c = 'In Progress',
                                      StartDateTime__c = Datetime.now().addDays(-14),
                                      EndDateTime__c = Datetime.now().addDays(14),
                                      MaxSeats__c = 10,
                                      EventType__c = 'Virtual',
                                      Live__c = true
                                     );
        insert event;

        Speaker__c spaker1 = new Speaker__c(Name = 'Speaker 1',
                                            Email__c = 'testspeaker1@test.com',
                                            Phone__c = '6543245643'
                                           );

        Speaker__c spaker2 = new Speaker__c(Name = 'Speaker 2',
                                            Email__c = 'testspeaker2@test.com',
                                            Phone__c = '4423233435'
                                           );

        insert new List<Speaker__c>{spaker1, spaker2};

        insert new EventSpeaker__c(Event__c = event.Id, Speaker__c = spaker1.Id);
    }

    @isTest
    static void testPositive(){
        EventSpeaker__c eventSpeaker = [SELECT Id, Event__c, Speaker__c FROM EventSpeaker__c LIMIT 1];

        Boolean isFailed = false;
        try {
            EventSpeaker__c newRecord = new EventSpeaker__c(Event__c = eventSpeaker.Event__c, Speaker__c = eventSpeaker.Speaker__c);
            insert newRecord;
        }catch(Exception exc){
            isFailed = true;
        }

        System.assert(isFailed);
    }

    @isTest
    static void testNegative(){
        Event__c event = [SELECT Id FROM Event__c WHERE Name__c = 'Test Event' LIMIT 1];
        Speaker__c spaker2 = [SELECT Id FROM Speaker__c WHERE Name = 'Speaker 2' LIMIT 1];

        EventSpeaker__c newRecord = new EventSpeaker__c(Event__c = event.Id, Speaker__c = spaker2.Id);
        insert newRecord;

        System.assertNotEquals(newRecord.Id, null);
    }

    @isTest
    static void testBulk(){
        
    }

}