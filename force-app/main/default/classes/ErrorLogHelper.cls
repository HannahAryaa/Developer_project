public with sharing class ErrorLogHelper {
    
    public static void createErrorLog(String className, String processName, String details){
        insert new ErrorLog__c(ApexClass__c = className,
                               ProcessName__c = processName,
                               LogDetails__c = details,
                               LogDateTime__c = Datetime.now()
                              );
    }

}