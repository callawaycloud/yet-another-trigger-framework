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

    @testVisible
    private TriggerConfigService.ObjectConfig triggerConfig;

    /*
     *   Simplistic handler to implement on any of the event. It doesn't require or enforces any pattern except the
     *   method name to be "handle()".
     */
    public interface HandlerInterface {
        void handle();
    }

    // Internal mapping of handlers
    Map<String, List<HandlerInterface>> eventHandlerMapping = new Map<String, List<HandlerInterface>>();

    public TriggerHandler() {
        triggerConfig = TriggerConfigService.getConfig(sObjectType);
        doAutomaticBinding();
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
        if (!triggerConfig.enabled)
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
                if (!handlerDisabled(h)) {
                    h.handle();
                }
            }
        }
    }

    private void doAutomaticBinding() {
        if (!triggerConfig.enabled) {
            return;
        }
        for (String handlerName : triggerConfig.handlerOrder) {
            TriggerConfigService.HandlerConfig handlerConfig = triggerConfig.handlers.get(handlerName);
            // do not bind if auto bind is off or if handler is disabled
            if (!handlerConfig.autoBind || !handlerConfig.enabled) {
                continue;
            }
            Type t = getType(handlerConfig.className);
            if (t == null) {
                System.debug(handlerConfig.className + '? Looks like that handler class does not exist!');
                continue;
            }
            HandlerInterface handlerClass = (HandlerInterface) t.newInstance();
            if (handlerConfig.beforeInsert) {
                bind(Evt.beforeInsert, handlerClass);
            }
            if (handlerConfig.afterInsert) {
                bind(Evt.afterInsert, handlerClass);
            }
            if (handlerConfig.beforeUpdate) {
                bind(Evt.beforeUpdate, handlerClass);
            }
            if (handlerConfig.afterUpdate) {
                bind(Evt.afterUpdate, handlerClass);
            }
            if (handlerConfig.beforeDelete) {
                bind(Evt.beforeDelete, handlerClass);
            }
            if (handlerConfig.afterDelete) {
                bind(Evt.afterDelete, handlerClass);
            }
            if (handlerConfig.afterUndelete) {
                bind(Evt.afterUndelete, handlerClass);
            }
        }
    }

    private Type getType(String className) {
        Type t;
        try {
            t = Type.forName(className); // doesn't throw exception if invalid name!
        } catch (Exception e) {
            // not sure we need a try/catch
            System.debug(e.getMessage());
        }
        return t;
    }

    private Boolean handlerDisabled(HandlerInterface h) {
        return triggerConfig.disabledHandlers.contains(getHandlerName(h));
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