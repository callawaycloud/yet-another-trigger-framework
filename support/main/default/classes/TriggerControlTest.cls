@isTest
private class TriggerControlTest {
  private static final TestRecordJSON =

  @isTest
  private static void testNoControl() {
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testContactHandler2Disable() {
    disable('Contact', 'Handler2');
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testContactHandler1Disable() {
    disable('Contact', 'Handler1');
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = false;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testAccountHandler2Disable() {
    disable('Account', 'Handler2');
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = false;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testAccountHandler1Disable() {
    disable('Account', 'Handler1');
    Boolean acctHandler1Fired = false;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testHandler2Disable() {
    disable(null, 'Handler2');
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = false;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testHandler1Disable() {
    disable(null, 'Handler1');
    Boolean acctHandler1Fired = false;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = false;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testContactDisable() {
    disable('Contact', null);
    Boolean acctHandler1Fired = true;
    Boolean acctHandler2Fired = true;
    Boolean contactHandler1Fired = false;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  @isTest
  private static void testAccountDisable() {
    disable('Account', null);
    Boolean acctHandler1Fired = false;
    Boolean acctHandler2Fired = false;
    Boolean contactHandler1Fired = true;
    runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  }

  private static void runTest(
    Boolean acctHandler1Fired,
    Boolean acctHandler2Fired,
    Boolean contactHandler1Fired
  ) {
    Id acctId = createAccount();
    checkAccount(acctId, acctHandler1Fired, acctHandler2Fired);
    Id contactId = createContact();
    checkContact(contactId, contactHandler1Fired);
  }

  // NB: current version replaces all trigger controls with each call, which
  // is plenty for the current test methods
  private static Trigger_Object__mdt generateObjMetadata(String objName, Boolean enabled){
    Trigger_Object__mdt trig_obj = new Trigger_Object__mdt(
      Object__c = objName,
      Enabled__c = enabled
    );
  }
  private static void disableObj(String objectName, String handlerClassName) {
    TriggerHandler.
      // NEED TO REPLACE WITH NEW METADATA
      /*
    TriggerHandler.cacheTriggerControl(
      new List<Trigger_Control__mdt>{
        new Trigger_Control__mdt(
          Object__c = objectName,
          Class__c = handlerClassName
        )
      }
    );
	*/
  }

  private static void checkContact(Id contactId, Boolean handler1Fired) {
    Contact contact = [SELECT Handler1__c FROM Contact WHERE Id = :contactId];
    System.assertEquals(contact.Handler1__c, handler1Fired);
  }

  private static void checkAccount(
    Id acctId,
    Boolean handler1Fired,
    Boolean handler2Fired
  ) {
    Account acct = [
      SELECT Handler1__c, Handler2__c
      FROM Account
      WHERE Id = :acctId
    ];
    System.assertEquals(acct.Handler1__c, handler1Fired);
    System.assertEquals(acct.Handler2__c, handler2Fired);
  }

  private static Id createAccount() {
    Account record = new Account(Name = 'Test');
    insert record;
    return record.Id;
  }

  private static Id createContact() {
    Contact record = new Contact(LastName = 'Test');
    insert record;
    return record.Id;
  }
}