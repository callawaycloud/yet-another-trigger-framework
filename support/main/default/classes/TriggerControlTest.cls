@isTest
private class TriggerControlTest {
  private static Trigger_Object__mdt[] buildMetadata(){
    Trigger_Object__mdt[] mdt = new Trigger_Object__mdt[]{};
    Trigger_Object__mdt acct = generateObjMetadata('Account', true);
    Trigger_Object__mdt cont = generateObjMetadata('Contact', true);
    acct =  addChildHandlerToObj(acct, generateHandlerMdt('handler1', true));
    acct = addChildHandlerToObj(acct, generateHandlerMdt('handler2', true));
    cont =  addChildHandlerToObj(cont, generateHandlerMdt('handler1', true));
    cont = addChildHandlerToObj(cont, generateHandlerMdt('handler2', true));
    mdt.add(acct);
    mdt.add(cont);
    return mdt;
  }

  @isTest
  private static void testNoControl() {
    Trigger_Object__mdt[] mdt = buildMetadata();
    TriggerHandler.configMetadata = mdt;
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

  // @isTest
  // private static void testHandler2Disable() {
  //   disable(null, 'Handler2');
  //   Boolean acctHandler1Fired = true;
  //   Boolean acctHandler2Fired = false;
  //   Boolean contactHandler1Fired = true;
  //   runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  // }

  // @isTest
  // private static void testHandler1Disable() {
  //   disable(null, 'Handler1');
  //   Boolean acctHandler1Fired = false;
  //   Boolean acctHandler2Fired = true;
  //   Boolean contactHandler1Fired = false;
  //   runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
  // }

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
    system.debug(TriggerHandler.configMetadata);
    system.debug(TriggerHandler.configMetadata[0].Trigger_Handlers__r[0]);
    Id acctId = createAccount();
    checkAccount(acctId, acctHandler1Fired, acctHandler2Fired);
    Id contactId = createContact();
    checkContact(contactId, contactHandler1Fired);
  }

  // NB: current version replaces all trigger controls with each call, which
  // is plenty for the current test methods
  private static Trigger_Object__mdt generateObjMetadata(String objName, Boolean enabled){
    Trigger_Object__mdt trigObj = new Trigger_Object__mdt(
      Object__c = objName,
      Enabled__c = enabled
    );
    return trigObj;
  }

 // Add additional params for each trigger evt?
  private static Trigger_Handler__mdt generateHandlerMdt(
    String className,
    Boolean enabled
  ){
    Trigger_Handler__mdt handlerMdt = new Trigger_Handler__mdt(
      Handler_Class__c = className,
      Enabled__c = enabled,
      Auto_Bind__c = true,
      Execution_Order__c = 0,
      Before_Insert__c = true,
      After_Insert__c = false,
      Before_Delete__c = true,
      After_Delete__c = false,
      After_Undelete__c = false,
      Before_Update__c = true,
      After_Update__c = false
    );
    return handlerMdt;
  }

  private static Trigger_Object__mdt addChildHandlerToObj(Trigger_Object__mdt obj, Trigger_Handler__mdt handler){
    System.debug(handler);
    if(obj.Trigger_Handlers__r == null){
      obj.Trigger_Handlers__r = new Trigger_Handler__mdt[]{};
    }
    system.debug(obj.Trigger_Handlers__r);
    obj.Trigger_Handlers__r.add(handler);
    system.debug(obj.Trigger_Handlers__r);
    return obj;
  }

  private static void disable(String objectName, String handlerClassName) {
    Trigger_Object__mdt triggerObj = generateObjMetadata(objectName, true);
    Trigger_Handler__mdt handlerMdt = generateHandlerMdt(handlerClassName, false);
    addChildHandlerToObj(triggerObj, handlerMdt);
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