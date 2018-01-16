public with sharing class ACNLM_RefreshLimitMagicController {

	private List<ACNLM_Environment__c> listOfEnv = new List<ACNLM_Environment__c>();
    private ACNLM_Environment__c env;
    private PageReference cancelPage;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ACNLM_RefreshLimitMagicController(ApexPages.StandardSetController controller){
        listOfEnv = controller.getSelected();
        cancelPage = controller.cancel();
    }

    public ACNLM_RefreshLimitMagicController(ApexPages.StandardController controller){
        env = (ACNLM_Environment__c)controller.getRecord();
        cancelPage = controller.cancel();
    }

    public PageReference doRefreshAndGoBack() {
        Set<Id> envIdSet = new Set<Id>();    
        if (env != null){
            envIdSet.add(env.Id);
            ACNLM_GetEnvironemntLimitsBatch.callFromButtons(envIdSet);
        }
        else if (!listOfEnv.isEmpty()){
            for (ACNLM_Environment__c envValue : listOfEnv){
                envIdSet.add(envValue.Id);
            }
            ACNLM_GetEnvironemntLimitsBatch.callFromButtons(envIdSet);   
        } 
        return cancelPage;
    }
}