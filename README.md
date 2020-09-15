# ⚡️🤘⚡️ Yet-Another-Trigger-Framework ⚡️🤘⚡️

_This "framework" is an extension of the [`TriggerHandler` pattern which original shipped with Mavensmate](https://github.com/joeferraro/MavensMate-Templates/blob/master/ApexClass/TriggerHandler.cls)_

# 💪Goals

The goal of this project is to improve upon that concept, by adding additional configuration and capabilities, while at the same time **retaining full backwards compatibility**.

## ✨Features

-   Dynamic Binding of Trigger Handlers via Custom Metadata (similar to table based trigger)
-   Ability to disable whole triggers or individual handlers
-   Easy to upgrade, full backwards compatibility
-   Build in Error Handling & Logging
-   Ability to decouple your handlers from the system static `Trigger` context, which allows for better unit testability (no need to actually run DML in tests)

### Coming Soon

-   built in recursion control
-   support for other popular framework patterns ([sfdc-trigger-framework](https://github.com/kevinohara80/sfdc-trigger-framework))

## 📦Installation

-   [Package URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1C000000lIX3QAM) (replace host as needed)

-   command line: `sfdx force:package:install -p 04t1C000000lIX3QAM -u {TARGET ALIAS OR USERNAME} -b 1000 -w 1000`

## 🔨Usage

At it's core, the concept is very simple:

1. Create a class that `implements YATF.Handler`
1. Write a `void handle(){}` method to perform the trigger logic
1. Create a trigger (one trigger per object!) and bind your handlers to the appropriate events.

### Handler

```java
public class AccountGreeter implements YATF.Handler{
  public void handle(){
    for(Account acc : (Account[]) Trigger.new){
      System.debug('Hello ' + acc.Name);
    }
  }
}
```

### Trigger

```java
trigger AccountTrigger on Account(before insert){
  YATF.Manager m = new YATF.Manager();
  AccountGreeter greeter = new AccountGreeter();
  m.bind(TriggerOperation.BEFORE_INSERT, greeter);
  m.manage();
}
```

## Advanced Usage

### Dynamic Binding

<img width="1305" alt="Custom_Metadata_Types___Salesforce" src="https://user-images.githubusercontent.com/5217568/91907383-03565e80-ec67-11ea-903b-925db1d67e25.png">

Dynamic binding (or dependency injection) has the advantage of being able to switch out handlers without needed to deploy updates to the Trigger itself.

To do this for the above example:

1. update the `.trigger` to fire on all event:

```java
trigger AccountMaster on Account(
    after insert,
    after update,
    after delete,
    after undelete,
    before insert,
    before update,
    before delete
) {
  new YATF.Manager().manage();
}
```

_WARNING: this is technically not required. The performance impact of binding to all events is untested. If you are concerned, only bind the events you are using!_

2. Change the `Handler` access modifier to `global`

3. Setup the Custom Metadata

-   navigate to `setup -> Custom Metadata -> Trigger Object -> manage`
-   create a new Record.
    -   Set the `Object API Name` field to "Account"
    -   Save
-   create a new child `Trigger Handler`
    -   Set the `Handler Class` to "AccountGreeter"
    -   Check the `Before Update` box

<img width="1294" alt="Custom_Metadata_Types___Salesforce" src="https://user-images.githubusercontent.com/5217568/91907729-9becde80-ec67-11ea-82ee-16e39beee9f1.png">

<img width="1083" alt="Custom_Metadata_Types___Salesforce" src="https://user-images.githubusercontent.com/5217568/91908040-29303300-ec68-11ea-99a8-9832b4f0b545.png">

_NOTES_:

-   Dynamic Binding and Static binding can co-exist! Statically bound handlers will execute first.
-   You can still configuration for a statically bound trigger. The handler will **only execute one time per event**, but this allows you to disable a handler or use built in exception handling without having to deploy code.

### Disabling Triggers

You can disable the trigger on the entire `SObject` or just a single `Handler`. Simply un-check the `Enabled` field on the respective record.

_NOTE: You can disable a static bound trigger by adding a Handler Configuration!_

### Built in Exception Handling

<img width="1299" alt="Custom_Metadata_Types___Salesforce" src="https://user-images.githubusercontent.com/5217568/91908428-c5f2d080-ec68-11ea-8af7-16468d2b510d.png">

When a trigger throws an uncaught exception, you can choose how it should be handled via the `On Exception` field:

-   `Throw`: Just rethrows the error. Will cause the entire trigger to fail. This is the default.
-   `Rollback`: Creates a `Savepoint` prior to running handler and rolls back the transaction on exception. NOTE: this does NOT rollback changes made directly to the trigger context on `BEFORE` triggers.
-   `Suppress`: Will only `System.Debug` the exception.

### Exception Logging with Platform Events

Additionally, by setting `Create_Exception_Event__c` the system will platform events named `Trigger_Handler_Exception__e` any time an uncaught exception is thrown. This event contains details of the thrown exception, the handler that failed and the trigger context.

#### Registering Exception Event Listeners

<img width="646" alt="Custom_Metadata_Types___Salesforce" src="https://user-images.githubusercontent.com/5217568/91908673-2c77ee80-ec69-11ea-9bdf-c27d56e0d4d7.png">

You can register a listener to automatically run when a `Trigger_Handler_Exception__e` occurs by setting the `On_Exception_Event_Handler__c` field. The value must be the name of a `global` class which implements `ExceptionEventHandler`.

You can optionally use `On_Exception_Event_Handler_Props__c` to pass `json` properties which will be used to initialize the class.

#### Built in Listeners

##### `SendEmailExceptionEventHandler`

Sends an email with the details of the exception to one or more recipients. Requires the following `On_Exception_Event_Handler_Props__c` properties

`fromEmailAddress`: The ORG WIDE email address the email will be sent from
`recipients`: `String[]` of emails to send the exceptions to.

Example JSON:

```json
{
    "fromEmailAddress": "james.bond@callaway.cloud",
    "recipients": ["john@example.com", "jane@example.com"]
}
```

### Decoupling the Trigger Context

The design is not finalized, but the basic idea is to pass in or inject a proxy to the static `Trigger` variable (see [`TriggerContext`](https://github.com/callawaycloud/yet-another-trigger-framework/blob/master/src/main/default/classes/TriggerContext.cls)). This will allow you to define your own context during unit tests.

## Upgrading from Mavensmate "TriggerHandler"

1. Replace all instances of `TriggerHandler.HandlerInterface` with `YATF.Handler`

1. Replace all instances of `TriggerHandler` class with `YATF.Manager`.

1. Update all references of `TriggerHandler.Evt` to either `TriggerOperation` or `Manager.EVT` (easier to refactor but will be deprecated at some point).

1. Delete the `TriggerHandler` class from org

That's it! There should be no functional changes, but it's a good idea to run all unit tests before and after to confirm.

## 🤝Contributing

Please do! We will try to incorporate all reasonable ideas.

## 📝License

MIT
