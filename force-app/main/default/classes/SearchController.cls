public with sharing class SearchController {
    
    @AuraEnabled
    public static String searchRecords(String objName, String fieldName, String searchKey){
        String searchKeyword = searchKey + '*';
        String returningQuery = objName + ' ( Id, ' + fieldName + ')';

        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING ' + returningQuery + ' LIMIT 2000';

        List<List<SObject>> records = Search.query(query);
        return JSON.serialize(records);
    }

}