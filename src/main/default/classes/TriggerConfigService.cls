public class TriggerConfigService {

    public static ObjectConfig getConfig(String objName){
        String lowercaseObjName = objName.toLowerCase();
        if(!configMetadata.keySet().contains(lowercaseObjName)){
            return null;
        }

        return new ObjectConfig(configMetadata.get(lowercaseObjName));
    }

    @testVisible
    private static Map<String,ObjectConfig> configMetadata {
        get {
            if(configMetadata == null){
                configMetadata = buildConfigMap();
            }
            return configMetadata;
        }
        set;
    }

    private static Map<String,ObjectConfig> buildConfigMap(){
        Trigger_Object__mdt[] allMtd =
        [SELECT Object__c,
            Enabled__c,
            (
            select
                Handler_Class__c,
                Auto_Bind__c,
                Enabled__c,
                Execution_Order__c,
                Before_Insert__c,
                After_Insert__c,
                Before_Delete__c,
                After_Delete__c,
                After_Undelete__c,
                Before_Update__c,
                After_Update__c
            from
                Trigger_Handlers__r
            order by
                Execution_Order__c
            )
        FROM
            Trigger_Object__mdt
        ];
        Map<String,ObjectConfig> resultsMap = new Map<String,ObjectConfig>();
        for(Trigger_Object__mdt objMdt : allMtd){
            resultsMap.put(objMdt.Object__c, new ObjectConfig(objMdt));
        }
        return resultsMap;
    }

    public static Set<String> disabledObjects = new Set<String>();
    public static Map<String, Set<String>> disabledObjectHandlers = new Map<String, Set<String>>();

    @TestVisible
    private static void cacheDesabledTypes() {
        disabledObjects.clear();
        disabledObjectHandlers.clear();
        for (Trigger_Object__mdt triggerObject : configMetadata.values()) {
            String objectName = triggerObject.Object__c == null ? null : triggerObject.Object__c.toLowerCase();
            if(!triggerObject.Enabled__c){
                disabledObjects.add(objectName);
            }
            for(Trigger_Handler__mdt handler : triggerObject.Trigger_Handlers__r){
                String handlerName = handler.Handler_Class__c == null ? null : handler.Handler_Class__c.toLowerCase();
                if(!handler.Enabled__c){
                    if (!disabledObjectHandlers.containsKey(objectName)) {
                        disabledObjectHandlers.put(objectName, new Set<String>());
                    }
                    disabledObjectHandlers.get(objectName).add(handlerName);
                }
            }
        }
    }
    static{
        cacheDesabledTypes();
    }

    public class ObjectConfig{
        String objName;
        Boolean enabled;
        HandlerConfig[] handlers;

        public ObjectConfig(){}

        public ObjectConfig(Trigger_Object__mdt objMdt){
            objName = objMdt.Object__c.toLowerCase();
            enabled = objMdt.Enabled__c;
            handlers = new HandlerConfig[]{};

            for(Trigger_Handler__mdt th: objMdt.Trigger_Handlers__r){
                handlers.add(new HandlerConfig(th));
            }
        }
    }

    public class HandlerConfig{
        public String className;
        public Boolean autoBind;
        public Boolean enabled;
        public Decimal order;
        public Boolean beforeInsert;
        public Boolean afterInsert;
        public Boolean beforeUpdate;
        public Boolean afterUpdate;
        public Boolean beforeDelete;
        public Boolean afterDelete;
        public Boolean afterUndelete;

        public HandlerConfig(){}

        public HandlerConfig(Trigger_Handler__mdt th){
            className = th.Handler_Class__c.toLowerCase();
            autoBind = th.Auto_Bind__c;
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
