// Based on https://github.com/joeferraro/MavensMate-Templates/blob/master/ApexClass/TriggerHandler.cls
public class TriggerHandler {
    /**
     *   Enum representing each of before/after CRUD events on Sobjects
     */
    public enum Evt {
        afterDelete,
        afterInsert,
        afterUndelete,
        afterUpdate,
        beforeDelete,
        beforeInsert,
        beforeUpdate
    }

    /*
     *   Simplistic handler to implement on any of the event. It doesn't require or enforces any pattern except the
     *   method name to be "handle()".
     */
    public interface HandlerInterface {
        void handle();
    }

    // Internal mapping of handlers
    Map<String, List<HandlerInterface>> eventHandlerMapping = new Map<String, List<HandlerInterface>>();

    public TriggerHandler(){
        String objName = getSObjectType(Trigger.new[0]);
        doAutomaticBinding(objName);
    }

    /**
     *   Core API to bind handlers with events
     */
    public TriggerHandler bind(Evt event, HandlerInterface eh) {
        List<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) {
            handlers = new List<HandlerInterface>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of Trigger and available registered handlers
     */
    public void manage() {
        if (objectDisabled(sObjectType))
            return;

        Evt ev = null;
        if (Trigger.isInsert && Trigger.isBefore) {
            ev = Evt.beforeInsert;
        } else if (Trigger.isInsert && Trigger.isAfter) {
            ev = Evt.afterInsert;
        } else if (Trigger.isUpdate && Trigger.isBefore) {
            ev = Evt.beforeUpdate;
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            ev = Evt.afterUpdate;
        } else if (Trigger.isDelete && Trigger.isBefore) {
            ev = Evt.beforeDelete;
        } else if (Trigger.isDelete && Trigger.isAfter) {
            ev = Evt.afterDelete;
        } else if (Trigger.isUndelete) {
            ev = Evt.afterUndelete;
        }

        List<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());

        if (handlers != null && !handlers.isEmpty()) {
            for (HandlerInterface h : handlers) {
                if (!handlerDisabled(h) && !objectHandlerDisabled(sObjectType, h)) {
                    h.handle();
                }
            }
        }
    }

    private void doAutomaticBinding(String sObjName){
        for(Trigger_Object__mdt triggerObj : configMetadata){
            if(sObjName == triggerObj.Object__c){
                for(Trigger_Handler__c handler : triggerObj.Trigger_Handler__r){
                    if(After_Insert__c){
                        try{
                            Type t = Type.forName(handler.Handler_Class__c);
                        } catch {
                            // friendly non-exploding notificaiton?
                            System.debug('Looks like you accidently made up a thing that doesnt exist');
                        }
                        Shape newObj = (Shape)t.newInstance();
                        bind(Evt.afterInsert, (HandlerInterface) )
                    }
                }
            }
        }
    }

    private static Set<String> disabledObjects = new Set<String>();
    private static Set<String> disabledHandlers = new Set<String>();
    private static Map<String, Set<String>> disabledObjectHandlers = new Map<String, Set<String>>();

    private static Trigger_Object__mdt[] configMetadata {
        get {
            if(configMetadata == null){
                configMetadata = [
                SELECT
                    Object__c,
                    Enabled__c,
                    (
                    select
                        Handler_Class__c,
                        Auto_Bind__c,
                        Enabled__c,
                        Execution_Order__c,
                        Before_Insert__c,
                        After_Insert__c,
                        Before_Delete__c,
                        After_Undelete__c,
                        Before_Update__c,
                        After_Update__c
                    from
                        Trigger_Handler__r
                    order by
                        Execution_Order__c
                    )
                FROM
                    Trigger_Object__mdt
                ];
            }
            return configMetadata;
        }
        set;
    }

    // Build a wrapper for this? Feels messy.
    // @TestVisible
    // private class ConfigMetadata{
    //     String ObjectName;
    //     String ClassName;

    //     @TestVisible
    //     private ConfigMetadata(Trigger_Object__mdt triggerObj){

    //     }
    // }

    @TestVisible
    private static void cacheTriggerControl() {
        Trigger_Object__mdt[] triggerObjects = configMetadata;
        disabledObjects.clear();
        disabledHandlers.clear();
        disabledObjectHandlers.clear();
        for (Trigger_Object__mdt triggerObject : triggerObjects) {
            String objectName = triggerObject.Object__c == null ? null : triggerControl.Object__c.toLowerCase();
            if(!triggerObject.Enabled__c){
                disabledObjects.add(objectName);
            }
            for(Trigger_Handler__mdt handler : triggerObject.Trigger_Handler__r){
                String handlerName = handler.Handler_Class__c == null ? null : handler.Handler_Class__c.toLowerCase();
                if(!handler.Enabled__c){
                    if (!disabledObjectHandlers.containsKey(objectName)) {
                        disabledObjectHandlers.put(objectName, new Set<String>());
                    }
                    disabledObjectHandlers.get(objectName).add(handlerName);
                }
            }
        }
    }
    static{
        cacheTriggerControl();
    }

    private Boolean objectDisabled(String xSObjType) {
        return disabledObjects.contains(xSObjType);
    }

    // Handlers are required to have objects defined
    // They will only ever be running in the context of a single object at a time even if used in multiple triggers
    // To disable the handler on 2 objects, would need to disable against both objects in the 2 individual handler records
    /*
    private Boolean handlerDisabled(HandlerInterface h) {
        return disabledHandlers.contains(getHandlerName(h));
    }
    */

    private Boolean objectHandlerDisabled(String xSObjectType, HandlerInterface h) {
        return disabledObjectHandlers.containsKey(xSObjectType) &&
            disabledObjectHandlers.get(xSObjectType).contains(getHandlerName(h));
    }

    private String sObjectType {
        get {
            if (sObjectType == null) {
                if (Trigger.isDelete) {
                    sObjectType = getSObjectType(Trigger.old[0]);
                } else {
                    sObjectType = getSObjectType(Trigger.new[0]);
                }
            }
            return sObjectType;
        }
        set;
    }

    private String getHandlerName(HandlerInterface h) {
        // thanks https://salesforce.stackexchange.com/a/24002/594
        return String.valueOf(h).split(':')[0].toLowerCase();
    }

    private String getSObjectType(SObject sObj) {
        return String.valueOf(sObj.getSObjectType()).toLowerCase();
    }
}