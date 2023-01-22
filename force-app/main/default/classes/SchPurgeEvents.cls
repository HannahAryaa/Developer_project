public with sharing class SchPurgeEvents implements Database.Batchable<SObject>, Schedulable {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new SchPurgeEvents(), 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id
                                         FROM Event__c
                                         WHERE EndDateTime__c <=: Datetime.now().addMonths(-2)
                                         AND Live__c = false
                                        ]);
    }

    public void execute(Database.BatchableContext bc, List<Event__c> records){
        // process each batch of records
        try {
            delete records;
        }catch(Exception exc){
            ErrorLogHelper.createErrorLog('SchPurgeEvents', 'execute', exc.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){
        List<GroupMember> members = [SELECT UserOrGroupId
                                     FROM GroupMember
                                     WHERE Group.DeveloperName = 'DailyJob'
                                    ];

        Set<Id> userIds = new Set<Id>();
        for(GroupMember gm : members){
            userIds.add(gm.UserOrGroupId);
        }

        Set<String> toAddresses = new Set<String>();
        for(User us : [SELECT Email FROM User WHERE Id IN: userIds AND IsActive = true]){
            toAddresses.add(us.Email);
        }

        if(toAddresses.size() == 0) return;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Daily Purge Event Job Has Run');
        email.setHtmlBody('Hello, <br/><br/>Daily email job has finished.<br/>');
        email.setToAddresses(new List<String>(toAddresses));

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }catch(Exception exc){
            ErrorLogHelper.createErrorLog('SchPurgeEvents', 'sendEmail', exc.getMessage());
        }
    }

}