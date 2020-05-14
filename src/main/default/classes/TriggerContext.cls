// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
public class TriggerContext {
  public boolean isExecuting;
  public System.TriggerOperation operationType;
  public Integer size;
  public SObject[] newRecords;
  public Map<Id, SObject> newRecordMap;
  public SObject[] oldRecords;
  public Map<Id, SObject> oldRecordMap;

  public Boolean isInsert = false;
  public Boolean isUpdate = false;
  public Boolean isDelete = false;
  public Boolean isBefore = false;
  public Boolean isAfter = false;
  public Boolean isUndelete = false;

  public TriggerContext() {
      if (Trigger.isExecuting) {
          isExecuting = Trigger.isExecuting;
          operationType = Trigger.operationType;
          size = Trigger.size;
          newRecords = Trigger.new;
          newRecordMap = Trigger.newMap;
          oldRecords = Trigger.old;
          oldRecordMap = Trigger.oldMap;
          isInsert = Trigger.isInsert;
          isUpdate = Trigger.isUpdate;
          isDelete = Trigger.isDelete;
          isBefore = Trigger.isBefore;
          isAfter = Trigger.isAfter;
          isUndelete = Trigger.isUndelete;
      }
  }

  @testvisible
  private TriggerContext(System.TriggerOperation operationType, SObject[] newRecords, SObject[] oldRecords){
    System.assert(newRecords != null || oldRecords != null, 'Both newRecords & oldRecords cannot be null!');

    isExecuting = true;
    this.operationType = operationType;
    this.newRecords = newRecords;

    //not sure if this works for upsert?
    if(newRecords != null && newRecords.size() > 0 && newRecords[0].Id != null){
      this.newRecordMap = new Map<Id, SObject>(newRecords);
    }

    this.oldRecords = oldRecords;
    if(oldRecords != null){
      this.oldRecordMap = new Map<Id, SObject>(oldRecords);
    }
    size = newRecords != null ? newRecords.size() : oldRecords.size();

    switch on operationType{
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
