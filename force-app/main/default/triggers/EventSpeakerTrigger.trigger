trigger EventSpeakerTrigger on EventSpeaker__c (before insert, before update) {

    if(Trigger.isBefore){

        if(Trigger.isInsert || Trigger.isUpdate){
            EventSpeakerHandler.checkDuplicateSpeakerOnEvents(Trigger.new);
        }

    }

}