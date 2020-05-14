@isTest
public class TriggerManageTests {
    @isTest
    private static void staticBinding() {
        Account[] records = new List<Account>{ new Account() };

        TriggerContext context = new TriggerContext(System.TriggerOperation.BEFORE_INSERT, records, null);
        TriggerHandler th = new TriggerHandler(context);

        TestHandler beforeInsertHandler = new TestHandler();
        th.bind(TriggerHandler.Evt.beforeInsert, beforeInsertHandler);

        TestHandler afterInsertHandler = new TestHandler();
        th.bind(TriggerHandler.Evt.afterInsert, afterInsertHandler);

        th.manage();

        System.assertEquals(true, beforeInsertHandler.ran);
        System.assertEquals(false, afterInsertHandler.ran);
    }
}
