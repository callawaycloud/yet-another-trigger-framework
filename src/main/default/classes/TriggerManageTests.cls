@isTest
public class TriggerManageTests {
    @isTest
    private static void staticBinding() {
        // clear out metadata since we don't want any actual triggers firing
        Map<String, TriggerConfigService.ObjectConfig> mdt = new Map<String, TriggerConfigService.ObjectConfig>();
        TriggerConfigService.ObjectConfig acct = generateObjTestData('account', true);
        // all events on handler set to false - allows for static binding
        HandlerConfig handler = generateHandlerTestData('TestHandler', true);
        acct = addChildHandlerToObj(acct, handler);
        mdt.put('account', acct);
        TriggerConfigService.configMetadata = mdt;
        Account[] records = new List<Account>{ new Account() };

        TriggerContext context = new TriggerContext(System.TriggerOperation.BEFORE_INSERT, records, null);
        Manager th = new Manager(context);

        TestHandler beforeInsertHandler = new TestHandler();
        th.bind(Manager.Evt.beforeInsert, beforeInsertHandler);

        TestHandler afterInsertHandler = new TestHandler();
        th.bind(Manager.Evt.afterInsert, afterInsertHandler);

        th.manage();

        System.assertEquals(true, beforeInsertHandler.ran);
        System.assertEquals(false, afterInsertHandler.ran);
    }

    @isTest
    private static void testAllHandlerEvts() {
        Map<String, TriggerConfigService.ObjectConfig> mdt = new Map<String, TriggerConfigService.ObjectConfig>();
        TriggerConfigService.ObjectConfig acct = generateObjTestData('account', true);
        HandlerConfig handler = generateHandlerTestData('TestHandler', true);
        handler.beforeInsert = true;
        handler.afterInsert = true;
        handler.beforeUpdate = true;
        handler.afterUpdate = true;
        handler.beforeDelete = true;
        handler.afterDelete = true;
        acct = addChildHandlerToObj(acct, handler);
        mdt.put('account', acct);
        TriggerConfigService.configMetadata = mdt;
        System.debug(JSON.serializePretty(TriggerConfigService.configMetadata));
        Account a = new Account();
        // before insert
        TriggerContext tc = new TriggerContext(
            System.TriggerOperation.BEFORE_INSERT,
            new List<Account>{ a },
            new List<Account>{ a }
        );
        Manager th = new Manager(tc);
        th.manage();

        // after insert
        tc = new TriggerContext(System.TriggerOperation.AFTER_INSERT, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();

        // before update
        tc = new TriggerContext(System.TriggerOperation.BEFORE_UPDATE, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();

        // after update
        tc = new TriggerContext(System.TriggerOperation.AFTER_UPDATE, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();

        // before delete
        tc = new TriggerContext(System.TriggerOperation.BEFORE_DELETE, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();

        // after delete
        tc = new TriggerContext(System.TriggerOperation.AFTER_DELETE, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();

        // after undelete
        tc = new TriggerContext(System.TriggerOperation.AFTER_UNDELETE, new List<Account>{ a }, new List<Account>{ a });
        th = new Manager(tc);
        th.manage();
    }

    @isTest
    private static void testTriggerContext() {
        // cover the lines we can't really test without a trigger
        TriggerContext.triggerCoverage = true;
        TriggerContext tc = new TriggerContext();
        TriggerConfigService.buildConfigMap();
    }

    @isTest
    private static void testExceptionManager() {
        // code coverage for exception manager class
        ExceptionManager em = new ExceptionManager();
        TestManagerException exc = new TestManagerException('test');
        TriggerContext tc = new TriggerContext();
        tc.sObjectType = 'testobj';

        HandlerConfig hc = new HandlerConfig();
        hc.createExceptionEvent = true;
        em.manage(exc, tc, hc, null);
    }

    @isTest
    private static void testTriggerConfig() {
        // coverage for the custom metadata dependant elements of the config
        Map<String, TriggerConfigService.ObjectConfig> objConfig = TriggerConfigService.configMetadata;
        Trigger_Object__mdt objMdt = new Trigger_Object__mdt(Object_API_Name__c = 'account', Enabled__c = true);
        TriggerConfigService.ObjectConfig objWrapper = new TriggerConfigService.ObjectConfig(
            objMdt.Enabled__c,
            objMdt.Object_API_Name__c
        );

        Trigger_Handler__mdt handlerMdt = new Trigger_Handler__mdt(
            Handler_Class__c = 'TriggerHandler',
            Enabled__c = true,
            Execution_Order__c = 0,
            Before_Insert__c = false,
            After_Insert__c = false,
            Before_Delete__c = false,
            After_Delete__c = false,
            After_Undelete__c = false,
            Before_Update__c = false,
            After_Update__c = false
        );

        HandlerConfig handlerWrapper = new HandlerConfig(handlerMdt);
    }

    private static TriggerConfigService.ObjectConfig generateObjTestData(String objName, Boolean enabled) {
        TriggerConfigService.ObjectConfig trigObj = new TriggerConfigService.ObjectConfig();
        trigObj.objName = objName;
        trigObj.enabled = enabled;
        return trigObj;
    }

    // used by other tests
    public static HandlerConfig generateHandlerTestData(String className, Boolean enabled) {
        HandlerConfig handler = new HandlerConfig();
        handler.className = className;
        handler.enabled = enabled;
        handler.order = 0;
        handler.beforeInsert = false;
        handler.afterInsert = false;
        handler.beforeDelete = false;
        handler.afterDelete = false;
        handler.afterUndelete = false;
        handler.beforeUpdate = false;
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
    public class TestManagerException extends Exception{}
}
