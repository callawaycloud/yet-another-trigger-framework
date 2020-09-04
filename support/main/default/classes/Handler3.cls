public without sharing class Handler3 extends BaseHandler {
    public static Set<String> events;
    public void handle() {
        if (events == null) {
            events = new Set<String>();
        }
        // does not touch the triggering sObject so every event can be bound
        String event = '';
        event += context.isBefore ? 'before' : 'after';
        if (context.isInsert) {
            event += 'Insert';
        }
        if (context.isUpdate) {
            event += 'Update';
        }
        if (context.isDelete) {
            event += 'Delete';
        }
        if (context.isUndelete) {
            event += 'Undelete';
        }
        events.add(event);
        System.debug('Handler 3 - ' + event);
    }
}
