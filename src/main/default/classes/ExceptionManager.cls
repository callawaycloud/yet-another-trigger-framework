public class ExceptionManager {
    public void manage(Exception e, TriggerContext context, HandlerConfig config, Savepoint sp) {
        System.debug(e);
        switch on config.onException {
            when SUPPRESS {
                System.debug('Exception Suppress!');
                Database.rollback(sp);
            }
            when EMAIL {
                Database.rollback(sp);
                try {
                    sendEmail(e, context, config);
                } catch (Exception emailException) {
                    //suppress or throw? Maybe we need a "Secondary Error Strategy" configuration point
                    System.debug(emailException);
                }
            }
            when CUSTOM {
                try {
                    CustomExceptionHandler errHandler = (CustomExceptionHandler) Utils.constructFromName(
                        config.exceptionHandlerClassName
                    );
                    errHandler.handle(e, context, config, sp);
                } catch (Exception customHandlerException) {
                    //suppress or throw? Maybe we need a "Secondary Error Strategy" configuration point
                    System.debug(customHandlerException);
                    Database.rollback(sp);
                }
            }
            when else {
                throw e;
            }
        }
        // should we provide configuration over rollbacks?
        //  Maybe seems like it should always happen when the exception is handled
    }

    private void sendEmail(Exception e, TriggerContext context, HandlerConfig config) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(
            String.format(
                'An exception occurred in {0} trigger during {1}',
                new List<String>{ context.sObjectType, config.className }
            )
        );
        email.setPlainTextBody(
            String.format(
                '===Exception===\n{0} \n{1} \n===Context===\n{2}',
                new List<String>{ e.getMessage(), e.getStackTraceString(), JSON.serializePretty(context) }
            )
        );
        email.setToAddresses(config.exceptionEmailRecipients);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }
}
