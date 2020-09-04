/**
 * Control logic for uncaught `Handler` exceptions
 */
public class ExceptionManager {
    //messages that will be sent before
    public void manage(Exception e, TriggerContext context, HandlerConfig config, Savepoint sp) {
        if (sp != null) {
            Database.rollback(sp);
        }

        publishEvent(e, context, config);

        if (config.onException == HandlerConfig.ExceptionStrategy.RETHROW) {
            throw e;
        }
    }

    private void publishEvent(Exception e, TriggerContext context, HandlerConfig config) {
        if (config.createExceptionEvent) {
            EventBus.publish(
                new List<Trigger_Handler_Exception__e>{
                    new Trigger_Handler_Exception__e(
                        User_Name__c = System.UserInfo.getUserName(),
                        Exception_Type__c = e.getTypeName(),
                        Exception_Message__c = e.getMessage(),
                        Stack_Trace__c = e.getStackTraceString(),
                        Handler_Config_Id__c = config.id,
                        Handler_Config__c = JSON.serialize(config),
                        SObject_Type__c = context.sObjectType,
                        Trigger_Operation__c = context.operationType.name(),
                        size__c = context.size,
                        New_Records__c = context.newRecords != null
                            ? JSON.serialize(context.newRecords).abbreviate(131072)
                            : null,
                        Old_Records__c = context.oldRecords != null
                            ? JSON.serialize(context.oldRecords).abbreviate(131072)
                            : null
                    )
                }
            );
        }
    }
}
