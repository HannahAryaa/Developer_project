@isTest
private class InvSmartyStreetCallerTester {
    
    @isTest
    static void testNegative(){
        Location__c location = new Location__c(Name = 'Test Address Name',
                                               City__c = 'TestCity',
                                               PostalCode__c = '123',
                                               State__c = 'TestState',
                                               Street__c = 'TestStreet',
                                               Country__c = 'United States'
                                              );

        Test.startTest();
        insert location;
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM ErrorLog__c WHERE ApexClass__c = 'InvSmartyStreetCaller'];
        System.assertEquals(1, logCount);
    }

    @isTest
    static void testPositive(){
        Location__c location = new Location__c(Name = 'Test Address Name',
                                               City__c = 'TestCity',
                                               PostalCode__c = '123',
                                               State__c = 'TestState',
                                               Street__c = 'TestStreet',
                                               Country__c = 'United States'
                                              );

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockSmartyStreetAPI());

        Test.startTest();
        insert location;
        Test.stopTest();

        location = [SELECT Verified__c FROM Location__c WHERE Id =: location.Id];
        System.assert(location.Verified__c);
    }

    private class MockSmartyStreetAPI implements HttpCalloutMock {

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req){
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }

}