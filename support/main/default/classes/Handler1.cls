public without sharing class Handler1 extends BaseTriggerHandler {
  public void handle() {
    for (SObject sObj : context.newRecords) {
      sObj.put('Handler1__c', true);
    }
  }
}
