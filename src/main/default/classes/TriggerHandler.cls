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
    Map<System.TriggerOperation, List<HandlerInterface>> eventHandlerMapping = new Map<System.TriggerOperation, List<HandlerInterface>>();

    public TriggerHandler() {
        System.debug(TriggerConfigService.configMetadata);
        context = new TriggerContext();
        triggerConfig = TriggerConfigService.configMetadata.get(sObjectType);
        System.debug(context);
        System.debug(triggerConfig);
        doAutomaticBinding();
    }

    /**
     *   Core API to bind handlers with events
     *   @depreciated use bind(System.TriggerOperation event, HandlerInterface eh)
     */
    public TriggerHandler bind(Evt event, HandlerInterface eh) {
        System.TriggerOperation mappedEvent;
        switch on event{
          when beforeInsert {
            mappedEvent = System.TriggerOperation.BEFORE_INSERT;
          }
          when afterInsert {
            mappedEvent = System.TriggerOperation.AFTER_INSERT;
          }
          when beforeUpdate {
            mappedEvent = System.TriggerOperation.BEFORE_UPDATE;
          }
          when afterUpdate {
            mappedEvent = System.TriggerOperation.AFTER_UPDATE;
          }
          when beforeDelete {
            mappedEvent = System.TriggerOperation.BEFORE_DELETE;
          }
          when afterDelete {
            mappedEvent = System.TriggerOperation.AFTER_DELETE;
          }
          when afterUndelete {
            mappedEvent = System.TriggerOperation.AFTER_UNDELETE;
          }
        }
        return bind(mappedEvent, eh);
    }

    public TriggerHandler bind(System.TriggerOperation event, HandlerInterface eh) {
        List<HandlerInterface> handlers = eventHandlerMapping.get(event);
        if (handlers == null) {
            handlers = new List<HandlerInterface>();
            eventHandlerMapping.put(event, handlers);
        }
        handlers.add(eh);
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of Trigger and available registered handlers
     */
    public void manage() {
        system.debug(triggerConfig);
        if (triggerConfig != null && !triggerConfig.enabled){
            return;
        }

        system.debug(eventHandlerMapping);
        List<HandlerInterface> handlers = eventHandlerMapping.get(context.operationType);

        if (handlers != null && !handlers.isEmpty()) {
            // prevent duplicate runs within an event
            Set<String> firedHandlers = new Set<String>{};
            for (HandlerInterface h : handlers) {
                if (!handlerDisabled(h)) {

                    // potentially move this to binding
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
                if (this.context.isDelete) {
                    sObjectType = getSObjectType(this.context.oldRecords[0]);
                } else {
                    sObjectType = getSObjectType(this.context.newRecords[0]);
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
