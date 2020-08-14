global class TriggerConfigService {
    global static Map<String, ObjectConfig> configMetadata {
        get {
            if (configMetadata == null) {
                configMetadata = buildConfigMap();
            }
            return configMetadata;
        }
        set;
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
                Trigger_Object__r.Enabled__c
            //Debug_Errors__c
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
            objectConfig.handlerOrder.add(handler.Handler_Class__c);
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
    }

    global class HandlerConfig {
        global String className;
        global Boolean enabled;
        global Decimal order;
        global Boolean beforeInsert;
        global Boolean afterInsert;
        global Boolean beforeUpdate;
        global Boolean afterUpdate;
        global Boolean beforeDelete;
        global Boolean afterDelete;
        global Boolean afterUndelete;
        global Boolean debugErrors;

        global HandlerConfig() {
        }

        global HandlerConfig(Trigger_Handler__mdt th) {
            className = th.Handler_Class__c.toLowerCase();
            enabled = th.Enabled__c;
            order = th.Execution_Order__c;
            beforeInsert = th.Before_Insert__c;
            afterInsert = th.After_Insert__c;
            beforeUpdate = th.Before_Update__c;
            afterUpdate = th.After_Update__c;
            beforeDelete = th.Before_Delete__c;
            afterDelete = th.After_Delete__c;
            afterUndelete = th.After_Undelete__c;
            debugErrors = false; // for now, always false until we test and implement
        }
    }
}