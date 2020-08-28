/**
 * Interface for when On_Exception=Custom Handler
 */
global interface CustomExceptionHandler {
    /**
     * runs when a handler throws an exception
     * @param e the uncaught exception
     * @param ctx the trigger context
     * @param handler the handler which threw
     * @param sp the save point created just before the handler ran
     */
    void handle(Exception e, TriggerContext ctx, HandlerConfig h, Savepoint sp);
}
