public without sharing class Handler1 implements TriggerHandler.HandlerInterface {
    public static integer runCount = 0;
    public void handle() {
        for (SObject sObj : Trigger.new) {
            sObj.put('Handler1__c', true);
            runCount++;
        }
    }
}