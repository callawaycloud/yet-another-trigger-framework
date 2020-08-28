public without sharing class Handler2 extends BaseHandler {
    public void handle() {
        for (SObject sObj : context.newRecords) {
            sObj.put('Handler2__c', true);
            system.debug(sObj.get('Handler2__c'));
        }
    }
}
