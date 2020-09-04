/*
 *  The master orchestrator
 *    Based on https://github.com/joeferraro/MavensMate-Templates/blob/master/ApexClass/TriggerHandler.cls
 */
global class Manager {
    @testVisible
    private TriggerConfigService.ObjectConfig triggerConfig;

    @testVisible
    private TriggerContext context;

    // Internal mapping of handlers
    @testVisible
    private Map<System.TriggerOperation, List<HandlerConfig>> eventHandlerMapping = new Map<System.TriggerOperation, List<HandlerConfig>>();
    //used to prevent double bindings
    @testVisible
    private Map<System.TriggerOperation, Set<String>> eventHandlerNamesMap = new Map<System.TriggerOperation, Set<String>>();

    private static ExceptionManager exceptionManager = new ExceptionManager();

    /** Constructor */
    global Manager() {
        this(new TriggerContext());
    }

    /** Test Constructor */
    @testVisible
    private Manager(TriggerContext context) {
        this.context = context;
        triggerConfig = TriggerConfigService.getObjectConfig(context.SObjectType);
        bindDynamicConfiguration();
    }

    /**
     * Method for static binding of `TriggerHandler` to event.
     * @param event Trigger event to bind to
     * @param eh Event Handler
     * @return instance of `this` for chaining
     */
    global Manager bind(System.TriggerOperation event, Handler eh) {
        return bind(event, eh, false);
    }

    private Manager bind(System.TriggerOperation event, Handler eh, Boolean limitBinding) {
        HandlerConfig hc = triggerConfig.getHandlerConfig(Utils.getClassName(eh));
        hc.handler = eh;

        Set<String> handlerNames = eventHandlerNamesMap.get(event);
        if (handlerNames == null) {
            handlerNames = new Set<String>();
            eventHandlerNamesMap.put(event, handlerNames);
        }

        List<HandlerConfig> handlers = eventHandlerMapping.get(event);
        if (handlers == null) {
            handlers = new List<HandlerConfig>();
            eventHandlerMapping.put(event, handlers);
        }

        Boolean disabled = !hc.enabled;

        if (disabled) {
            System.debug('Handler is disabled: ' + hc.className);
        } else if (limitBinding && handlerNames.contains(hc.className)) {
            System.debug('Already bound handler: ' + hc.className);
        } else {
            handlerNames.add(hc.className);
            handlers.add(hc);
        }
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of Trigger and available registered handlers
     */
    global void manage() {
        if (!triggerConfig.enabled) {
            return;
        }

        List<HandlerConfig> handlers = eventHandlerMapping.get(context.operationType);

        if (handlers != null && !handlers.isEmpty()) {
            for (HandlerConfig config : handlers) {
                System.debug('Running handler: ' + config.className);
                if (config.handler instanceof BaseHandler) {
                    ((BaseHandler) config.handler).context = this.context;
                }
                Savepoint sp = config.onException == HandlerConfig.ExceptionStrategy.USE_SAVEPOINT
                    ? Database.setSavePoint()
                    : null;

                try {
                    config.handler.handle();
                } catch (Exception e) {
                    exceptionManager.manage(e, context, config, sp);
                }
            }
        }
    }

    /**
     * Handles binding of configuration based handles
     */
    private void bindDynamicConfiguration() {
        if (!triggerConfig.enabled) {
            return;
        }
        for (String handlerName : triggerConfig.handlerOrder) {
            System.debug('Auto binding: ' + handlerName);
            HandlerConfig handlerConfig = triggerConfig.handlers.get(handlerName);
            // do not bind if auto bind is off or if handler is disabled
            if (!handlerConfig.enabled) {
                continue;
            }
            Handler handlerClass = constructHandler(handlerConfig);
            if (handlerClass == null) {
                continue;
            }

            //consider refactoring to Set of TriggerOperation
            // DO we even need to bind all these events?
            //  Seems like we just need to bind for the current trigger context???
            if (handlerConfig.beforeInsert) {
                bind(TriggerOperation.BEFORE_INSERT, handlerClass, true);
            }
            if (handlerConfig.afterInsert) {
                bind(TriggerOperation.AFTER_INSERT, handlerClass, true);
            }
            if (handlerConfig.beforeUpdate) {
                bind(TriggerOperation.BEFORE_UPDATE, handlerClass, true);
            }
            if (handlerConfig.afterUpdate) {
                bind(TriggerOperation.AFTER_UPDATE, handlerClass, true);
            }
            if (handlerConfig.beforeDelete) {
                bind(TriggerOperation.BEFORE_DELETE, handlerClass, true);
            }
            if (handlerConfig.afterDelete) {
                bind(TriggerOperation.AFTER_DELETE, handlerClass, true);
            }
            if (handlerConfig.afterUndelete) {
                bind(TriggerOperation.AFTER_UNDELETE, handlerClass, true);
            }
        }
    }

    private Handler constructHandler(HandlerConfig handlerConfig) {
        try {
            return (Handler) Utils.constructFromName(handlerConfig.className);
        } catch (Exception te) {
            System.debug(
                'Cannot bind invalid class ' +
                handlerConfig.className +
                '. Make sure your handler exists and implements the Handler Interface'
            );
        }
        return null;
    }

    private class HandlerWrapper {
        public Handler handler;
        public String name;
        public HandlerConfig config;
        public HandlerWrapper(Handler handler) {
            this.handler = handler;
            this.name = Utils.getClassName(handler);
        }
    }

    /**
     *   Enum representing each of before/after CRUD events on Sobjects
     *   @depreciated  Use System `TriggerOperation`
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

    private static final Map<Evt, TriggerOperation> LEGACY_EVT_MAPPING = new Map<Evt, TriggerOperation>{
        Evt.beforeInsert => TriggerOperation.BEFORE_INSERT,
        Evt.afterInsert => TriggerOperation.AFTER_INSERT,
        Evt.beforeUpdate => TriggerOperation.BEFORE_UPDATE,
        Evt.afterUpdate => TriggerOperation.AFTER_UPDATE,
        Evt.beforeDelete => TriggerOperation.BEFORE_DELETE,
        Evt.afterDelete => TriggerOperation.AFTER_DELETE,
        Evt.afterUndelete => TriggerOperation.AFTER_UNDELETE
    };
    /**
     *   Core API to bind handlers with events
     *   @depreciated use `bind(TriggerOperation event, Handler eh)`
     */
    global Manager bind(Evt event, Handler eh) {
        TriggerOperation mappedEvent = LEGACY_EVT_MAPPING.get(event);
        return bind(mappedEvent, eh);
    }
}
