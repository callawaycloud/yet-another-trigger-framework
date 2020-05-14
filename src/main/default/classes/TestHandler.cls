@isTest
public class TestHandler extends BaseTriggerHandler {
    public Boolean ran = false;
    public void handle() {
        ran = true;
    }
}
