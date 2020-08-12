# Installation

-   Go to [package installation url](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1C000000pQcjQAE)
-   Or install with sfdx `sfdx force:package:install -p 04t1C000000pQcjQAE -u target_alias_or_username -b 1000 -w 1000`

# TODOS

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
