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

    public TriggerConfigService.ObjectConfig objectConfig {
        get {
            if(objectConfig == null){
                objectConfig = TriggerConfigService.getConfig(sObjectType);
            }
            return objectConfig;
        }
        set;
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
                if (!objectHandlerDisabled(sObjectType, h)) {
                    h.handle();
                }
            }
        }
    }

    private void doAutomaticBinding(String sObjName){
        for(Trigger_Object__mdt triggerObj : configMetadata){
            if(sObjName == triggerObj.Object__c){
                for(Trigger_Handler__mdt handler : triggerObj.Trigger_Handlers__r){
                    if(!handler.Auto_Bind__c){
                        continue;
                    }
                    Type t = getType(handler.Handler_Class__c);
                    if(t == null){
                        System.debug(handler.Handler_Class__c + '? Looks like that handler class does not exist!');
                        continue;
                    }
                    HandlerInterface handlerClass = (HandlerInterface) t.newInstance();
                    if(handler.Before_Insert__c){
                        bind(Evt.beforeInsert, handlerClass);
                    }
                    if(handler.After_Insert__c){
                        bind(Evt.afterInsert, handlerClass);
                    }
                    if(handler.Before_Update__c){
                        bind(Evt.beforeUpdate, handlerClass);
                    }
                    if(handler.After_Update__c){
                        bind(Evt.afterUpdate, handlerClass);
                    }
                    if(handler.Before_Delete__c){
                        bind(Evt.beforeDelete, handlerClass);
                    }
                    if(handler.After_Delete__c){
                        bind(Evt.afterDelete, handlerClass);
                    }
                    if(handler.After_Undelete__c){
                        bind(Evt.afterUndelete, handlerClass);
                    }
                }
            }
        }
    }

    private Type getType(String className){
        Type t;
        try{
            t = Type.forName(className); // doesn't throw exception if invalid name!
        } catch (Exception e){
            // friendly non-exploding notificaiton?
            System.debug(e.getMessage());
        }
        return t;
    }

    private Boolean objectDisabled(String xSObjType) {
        return disabledObjects.contains(xSObjType);
    }

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