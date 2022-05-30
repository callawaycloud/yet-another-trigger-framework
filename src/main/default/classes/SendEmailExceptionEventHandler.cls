global class SendEmailExceptionEventHandler implements ExceptionEventHandler {

    /**
     * ORG WIDE EMAIL ADDRESS to use to send email.
     * Required due to limitation sending emails from PE.
     */
    public String fromEmailAddress;

    /**
     * Email Address to send the exceptions to
     */
    public String[] recipients;

    global void handleExceptionEvents(ExceptionEvent event) {
        OrgWideEmailAddress[] owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :fromEmailAddress LIMIT 1];
        Id fromId;
        if(!owe.isEmpty()){
            fromId = owe[0].Id;
        }
        if (recipients == null || recipients.size() == 0) {
            throw new SendEmailExceptionEventHandlerException('Must Specify recipients array');
        }
        // need to hit the "createEmail" method for test coverage
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{ createEmail(event, fromId) };
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(messages);
        }
    }

    private Messaging.SingleEmailMessage createEmail(ExceptionEvent e, Id fromId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = String.format(
            'An exception occurred in {0} trigger during {1}',
            new List<String>{ e.SObjectType, e.config.className }
        );

        String context = String.format(
            'SObjectType: {0} \nOperation: {1} \nRecord Count: {2} \nNew Records: \n{3}\nOld Records: \n{4}',
            new List<String>{
                e.SObjectType,
                e.operationType.name(),
                String.valueOf(e.size),
                e.event.New_Records__c,
                e.event.Old_Records__c
            }
        );
        String body = String.format(
            '===USER===\n{0}\n\n===Exception===\n{1} \n{2}\n\n===CONTEXT===\n{3}',
            new List<String>{ e.user, e.message, e.stackTrace, context }
        );

        return createEmail(subject, body, fromId, recipients);
    }

    private static Messaging.SingleEmailMessage createEmail(
        String subject,
        String body,
        Id fromId,
        String[] recipients
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setToAddresses(recipients);
        email.setOrgWideEmailAddressId(fromId);
        return email;
    }

    global class SendEmailExceptionEventHandlerException extends Exception {
    }
}
