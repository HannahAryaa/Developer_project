@isTest
private class TestSchPurgeEvents {
    
    @isTest
    static void tester(){
        EventOrganizer__c organizer = new EventOrganizer__c(Name = 'Organizer 1',
                                                            Email__c = 'testorganizer1@test.com',
                                                            Phone__c = '234567876543'
                                                           );
        insert organizer;

        Event__c event1 = new Event__c(EventOrganizer__c = organizer.Id,
                                       Name__c = 'Test Event 1',
                                       Status__c = 'In Progress',
                                       StartDateTime__c = Datetime.now().addDays(-14),
                                       EndDateTime__c = Datetime.now().addDays(14),
                                       MaxSeats__c = 10,
                                       EventType__c = 'Virtual',
                                       Live__c = true
                                      );

        Event__c event2 = new Event__c(EventOrganizer__c = organizer.Id,
                                       Name__c = 'Test Event 2',
                                       Status__c = 'Completed',
                                       StartDateTime__c = Datetime.now().addMonths(-3),
                                       EndDateTime__c = Datetime.now().addMonths(-3).addDays(14),
                                       MaxSeats__c = 10,
                                       EventType__c = 'Virtual',
                                       Live__c = false
                                      );
        
        insert new List<Event__c>{event1, event2};

        Test.startTest();
        SchPurgeEvents obj = new SchPurgeEvents();
        obj.execute(null);
        Test.stopTest();

        Integer eventCount = [SELECT COUNT() FROM Event__c];
        System.assertEquals(1, eventCount);
    }

}