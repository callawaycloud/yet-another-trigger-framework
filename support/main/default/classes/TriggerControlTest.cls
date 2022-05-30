@isTest
private class TriggerControlTest {
    private static Map<String, TriggerConfigService.ObjectConfig> buildMetadata() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = new Map<String, TriggerConfigService.ObjectConfig>();
        TriggerConfigService.ObjectConfig acct = generateObjTestData('account', true);
        TriggerConfigService.ObjectConfig cont = generateObjTestData('contact', true);
        acct = addChildHandlerToObj(acct, generateHandlerTestData('handler1', true));
        // handler2 directly binds in trigger
        // acct = addChildHandlerToObj(acct, generateHandlerTestData('handler2', true));
        cont = addChildHandlerToObj(cont, generateHandlerTestData('handler1', true));
        mdt.put('account', acct);
        mdt.put('contact', cont);
        return mdt;
    }

    @isTest
    private static void testNoControl() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void testContactHandler1Disable() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        mdt = disableHandler(mdt, 'contact', 'handler1');
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = false;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void testAccountHandler2Disable() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        addChildHandlerToObj(mdt.get('account'), generateHandlerTestData('handler2', true));
        mdt = disableHandler(mdt, 'account', 'handler2');
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = false;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void testAccountHandler1Disable() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        mdt = disableHandler(mdt, 'account', 'handler1');
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = false;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void testContactDisable() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        mdt = disableObj(mdt, 'contact');
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = false;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void testAccountDisable() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        mdt = disableObj(mdt, 'account');
        TriggerConfigService.configMetadata = mdt;
        Boolean acctHandler1Fired = false;
        Boolean acctHandler2Fired = false;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void runAllEvents() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = new Map<String, TriggerConfigService.ObjectConfig>();
        TriggerConfigService.ObjectConfig acct = generateObjTestData('account', true);
        HandlerConfig h3 = new HandlerConfig();
        h3.className = 'handler3';
        h3.enabled = true;
        h3.order = 0;
        //h3.autoBind = true;
        h3.beforeInsert = true;
        h3.afterInsert = true;
        h3.beforeUpdate = true;
        h3.afterUpdate = true;
        h3.beforeDelete = true;
        h3.afterDelete = true;
        h3.afterUndelete = true;
        acct = addChildHandlerToObj(acct, h3);
        mdt.put('account', acct);
        TriggerConfigService.configMetadata = mdt;
        Id aId = createAccount();
        Account a = new Account(Id = aId);

        update a;
        delete a;
        undelete a;

        // all events should have fired:
        System.assert(Handler3.events.contains('beforeInsert'), 'beforeInsert should have fired');
        System.assert(Handler3.events.contains('afterInsert'), 'afterInsert should have fired');
        System.assert(Handler3.events.contains('beforeUpdate'), 'beforeUpdate should have fired');
        System.assert(Handler3.events.contains('afterUpdate'), 'afterUpdate should have fired');
        System.assert(Handler3.events.contains('beforeDelete'), 'beforeDelete should have fired');
        System.assert(Handler3.events.contains('afterDelete'), 'afterDelete should have fired');
        System.assert(Handler3.events.contains('afterUndelete'), 'afterUndelete should have fired');
        System.assert(Handler3.events.size() == 7, 'All events should have fired one time');
    }

    @isTest
    private static void invalidHandlerTest() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        TriggerConfigService.ObjectConfig objConfig = mdt.get('contact');
        //objConfig.disabledHandlers.clear();
        objConfig.handlerOrder.clear();
        objConfig.handlers.clear();
        HandlerConfig handlerConfig = generateHandlerTestData('badNameClass', true);
        addChildHandlerToObj(objConfig, handlerConfig);
        mdt.put('contact', objConfig);
        TriggerConfigService.configMetadata = mdt;
        // invalid class name should not run - currently just debugs
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = false;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
    }

    @isTest
    private static void duplicateBindingTest() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        TriggerConfigService.ObjectConfig objConfig = mdt.get('contact');
        HandlerConfig handlerConfig = generateHandlerTestData('handler1', true);
        addChildHandlerToObj(objConfig, handlerConfig);
        mdt.put('contact', objConfig);
        TriggerConfigService.configMetadata = mdt;
        // class should only run once - currently just debugs
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
        // handler 1 should run once for account and once for contact
        system.assertEquals(2, Handler1.runCount, 'Handler should only run once per object');
    }

    @isTest
    private static void additionalCoverage() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        TriggerConfigService.ObjectConfig objConfig = mdt.get('account');
        HandlerConfig handlerConfig = generateHandlerTestData('handler2', true);
        addChildHandlerToObj(objConfig, handlerConfig);
        mdt.put('contact', objConfig);
        TriggerConfigService.configMetadata = mdt;
        // class should only run once - currently just debugs
        Boolean acctHandler1Fired = true;
        Boolean acctHandler2Fired = true;
        Boolean contactHandler1Fired = true;
        runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
        // handler 1 should run once for account and once for contact
        system.assertEquals(2, Handler1.runCount, 'Handler should only run once per object');
    }

    @isTest
    private static void testExceptionHandling() {
        // Map<String, TriggerConfigService.ObjectConfig> mdt = buildMetadata();
        // TriggerConfigService.ObjectConfig objConfig = mdt.get('account');
        // HandlerConfig hc = generateHandlerTestData('handler2', true);
        // hc.createExceptionEvent = true;
        // hc.onException = HandlerConfig.ExceptionStrategy.RETHROW;
        // hc.exceptionHandlerClassName = 'SendEmailExceptionEventHandler';
        // addChildHandlerToObj(objConfig, hc);
        // mdt.put('account', objConfig);
        // TriggerConfigService.configMetadata = mdt;

        // Don't do any mdt setup - we need to auto bind with the handler2 config
        Boolean hitException = false;
        Test.startTest();
        try{
            Boolean acctHandler1Fired = true;
            Boolean acctHandler2Fired = false;
            Boolean contactHandler1Fired = true;
            Handler2.throwException = true;
            runTest(acctHandler1Fired, acctHandler2Fired, contactHandler1Fired);
        } catch (Exception e) {
            hitException = true;
        }

        Test.stopTest();

        System.assertEquals(true, hitException, 'Should have had thrown exception');
    }

    private static void runTest(Boolean acctHandler1Fired, Boolean acctHandler2Fired, Boolean contactHandler1Fired) {
        system.debug(TriggerConfigService.configMetadata);
        Id acctId = createAccount();
        checkAccount(acctId, acctHandler1Fired, acctHandler2Fired);
        Id contactId = createContact();
        checkContact(contactId, contactHandler1Fired);
    }

    // NB: current version replaces all trigger controls with each call, which
    // is plenty for the current test methods
    private static TriggerConfigService.ObjectConfig generateObjTestData(String objName, Boolean enabled) {
        TriggerConfigService.ObjectConfig trigObj = new TriggerConfigService.ObjectConfig();
        trigObj.objName = objName;
        trigObj.enabled = enabled;
        return trigObj;
    }

    // Add additional params for each trigger evt?
    private static HandlerConfig generateHandlerTestData(String className, Boolean enabled) {
        HandlerConfig handler = new HandlerConfig();
        handler.className = className;
        handler.enabled = enabled;
        //handler.autoBind = true;
        handler.order = 0;
        handler.beforeInsert = true;
        handler.afterInsert = false;
        handler.beforeDelete = true;
        handler.afterDelete = false;
        handler.afterUndelete = false;
        handler.beforeUpdate = true;
        handler.afterUpdate = false;
        return handler;
    }

    private static TriggerConfigService.ObjectConfig addChildHandlerToObj(
        TriggerConfigService.ObjectConfig obj,
        HandlerConfig handler
    ) {
        if (obj.handlers == null) {
            obj.handlers = new Map<String, HandlerConfig>();
        }
        obj.handlers.put(handler.className, handler);
        obj.handlerOrder.add(handler.className);
        return obj;
    }

    private static Map<String, TriggerConfigService.ObjectConfig> disableObj(
        Map<String, TriggerConfigService.ObjectConfig> mdt,
        String objectName
    ) {
        TriggerConfigService.ObjectConfig obj = mdt.get(objectName);
        obj.enabled = false;
        mdt.put(objectName, obj);
        return mdt;
    }

    private static Map<String, TriggerConfigService.ObjectConfig> disableHandler(
        Map<String, TriggerConfigService.ObjectConfig> mdt,
        String objectName,
        String className
    ) {
        TriggerConfigService.ObjectConfig obj = mdt.get(objectName);
        obj.handlers.get(className).enabled = false;
        mdt.put(objectName, obj);
        return mdt;
    }

    private static void checkContact(Id contactId, Boolean handler1Fired) {
        Contact contact = [SELECT Handler1__c FROM Contact WHERE Id = :contactId];
        System.assertEquals(contact.Handler1__c, handler1Fired);
    }

    private static void checkAccount(Id acctId, Boolean handler1Fired, Boolean handler2Fired) {
        Account acct = [SELECT Handler1__c, Handler2__c FROM Account WHERE Id = :acctId];
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
