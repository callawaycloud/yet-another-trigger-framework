@isTest
public class BaseTriggerTest {
  @isTest
  private static void testInMemoryBaseClass() {
    Account acc1 = new Account();
    acc1.name = 'abc';

    Account acc2 = new Account();
    acc2.name = 'abc';

    Handler3 h = new Handler3();
    h.context = new TriggerContext(System.TriggerOperation.BEFORE_INSERT, new Account[]{acc1, acc2}, null);
    h.handle();
    System.assertEquals(acc1.name, 'foo');
    System.assertEquals(acc2.name, 'foo');
  }
}
