/**
 * Abstract base classes for triggers.
 * Simply decouples the class from the System `Trigger` context variable
 */
global abstract class BaseTriggerHandler implements TriggerHandler.HandlerInterface {
    // injected Trigger Context
    global TriggerContext context = new TriggerContext();
}