// Based on https://github.com/joeferraro/MavensMate-Templates/blob/master/ApexClass/TriggerHandler.cls
global class Manager {
    @testVisible
    private TriggerConfigService.ObjectConfig triggerConfig;

    @testVisible
    private TriggerContext context;

    // Internal mapping of handlers
    @testVisible
    private Map<System.TriggerOperation, List<Handler>> eventHandlerMapping = new Map<System.TriggerOperation, List<Handler>>();
    @testVisible
    private Map<System.TriggerOperation, Set<String>> eventHandlerNamesMap = new Map<System.TriggerOperation, Set<String>>();

    global Manager() {
        this(new TriggerContext());
    }

    @testVisible
    private Manager(TriggerContext context) {
        this.context = context;
        triggerConfig = TriggerConfigService.configMetadata.get(sObjectType);
        doAutomaticBinding();
    }

    global Manager bind(System.TriggerOperation event, Handler eh) {
        List<Handler> handlers = eventHandlerMapping.get(event);
        Set<String> handlerNames = eventHandlerNamesMap.get(event);
        String hName = getHandlerName(eh);

        if (handlerNames == null) {
            handlerNames = new Set<String>();
            eventHandlerNamesMap.put(event, handlerNames);
        }
        if (handlers == null) {
            handlers = new List<Handler>();
            eventHandlerMapping.put(event, handlers);
        }

        if (handlerDisabled(eh)) {
            System.debug('Handler is disabled: ' + hName);
        } else if (handlerNames.contains(hName)) {
            System.debug('Already bound handler: ' + hName);
        } else {
            handlerNames.add(hName);
            handlers.add(eh);
        }
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of Trigger and available registered handlers
     */
    global void manage() {
        if (triggerConfig != null && !triggerConfig.enabled) {
            return;
        }

        List<Handler> handlers = eventHandlerMapping.get(context.operationType);

        if (handlers != null && !handlers.isEmpty()) {
            for (Handler h : handlers) {
                System.debug('Running handler: ' + getHandlerName(h));
                if (h instanceof BaseHandler) {
                    ((BaseHandler) h).context = this.context;
                }
                if (isDebugOnly(h)) {
                    try {
                        h.handle();
                    } catch (Exception e) {
                        System.debug(JSON.serializePretty(e));
                    }
                } else {
                    h.handle();
                }
            }
        }
    }

    private void doAutomaticBinding() {
        if (triggerConfig == null || !triggerConfig.enabled) {
            return;
        }
        for (String handlerName : triggerConfig.handlerOrder) {
            System.debug('Auto binding: ' + handlerName);
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
            Handler handlerClass;
            try {
                handlerClass = (Handler) t.newInstance();
            } catch (TypeException te) {
                System.debug(
                    'Cannot bind invalid class ' +
                    handlerConfig.className +
                    '. Make sure your handler implements the Handler'
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

    private Boolean handlerDisabled(Handler h) {
        if (triggerConfig == null) {
            return false;
        }
        TriggerConfigService.HandlerConfig hc = triggerConfig.handlers.get((getHandlerName(h)));
        boolean disabled = hc != null && !hc.enabled;
        return disabled;
    }

    private Boolean isDebugOnly(Handler h) {
        if (triggerConfig == null) {
            return false;
        }
        TriggerConfigService.HandlerConfig hc = triggerConfig.handlers.get((getHandlerName(h)));
        system.debug(JSON.serializePretty(hc));
        boolean debugErrors = hc != null && hc.debugErrors;
        return debugErrors;
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

    private String getHandlerName(Handler h) {
        // thanks https://salesforce.stackexchange.com/a/24002/594
        return String.valueOf(h).split(':')[0].toLowerCase();
    }

    private String getSObjectType(SObject sObj) {
        return String.valueOf(sObj.getSObjectType()).toLowerCase();
    }

    /**
     *   Enum representing each of before/after CRUD events on Sobjects
     *   @depreciated  Use System.TriggerOperation
     */
    global enum Evt {
        afterDelete,
        afterInsert,
        afterUndelete,
        afterUpdate,
        beforeDelete,
        beforeInsert,
        beforeUpdate
    }

    /**
     *   Core API to bind handlers with events
     *   @depreciated use bind(System.TriggerOperation event, Handler eh)
     */
    global Manager bind(Evt event, Handler eh) {
        System.TriggerOperation mappedEvent;
        switch on event {
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
}