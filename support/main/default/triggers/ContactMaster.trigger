trigger ContactMaster on Contact(
    after insert,
    after update,
    after delete,
    after undelete,
    before insert,
    before update,
    before delete
) {
    Manager handler = new Manager();
    //handler.bind(TriggerHandler.Evt.beforeInsert, new Handler1());
    handler.manage();
}
