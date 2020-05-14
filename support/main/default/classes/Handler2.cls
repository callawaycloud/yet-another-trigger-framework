public without sharing class Handler2 implements TriggerHandler.HandlerInterface {
    public void handle() {
        for (SObject sObj : Trigger.new) {
            sObj.put('Handler2__c', true);
            system.debug(sObj.get('Handler2__c'));
        }
    }
}