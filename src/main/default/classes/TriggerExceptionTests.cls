/*
*  This class has to exist to cover the baked in exception management classes
*  SendEmailExceptionEventHandler, ExceptionEvent, and TriggerHandlerException
*/

@isTest
public with sharing class TriggerExceptionTests {
    @isTest
    public static void TriggerExceptionTests() {
        // we don't need to hit the database, just need to pass in what's needed for the test
        HandlerConfig hConfig = TriggerManageTests.generateHandlerTestData('TestHandler', true);
        Trigger_Handler_Exception__e thevt = new Trigger_Handler_Exception__e(
            User_Name__c = System.UserInfo.getUserName(),
            Exception_Type__c = 'textString',
            Exception_Message__c = 'textString',
            Stack_Trace__c = 'textString',
            Handler_Config_Id__c = 'textString',
            Handler_Config__c = JSON.serialize(hConfig),
            SObject_Type__c = 'Account',
            Trigger_Operation__c = 'Before_Insert',
            size__c = 1,
            New_Records__c = null,
            Old_Records__c = null
        );
        ExceptionEvent excEvt = new ExceptionEvent(thevt);
        // excEvt.config = hConfig;
        // excEvt.event =
        // excEvt.message = 'Test exception';
        // excEvt.operationType = System.TriggerOperation.BEFORE_INSERT;
        // excEvt.size = 1;
        // excEvt.SObjectType = 'Account';
        // excEvt.stackTrace = '--- test stack trace ---';
        // excEvt.type = 'test type';
        // excEvt.user = 'testuser';

        SendEmailExceptionEventHandler emailExEvHandler = new SendEmailExceptionEventHandler();
        emailExEvHandler.fromEmailAddress = 'test@example.com';
        emailExEvHandler.recipients = new String[]{'test@recip.com', 'test2@recip.com'};
        emailExEvHandler.handleExceptionEvents(excEvt);
    }
}
