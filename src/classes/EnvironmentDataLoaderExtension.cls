public with sharing class EnvironmentDataLoaderExtension {

	private final ACNLM_Environment__c env;
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    private PageReference cancelPage;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public EnvironmentDataLoaderExtension(ApexPages.StandardController stdController) {
        env = (ACNLM_Environment__c)stdController.getRecord();
        cancelPage = stdController.cancel();
    }

    public PageReference doImport() {
        return null;
    }

    public PageReference goBack() {
        return cancelPage;
    }
}