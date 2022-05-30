global without sharing class Handler2 extends BaseHandler {
    global static boolean throwException = false;
    global void handle() {
        if(throwException == true){
            System.debug('Exception thrown');
            throw new EventHandlingTestException('Throwing event exception!');
        }
        for (SObject sObj : context.newRecords) {
            sObj.put('Handler2__c', true);
            system.debug(sObj.get('Handler2__c'));
        }
    }

    class EventHandlingTestException extends Exception {}
}
