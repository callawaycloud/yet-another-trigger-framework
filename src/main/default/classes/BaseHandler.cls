/**
 * Abstract base classes for triggers.
 * Simply decouples the class from the System `Trigger` context variable
 */
global abstract class BaseHandler implements Handler {
    // injected Trigger Context
    global TriggerContext context;
}
