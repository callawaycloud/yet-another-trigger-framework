// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
global class TriggerContext {
    global boolean isExecuting;
    global System.TriggerOperation operationType;
    global Integer size;
    global SObject[] newRecords;
    global Map<Id, SObject> newRecordMap;
    global SObject[] oldRecords;
    global Map<Id, SObject> oldRecordMap;

    global Boolean isInsert = false;
    global Boolean isUpdate = false;
    global Boolean isDelete = false;
    global Boolean isBefore = false;
    global Boolean isAfter = false;
    global Boolean isUndelete = false;

    @TestVisible
    private static boolean triggerCoverage = false;

    global TriggerContext() {
        if (Trigger.isExecuting || triggerCoverage) {
            isExecuting = !triggerCoverage ? Trigger.isExecuting : false;
            operationType = !triggerCoverage ? Trigger.operationType : null;
            size = !triggerCoverage ? Trigger.size : 0;
            newRecords = !triggerCoverage ? Trigger.new : null;
            newRecordMap = !triggerCoverage ? Trigger.newMap : null;
            oldRecords = !triggerCoverage ? Trigger.old : null;
            oldRecordMap = !triggerCoverage ? Trigger.oldMap : null;
            isInsert = !triggerCoverage ? Trigger.isInsert : false;
            isUpdate = !triggerCoverage ? Trigger.isUpdate : false;
            isDelete = !triggerCoverage ? Trigger.isDelete : false;
            isBefore = !triggerCoverage ? Trigger.isBefore : false;
            isAfter = !triggerCoverage ? Trigger.isAfter : false;
            isUndelete = !triggerCoverage ? Trigger.isUndelete : false;
        }
    }

    @testvisible
    private TriggerContext(System.TriggerOperation operationType, SObject[] newRecords, SObject[] oldRecords) {
        System.assert(newRecords != null || oldRecords != null, 'Both newRecords & oldRecords cannot be null!');

        isExecuting = true;
        this.operationType = operationType;
        this.newRecords = newRecords;

        //not sure if this works for upsert?
        if (newRecords != null && newRecords.size() > 0 && newRecords[0].Id != null) {
            this.newRecordMap = new Map<Id, SObject>(newRecords);
        }

        this.oldRecords = oldRecords;
        if (oldRecords != null && oldRecords.size() > 0 && oldRecords[0].Id != null) {
            this.oldRecordMap = new Map<Id, SObject>(oldRecords);
        }
        size = newRecords != null ? newRecords.size() : oldRecords.size();

        switch on operationType {
            when BEFORE_INSERT {
                isBefore = true;
                isInsert = true;
            }
            when AFTER_INSERT {
                isAfter = true;
                isInsert = true;
            }
            when BEFORE_UPDATE {
                isBefore = true;
                isUpdate = true;
            }
            when AFTER_UPDATE {
                isAfter = true;
                isUpdate = true;
            }
            when BEFORE_DELETE {
                isBefore = true;
                isDelete = true;
            }
            when AFTER_DELETE {
                isAfter = true;
                isDelete = true;
            }
            when AFTER_UNDELETE {
                isAfter = true;
                isUndelete = true;
            }
        }
    }
}