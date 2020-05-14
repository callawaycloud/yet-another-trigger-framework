public class TriggerConfigService {
    public static Map<String, ObjectConfig> configMetadata {
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
        Trigger_Object__mdt[] allMtd = [
            SELECT
                DeveloperName,
                Enabled__c,
                (
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
                        After_Update__c
                    FROM Trigger_Handlers__r
                    ORDER BY Execution_Order__c ASC
                )
            FROM Trigger_Object__mdt
        ];
        Map<String, ObjectConfig> resultsMap = new Map<String, ObjectConfig>();
        for (Trigger_Object__mdt objMdt : allMtd) {
            resultsMap.put(objMdt.DeveloperName.toLowerCase(), new ObjectConfig(objMdt));
        }
        if (allMtd.size() == 0) {
        }
        return resultsMap;
    }

    public class ObjectConfig {
        public String objName;
        public Boolean enabled;
        public Map<String, HandlerConfig> handlers = new Map<String, HandlerConfig>{};
        public String[] handlerOrder = new List<String>{};

        public ObjectConfig() {
        }

        public ObjectConfig(Trigger_Object__mdt objMdt) {
            objName = objMdt.DeveloperName.toLowerCase();
            enabled = objMdt.Enabled__c;
            handlers = new Map<String, HandlerConfig>{};
            handlerOrder = new List<String>{};

            for (Trigger_Handler__mdt th : objMdt.Trigger_Handlers__r) {
                String handlerName = th.Handler_Class__c.toLowerCase();
                handlers.put(handlerName, new HandlerConfig(th));
                handlerOrder.add(handlerName);
            }
        }
    }

    public class HandlerConfig {
        public String className;
        public Boolean enabled;
        public Decimal order;
        public Boolean beforeInsert;
        public Boolean afterInsert;
        public Boolean beforeUpdate;
        public Boolean afterUpdate;
        public Boolean beforeDelete;
        public Boolean afterDelete;
        public Boolean afterUndelete;

        public HandlerConfig() {
        }

        public HandlerConfig(Trigger_Handler__mdt th) {
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
        }
    }
}