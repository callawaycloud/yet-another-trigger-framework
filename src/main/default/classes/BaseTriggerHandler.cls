/**
 * Abstract base classes for triggers.SELECT
 * Simply decouples the class from the System `Trigger` context variable
 */
public abstract class BaseTriggerHandler implements TriggerHandler.HandlerInterface {
  // decoupled Trigger Context
  public TriggerContext context;
}
