@isTest
public class TestHandler extends BaseHandler {
    public Boolean ran = false;
    public void handle() {
        ran = true;
    }
}