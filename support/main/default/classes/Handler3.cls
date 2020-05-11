public without sharing class Handler3 implements TriggerHandler.HandlerInterface {
    public static Set<String> events;
    public void handle() {
      if(events == null){
        events = new Set<String>();
      }
      // does not touch the triggering sObject so every event can be bound
      String event = '';
      event += Trigger.isBefore ? 'before' : 'after';
      if(Trigger.isInsert){
          event += 'Insert';
      }
      if(Trigger.isUpdate){
        event += 'Update';
      }
      if(Trigger.isDelete){
        event += 'Delete';
      }
      if(Trigger.isUndelete){
        event += 'Undelete';
      }
      events.add(event);
      System.debug('Handler 3 - ' + event);
    }
  }