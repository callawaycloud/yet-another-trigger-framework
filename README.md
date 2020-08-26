# Installation
-   Prod install URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1C000000xAewQAE
-   Sanndobx install URL: https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1C000000xAewQAE
-   Or install with sfdx `sfdx force:package:install -p 04t1C000000xAewQAE -u {TARGET ALIAS OR USERNAME} -b 1000 -w 1000`

# Implementation

There are different levels of implementation that can be performed. If migrating from the existing org specific TriggerHandler class, it's fairly easy to just remove the TriggerHandler related classes and do a quick search and replace for the handlers.

## Basic Implementation - Convert from existing TriggerHandler class

1) Replace all implementations of "TriggerHandler.HandlerInterface" with "YATH.Handler"

2) Replace all instances of TriggerHandler class with YATH.Manager. (Good way to do this is prefix with a space in your search and replace - " TriggerHandler" with "YATH.TriggerHandler"

3) Delete "TriggerHandler" class from org

## Auto binding implementation - Remove explicit bindings in triggers and replace with metadata

1) Ensure all master triggers execute on all events. In some cases you might have triggers that only fire on a couple of events. Since the trigger doesn't know what handlers it will be firing, we should just put all events on all triggers:

`trigger AccountMaster on Account(
    after insert,
    after update,
    after delete,
    after undelete,
    before insert,
    before update,
    before delete
) {
//...
}
`

## Alpha

-   custom metadata
-   test it out in live scenario
-   yo ccc, clear pipelines, run pretty
-   readme with installation link

## Beta

-   readme with usage instructions
-   useful descriptions/help text on fields and objects
-   code commenting and formatting
-   add validation rule to require at least one field on metadata to be set

## Other General

-   add contribution guidelines
-   add development instructions
    -   setup scratch org
    -   testing
    -   contribution guidelines
-   setup commands
    -   run all tests
    -   verify format
    -   create version
        -   verify tests pass
        -   push package version
        -   update installation url in readme?

## Feature Improvements

-   add off for events
-   inject handlers from metadata instead of disabling
-   configurable recursion prevention (requires switching to injection)
-   configurable perf logging (cpu time, db time, dml usage, query usage, heap size) (requires injection)
