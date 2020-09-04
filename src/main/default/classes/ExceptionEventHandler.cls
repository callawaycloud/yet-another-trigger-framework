/**
 * Interface to implement when subscribing to `Trigger_Handler_Exception__e` events via `On_Exception_Event_Handler__c`
 */
global interface ExceptionEventHandler {
    /**
     * Run Exception Event logic
     * @param event Contains information about exception, handler and trigger context
     */
    void handleExceptionEvents(ExceptionEvent event);
}
