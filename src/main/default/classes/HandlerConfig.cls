/**
 * Class used to store all things related to a handler setup
 */
global class HandlerConfig {
    global enum ExceptionStrategy {
        RETHROW,
        USE_SAVEPOINT,
        SUPPRESS
    }

    global transient Handler handler;

    global String id;
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

    //Error Handling
    global ExceptionStrategy onException;
    global Boolean createExceptionEvent;
    global String exceptionHandlerClassName;
    // global Map<String, Object> additionalExceptionConfiguration;

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
        id = th.Id;
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

        // error management
        onException = ExceptionStrategy.RETHROW;
        switch on th.On_Exception__c {
            when 'Suppress' {
                onException = ExceptionStrategy.SUPPRESS;
            }
            when 'Rollback' {
                onException = ExceptionStrategy.USE_SAVEPOINT;
            }
        }

        createExceptionEvent = th.Create_Exception_Event__c;
        exceptionHandlerClassName = th.On_Exception_Event_Handler__c;
    }
}
