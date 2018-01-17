@isTest
private class ACNLM_RefreshLimitMagicControllerTest {
	
	@isTest static void callFromButtonsSingleTest() {
		ACNLM_Environment__c env = ACNLM_TestHelper.createEnvironments(1)[0];
		insert env;
		system.assertEquals(1,[SELECT count() FROM ACNLM_Environment__c]);
		ACNLM_Batch_settings__c settings = ACNLM_TestHelper.createBatchSettings();
		insert settings;
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
		ACNLM_Batch_settings__c settings = ACNLM_TestHelper.createBatchSettings();
		insert settings;
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
		ACNLM_GetEnvironemntLimitsBatch.callFromButtons(envIds);
		test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
	}
}