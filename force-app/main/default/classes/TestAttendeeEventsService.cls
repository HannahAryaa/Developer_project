@isTest
private class TestAttendeeEventsService {

    @isTest
    static void tester(){
        EventOrganizer__c organizer = new EventOrganizer__c(Name = 'Organizer 1',
                                                            Email__c = 'testorganizer1@test.com',
                                                            Phone__c = '234567876543'
                                                           );
        insert organizer;

        List<Event__c> events = new List<Event__c>();
        for(Integer i=1; i<=200; i++){
            events.add(new Event__c(EventOrganizer__c = organizer.Id,
                                    Name__c = 'Test Event ' + String.valueOf(i),
                                    Status__c = 'In Progress',
                                    StartDateTime__c = i<=100 ? Datetime.now().addMonths(-3) : Datetime.now().addDays(3),
                                    MaxSeats__c = 10,
                                    EventType__c = 'Virtual',
                                    Live__c = true
                                ));
        }
        
        insert events;
        
        Attendee__c attendee = new Attendee__c(Name = 'Mustafa Test',
                                               Email__c = 'test@test.com',
                                               Phone__c = '23456786543'
                                              );
        insert attendee;

        List<EventAttendee__c> eaList = new List<EventAttendee__c>();
        eaList.add(new EventAttendee__c(Event__c = events[7].Id, Attendee__c = attendee.Id));
        eaList.add(new EventAttendee__c(Event__c = events[17].Id, Attendee__c = attendee.Id));
        eaList.add(new EventAttendee__c(Event__c = events[117].Id, Attendee__c = attendee.Id));
        eaList.add(new EventAttendee__c(Event__c = events[165].Id, Attendee__c = attendee.Id));
        insert eaList;

        Test.startTest();
        List<EventAttendee__c> pastEvents = AttendeeEventsService.pastEvents(attendee.Id);
        List<AttendeeEventsService.MemberWrapper> upcomingEvents = AttendeeEventsService.upcomingEvents(attendee.Id);
        Test.stopTest();

        System.assertEquals(2, pastEvents.size());
        System.assertEquals(100, upcomingEvents.size());

        Integer memberCount = 0;
        for(AttendeeEventsService.MemberWrapper mw : upcomingEvents){
            if(mw.isMember) memberCount++;
        }

        System.assertEquals(2, memberCount);
    }

}