@isTest
private class ACNLM_RefreshLimitMagicControllerTest {
	
	@isTest static void callFromButtonsSingleTest() {
		ACNLM_Environment__c env = ACNLM_TestHelper.createEnvironments(1)[0];
		insert env;
		system.assertEquals(1,[SELECT count() FROM ACNLM_Environment__c]);
		List<ACNLM_BatchSettings__mdt> batchSettings = [SELECT Id, ACNLM_Name__c, ACNLM_Interval__c, ACNLM_Size__c, ACNLM_Call_again__c, ACNLM_Endpoint__c FROM ACNLM_BatchSettings__mdt WHERE DeveloperName ='Main_settings' LIMIT 1]; //Main_settings
		List<ACNLM_LimitMapping__mdt> limitMappings = [SELECT MasterLabel,Max_Field_API__r.QualifiedApiName ,Rem_Field_API__r.QualifiedApiName, (SELECT MasterLabel,Max_Field_API__r.QualifiedApiName,Rem_Field_API__r.QualifiedApiName FROM LimitMappingChildren__r) FROM ACNLM_LimitMapping__mdt LIMIT 50000];
		system.assertEquals(true, (!limitMappings.isEmpty() && !batchSettings.isEmpty())); 
		Test.startTest();
		ApexPages.StandardController controller = new ApexPages.StandardController(env);
		ACNLM_RefreshLimitMagicController ACNLM_RefreshLimitMagicController = new ACNLM_RefreshLimitMagicController(controller);
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		ACNLM_RefreshLimitMagicController.doRefreshAndGoBack();
		test.stopTest();
		system.assertEquals(1, [SELECT count() FROM ACNLM_Limit__c]);
	}
	
	@isTest static void callFromButtonsBulkTest() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(3);
		insert envList;
		system.assertEquals(3,[SELECT count() FROM ACNLM_Environment__c]);
		Test.startTest();
		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(envList);
		controller.setSelected(envList);
		ACNLM_RefreshLimitMagicController ACNLM_RefreshLimitMagicController = new ACNLM_RefreshLimitMagicController(controller);
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		ACNLM_RefreshLimitMagicController.doRefreshAndGoBack();
		test.stopTest();
		system.assertEquals(3, [SELECT count() FROM ACNLM_Limit__c]);
	}

	@isTest static void callFromButtonsBulkNegativeTest() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(3);
		insert envList;
		system.assertEquals(3,[SELECT count() FROM ACNLM_Environment__c]);
		Set<Id>envIds = (new Map<Id,ACNLM_Environment__c>(envList)).keySet();
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName = 'test';
		ACNLM_GetEnvironemntLimitsBatch.callFromButtons(envIds);
		test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
	}
}