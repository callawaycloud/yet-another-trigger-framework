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

    private static Set<String> disabledObjects = new Set<String>();
    private static Set<String> disabledHandlers = new Set<String>();
    private static Map<String, Set<String>> disabledObjectHandlers = new Map<String, Set<String>>();
    @TestVisible
    private static void cacheTriggerControl(Trigger_Control__mdt[] triggerControls) {
        disabledObjects.clear();
        disabledHandlers.clear();
        disabledObjectHandlers.clear();
        for (Trigger_Control__mdt triggerControl : triggerControls) {
            String objectName = triggerControl.Object__c == null ? null : triggerControl.Object__c.toLowerCase();
            String handlerName = triggerControl.Class__c == null ? null : triggerControl.Class__c.toLowerCase();
            if (handlerName == null && objectName != null) {
                disabledObjects.add(objectName);
            } else if (handlerName != null && objectName == null) {
                disabledHandlers.add(handlerName);
            } else if (handlerName != null && objectName != null) {
                if (!disabledObjectHandlers.containsKey(objectName)) {
                    disabledObjectHandlers.put(objectName, new Set<String>());
                }
                disabledObjectHandlers.get(objectName).add(handlerName);
            }
        }
    }
    static {
        cacheTriggerControl([SELECT Class__c, Object__c FROM Trigger_Control__mdt]);
    }

    private Boolean objectDisabled(String xSObjType) {
        return disabledObjects.contains(xSObjType);
    }

    private Boolean handlerDisabled(HandlerInterface h) {
        return disabledHandlers.contains(getHandlerName(h));
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