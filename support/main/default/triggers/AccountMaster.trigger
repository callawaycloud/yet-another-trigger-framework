trigger AccountMaster on Account(
    after insert,
    after update,
    after delete,
    after undelete,
    before insert,
    before update,
    before delete
) {
    Manager handler = new Manager();
    // manually auto-bind Handler1, directly bind Handler2
    //handler.bind(TriggerHandler.Evt.beforeUpdate, new Handler1());
    handler.bind(Manager.Evt.beforeInsert, new Handler2());
    handler.manage();
}
