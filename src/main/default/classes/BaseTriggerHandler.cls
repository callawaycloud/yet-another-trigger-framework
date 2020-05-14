/**
 * Abstract base classes for triggers.
 * Simply decouples the class from the System `Trigger` context variable
 */
public abstract class BaseTriggerHandler implements TriggerHandler.HandlerInterface {
    // injected Trigger Context
    public TriggerContext context;
}
