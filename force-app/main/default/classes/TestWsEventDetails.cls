@isTest
private class TestWsEventDetails {
    
    @isTest
    static void tester(){
        EventOrganizer__c organizer = new EventOrganizer__c(Name = 'Organizer 1',
                                                            Email__c = 'testorganizer1@test.com',
                                                            Phone__c = '234567876543'
                                                           );
        insert organizer;

        Event__c event = new Event__c(EventOrganizer__c = organizer.Id,
                                      Name__c = 'Test Event',
                                      Status__c = 'In Progress',
                                      StartDateTime__c = Datetime.now().addDays(14),
                                      EndDateTime__c = Datetime.now().addDays(45),
                                      MaxSeats__c = 10,
                                      EventType__c = 'Virtual',
                                      Live__c = true
                                     );
        insert event;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/apexrest/EventDetails/';
        RestContext.request.httpMethod = 'GET';

        Test.startTest();
        List<WsEventDetails.EventWrapper> events = WsEventDetails.getEventDetails();
        Test.stopTest();

        System.assertEquals(1, events.size());

        WsEventDetails.EventWrapper result = events[0];
        System.assertEquals('Test Event', result.name);
    }

}