trigger AccountMaster on Account(
    after insert,
    after update,
    after delete,
    after undelete,
    before insert,
    before update,
    before delete
) {
    TriggerHandler handler = new TriggerHandler();
    // manually auto-bind Handler1, directly bind Handler2
    //handler.bind(TriggerHandler.Evt.beforeUpdate, new Handler1());
    handler.bind(TriggerHandler.Evt.beforeInsert, new Handler2());
    handler.manage();
}