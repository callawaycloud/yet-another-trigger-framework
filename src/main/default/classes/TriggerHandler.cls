// Based on https://github.com/joeferraro/MavensMate-Templates/blob/master/ApexClass/TriggerHandler.cls
public class TriggerHandler {
    /**
     *   Enum representing each of before/after CRUD events on Sobjects
     */
    public enum Evt {
        afterDelete,
        afterInsert,
        afterUndelete,
        afterUpdate,
        beforeDelete,
        beforeInsert,
        beforeUpdate
    }

    /*
     *   Simplistic handler to implement on any of the event. It doesn't require or enforces any pattern except the
     *   method name to be "handle()".
     */
    public interface HandlerInterface {
        void handle();
    }

    // Internal mapping of handlers
    Map<String, List<HandlerInterface>> eventHandlerMapping = new Map<String, List<HandlerInterface>>();

    /**
     *   Core API to bind handlers with events
     */
    public TriggerHandler bind(Evt event, HandlerInterface eh) {
        List<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) {
            handlers = new List<HandlerInterface>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of Trigger and available registered handlers
     */
    public void manage() {
        Evt ev = null;
        if (Trigger.isInsert && Trigger.isBefore) {
            ev = Evt.beforeInsert;
        } else if (Trigger.isInsert && Trigger.isAfter) {
            ev = Evt.afterInsert;
        } else if (Trigger.isUpdate && Trigger.isBefore) {
            ev = Evt.beforeUpdate;
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            ev = Evt.afterUpdate;
        } else if (Trigger.isDelete && Trigger.isBefore) {
            ev = Evt.beforeDelete;
        } else if (Trigger.isDelete && Trigger.isAfter) {
            ev = Evt.afterDelete;
        } else if (Trigger.isUndelete) {
            ev = Evt.afterUndelete;
        }

        List<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());

        if (handlers != null && !handlers.isEmpty()) {
            for (HandlerInterface h : handlers) {
                h.handle();
            }
        }
    }
}