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

    @testVisible
    private TriggerContext context;

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
        System.debug(TriggerConfigService.configMetadata);
        triggerConfig = TriggerConfigService.configMetadata.get(sObjectType);
        context = new TriggerContext();
        System.debug(triggerConfig);
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
        system.debug(triggerConfig);
        if (triggerConfig != null && !triggerConfig.enabled)
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
        system.debug(eventHandlerMapping);
        List<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());

        if (handlers != null && !handlers.isEmpty()) {
            // prevent duplicate runs within an event
            Set<String> firedHandlers = new Set<String>{};
            for (HandlerInterface h : handlers) {
                if (!handlerDisabled(h)) {
                    if(h instanceOf BaseTriggerHandler){
                      ((BaseTriggerHandler) h).context = this.context;
                    }
                    String handlerName = getHandlerName(h);
                    if (firedHandlers.contains(handlerName)) {
                        System.debug('Duplicate binding for handler: ' + handlerName);
                        continue;
                    } else {
                        h.handle();
                        firedHandlers.add(handlerName);
                    }
                }
            }
        }
    }

    private void doAutomaticBinding() {
        if (triggerConfig == null || !triggerConfig.enabled) {
            return;
        }
        for (String handlerName : triggerConfig.handlerOrder) {
            TriggerConfigService.HandlerConfig handlerConfig = triggerConfig.handlers.get(handlerName);
            // do not bind if auto bind is off or if handler is disabled
            if (!handlerConfig.enabled) {
                continue;
            }
            Type t = getType(handlerConfig.className);
            if (t == null) {
                System.debug('Class does not exist: ' + handlerConfig.className);
                continue;
            }
            HandlerInterface handlerClass;
            try {
                handlerClass = (HandlerInterface) t.newInstance();
            } catch (TypeException te) {
                System.debug(
                    'Cannot bind invalid class ' +
                    handlerConfig.className +
                    '. Make sure your handler implements the HandlerInterface'
                );
                continue;
            }
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
        t = Type.forName(className); // doesn't throw exception if invalid name!
        return t;
    }

    private Boolean handlerDisabled(HandlerInterface h) {
        if (triggerConfig == null) {
            return false;
        }
        TriggerConfigService.HandlerConfig hc = triggerConfig.handlers.get((getHandlerName(h)));
        boolean disabled = hc != null && !hc.enabled;
        return disabled;
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
            return sObjectType.toLowerCase();
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
