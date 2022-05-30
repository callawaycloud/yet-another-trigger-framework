trigger TriggerHandlerException on Trigger_Handler_Exception__e(after insert) {
    Map<String, List<ExceptionEvent>> exceptionHandlers = new Map<String, List<ExceptionEvent>>();
    Set<Id> configIds = new Set<Id>();
    for (Trigger_Handler_Exception__e e : Trigger.new) {
        configIds.add(e.Handler_Config_Id__c);
    }

    Map<Id, Trigger_Handler__mdt> evtHandlerPropsMap = new Map<Id, Trigger_Handler__mdt>(
        [SELECT On_Exception_Event_Handler_Props__c FROM Trigger_Handler__mdt WHERE Id IN :configIds]
    );

    for (Trigger_Handler_Exception__e e : Trigger.new) {
        ExceptionEvent event = new ExceptionEvent(e);
        if (event.config.exceptionHandlerClassName == null) {
            continue;
        }
        String handlerProps = evtHandlerPropsMap.get(e.Handler_Config_Id__c)?.On_Exception_Event_Handler_Props__c;
        try {
            ExceptionEventHandler evtHandler = (ExceptionEventHandler) Utils.constructFromName(
                event.config.exceptionHandlerClassName,
                handlerProps
            );
            evtHandler.handleExceptionEvents(event);
        } catch (Exception evtHandlerException) {
            System.debug(evtHandlerException);
        }
    }
}
