global class TriggerConfigService {
    @TestVisible
    private static Map<String, ObjectConfig> configMetadata;

    /**
     * Given the name of an SObject, returns the Config.  If one doesn't exist, returns a default config
     */
    public static ObjectConfig getObjectConfig(String sObjectName) {
        if (configMetadata == null) {
            configMetadata = buildConfigMap();
        }

        if (configMetadata.containsKey(sObjectName)) {
            return configMetadata.get(sObjectName);
        }
        return new ObjectConfig(true, sObjectName);
    }

    @testVisible
    private static Map<String, ObjectConfig> buildConfigMap() {
        Trigger_Handler__mdt[] allMtd = [
            SELECT
                Handler_Class__c,
                Enabled__c,
                Execution_Order__c,
                Before_Insert__c,
                After_Insert__c,
                Before_Delete__c,
                After_Delete__c,
                After_Undelete__c,
                Before_Update__c,
                After_Update__c,
                Trigger_Object__r.Object_API_Name__c,
                Trigger_Object__r.Enabled__c,
                On_Exception__c,
                Create_Exception_Event__c,
                On_Exception_Event_Handler__c
            FROM Trigger_Handler__mdt
            ORDER BY Execution_Order__c ASC
        ];
        Map<String, ObjectConfig> resultsMap = new Map<String, ObjectConfig>();
        for (Trigger_Handler__mdt handler : allMtd) {
            ObjectConfig objectConfig;
            HandlerConfig handlerConfig = new HandlerConfig(handler);
            String objName = handler.Trigger_Object__r.Object_API_Name__c.toLowerCase();
            if (!resultsMap.containsKey(objName)) {
                objectConfig = new objectConfig(handler.Trigger_Object__r.Enabled__c, objName);
            } else {
                objectConfig = resultsMap.get(objName);
            }
            objectConfig.handlers.put(handler.Handler_Class__c.toLowerCase(), handlerConfig);
            objectConfig.handlerOrder.add(handler.Handler_Class__c.toLowerCase());
            resultsMap.put(objName, objectConfig);
        }
        if (allMtd.size() == 0) {
        }
        return resultsMap;
    }

    global class ObjectConfig {
        global String objName;
        global Boolean enabled;
        global Map<String, HandlerConfig> handlers = new Map<String, HandlerConfig>{};
        global String[] handlerOrder = new List<String>{};

        global ObjectConfig() {
        }

        global ObjectConfig(Boolean enabled, String objName) {
            this.objName = objName;
            this.enabled = enabled;
            handlers = new Map<String, HandlerConfig>{};
            handlerOrder = new List<String>{};
        }

        global HandlerConfig getHandlerConfig(String className) {
            if (handlers.containsKey(className)) {
                return handlers.get(className);
            }

            HandlerConfig defaultConfig = new HandlerConfig(className);

            return defaultConfig;
        }
    }
}
