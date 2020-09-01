/**
 * Abstraction of the  Trigger_Handler_Exception__e that is
 *   passed to `ExceptionEventHandler`
 */
global class ExceptionEvent {
    public String type;
    public String message;
    public String stackTrace;
    public String user;
    public HandlerConfig config;

    public TriggerOperation operationType;
    public Integer size;
    public String SObjectType;

    // useful for further serialization of records and what-not
    public Trigger_Handler_Exception__e event;

    public ExceptionEvent(Trigger_Handler_Exception__e e) {
        this.event = e;
        config = (HandlerConfig) JSON.deserialize(e.Handler_Config__c, HandlerConfig.class);

        // Exception Details
        type = e.Exception_Type__c;
        message = e.Exception_Message__c;
        stackTrace = e.Stack_Trace__c;

        // Context
        user = e.User_Name__c;
        sObjectType = e.SObject_Type__c;
        operationType = (TriggerOperation) Utils.parseEnum(e.Trigger_Operation__c, TriggerOperation.class);
        size = (Integer) e.Size__c;
    }
}
