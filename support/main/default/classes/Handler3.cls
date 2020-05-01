public class Handler3 extends BaseTriggerHandler {
  public void handle() {
    for (Account acc : (Account[]) context.newRecords) {
      acc.Name = 'foo';
    }
  }
}
