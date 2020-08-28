/**
 * Class used to store all things related to a handler setup
 */
global class HandlerConfig {
    global enum ExceptionStrategy {
        RETHROW,
        SUPPRESS,
        EMAIL,
        CUSTOM
    }

    global Handler handler;

    global String className;
    global Boolean enabled;
    global Decimal order;
    global Boolean beforeInsert;
    global Boolean afterInsert;
    global Boolean beforeUpdate;
    global Boolean afterUpdate;
    global Boolean beforeDelete;
    global Boolean afterDelete;
    global Boolean afterUndelete;
    global ExceptionStrategy onException;
    global List<String> exceptionEmailRecipients;
    global String exceptionHandlerClassName;

    global HandlerConfig() {
    }

    /**
     * Constructor for missing config
     */
    global HandlerConfig(String className) {
        this.className = className;
        enabled = true;
        onException = ExceptionStrategy.RETHROW;
    }

    /**
     * Constructor used for dynamic bound handlers
     */
    global HandlerConfig(Trigger_Handler__mdt th) {
        className = th.Handler_Class__c.toLowerCase();
        enabled = th.Enabled__c;
        order = th.Execution_Order__c;
        beforeInsert = th.Before_Insert__c;
        afterInsert = th.After_Insert__c;
        beforeUpdate = th.Before_Update__c;
        afterUpdate = th.After_Update__c;
        beforeDelete = th.Before_Delete__c;
        afterDelete = th.After_Delete__c;
        afterUndelete = th.After_Undelete__c;
        onException = ExceptionStrategy.RETHROW;
        switch on th.On_Exception__c {
            when 'Suppress' {
                onException = ExceptionStrategy.SUPPRESS;
            }
            when 'Email' {
                if (!String.isEmpty(th.On_Exception_Email_Addresses__c)) {
                    onException = ExceptionStrategy.EMAIL;
                    exceptionEmailRecipients = th.On_Exception_Email_Addresses__c.split(',');
                }
            }
            when 'Custom Handler' {
                if (!String.isEmpty(th.On_Exception_Custom_Handler__c)) {
                    onException = ExceptionStrategy.CUSTOM;
                    exceptionHandlerClassName = th.On_Exception_Custom_Handler__c;
                } else {
                    System.debug('WARNING: "On_Exception__c" set to "Custom Handler" but handler was not specified.');
                }
            }
        }
    }
}
