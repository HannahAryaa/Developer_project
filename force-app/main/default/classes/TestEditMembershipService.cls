@isTest
private class TestEditMembershipService {
    
    @TestSetup
    static void makeData(){
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

        Event__c event2 = event1.clone();
        event2.Name__c = 'Test Event 2';
        event2.StartDateTime__c = Datetime.now().addDays(-7);
        event2.EndDateTime__c = Datetime.now().addMonths(3);

        Event__c event3 = event1.clone();
        event3.Name__c = 'Test Event 3';
        event3.StartDateTime__c = Datetime.now().addDays(-17);
        event3.EndDateTime__c = Datetime.now().addMonths(2);

        Attendee__c attendee = new Attendee__c(Name = 'Test Attendee',
                                               Email__c = 'testemail@ema.com.test',
                                               Phone__c = '234511176543'
                                              );

        insert new List<SObject>{event1, event2, event3, attendee};

        insert new EventAttendee__c(Event__c = event1.Id,
                                    Attendee__c = attendee.Id
                                   );
    }

    @isTest
    static void testClearMembership(){
        Attendee__c attendee = [SELECT Id FROM Attendee__c LIMIT 1];

        List<EditMembershipService.MemberWrapper> results = EditMembershipService.findEvents(attendee.Id, 'delete');
        System.assertEquals(1, results.size());

        List<String> eventIds = new List<String>{results[0].eventId};

        Boolean isSuccess = EditMembershipService.manageMembership(attendee.Id, eventIds, 'delete');
        System.assert(isSuccess);

        System.assertEquals(0, [SELECT COUNT() FROM EventAttendee__c WHERE Attendee__c = :attendee.Id]);
    }

    @isTest
    static void testAddMembership(){
        Attendee__c attendee = [SELECT Id FROM Attendee__c LIMIT 1];

        List<EditMembershipService.MemberWrapper> results = EditMembershipService.findEvents(attendee.Id, 'create');
        System.assertEquals(2, results.size());

        List<String> eventIds = new List<String>{results[0].eventId};

        Boolean isSuccess = EditMembershipService.manageMembership(attendee.Id, eventIds, 'create');
        System.assert(isSuccess);

        System.assertEquals(2, [SELECT COUNT() FROM EventAttendee__c WHERE Attendee__c = :attendee.Id]);
    }

}
