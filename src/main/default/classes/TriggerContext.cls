// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
public class TriggerContext {
    public boolean isExecuting;
    public System.TriggerOperation operationType;
    public Integer size;
    public SObject[] newRecords;
    public Map<Id, SObject> newRecordMap;
    public SObject[] oldRecords;
    public Map<Id, SObject> oldRecordMap;
    public TriggerContext() {
        if (Trigger.isExecuting) {
            isExecuting = Trigger.isExecuting;
            operationType = Trigger.operationType;
            size = Trigger.size;
            newRecords = Trigger.new;
            newRecordMap = Trigger.newMap;
            oldRecords = Trigger.old;
            oldRecordMap = Trigger.oldMap;
        }
    }

    @testvisible
    private TriggerContext(System.TriggerOperation operationType, SObject[] newRecords, SObject[] oldRecords){
      System.assert(newRecords != null || oldRecords != null, 'Both newRecords & oldRecords cannot be null!');

      isExecuting = true;
      this.operationType = operationType;
      if(newRecords != null){
        this.newRecords = newRecords;
        this.newRecordMap = new Map<Id, SObject>(newRecords);
      }
      if(oldRecords != null){
        this.oldRecords = oldRecords;
        this.oldRecordMap = new Map<Id, SObject>(oldRecords);
      }
      size = newRecords != null ? newRecords.size() : oldRecords.size();
    }
}
