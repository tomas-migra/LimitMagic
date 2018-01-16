@isTest
public class ACNLM_GetEnvironemntLimitsBatchTest {
	@isTest static void batchTestDataValid() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(5);
		envList[0].ACNLM_Notification_Threshold__c = 99;
		insert envList;
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		batch.callAgain = false;
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(5, [SELECT count() FROM ACNLM_Limit__c]);
	}
	
	@isTest static void batchTestDataNotValid() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(1);
		insert envList;
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName = 'test';
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
		system.assertEquals(System.Label.ACNLM_NotCorrectDataError, [SELECT Id, ACNLM_Message__c FROM ACNLM_Environment__c].ACNLM_Message__c);
	}

	@isTest static void batchUnauthorizedEndpointTest() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(1);
		insert envList;
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		batch.callAgain = false;
		ACNLM_TestHelper.responseType = 'Unauthorized';
		Test.setMock(HttpCalloutMock.class, new ACNLM_TestHelper());
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
		system.assertEquals('Unauthorized endpoint, please check Setup->Security->Remote site settings.', [SELECT Id, ACNLM_Message__c FROM ACNLM_Environment__c].ACNLM_Message__c);
	}

	@isTest static void batchUserNotActiveTest() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(1);
		insert envList;
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		batch.callAgain = false;
		ACNLM_TestHelper.responseType = 'Session expired';
		Test.setMock(HttpCalloutMock.class, new ACNLM_TestHelper());
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
		system.assertEquals('Session expired or invalid', [SELECT Id, ACNLM_Message__c FROM ACNLM_Environment__c].ACNLM_Message__c);
	}

	@isTest static void batchTestEmptyResponse() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(1);
		insert envList;
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		batch.callAgain = false;
		ACNLM_TestHelper.responseType = null;
		Test.setMock(HttpCalloutMock.class, new ACNLM_TestHelper());
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
		system.assertEquals('Response is empty.', [SELECT Id, ACNLM_Message__c FROM ACNLM_Environment__c].ACNLM_Message__c);
	}

	@isTest static void callFromQuickActionTest() {
		ACNLM_Environment__c env = ACNLM_TestHelper.createEnvironments(1)[0];
		insert env;
		Test.startTest();
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		String response = ACNLM_GetEnvironemntLimitsBatch.callFromQuickAction(env);
		Test.stopTest();
		system.assertEquals(1, [SELECT count() FROM ACNLM_Limit__c]);
	}

	@isTest static void callFromQuickActionNegativeTest() {
		ACNLM_Environment__c env = ACNLM_TestHelper.createEnvironments(1)[0];
		insert env;
		ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName = 'test';
		Test.startTest();
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		String response = ACNLM_GetEnvironemntLimitsBatch.callFromQuickAction(env);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
		system.assertEquals(System.Label.ACNLM_NotCorrectDataError, response);
	}

	@isTest static void checkDataValidityTest() {
		String response = ACNLM_GetEnvironemntLimitsBatch.checkDataValidity();
		system.assertEquals(null, response);
	}

	@isTest static void checkDataValidityNegativeTest() {
		ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName = 'test';
		String response = ACNLM_GetEnvironemntLimitsBatch.checkDataValidity();
		system.assertEquals(System.Label.ACNLM_NotCorrectDataError, response);
	}

	@isTest static void abortScheduleJobTest() {
		CronTrigger response = ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
		if (response == null){
			ACNLM_GetEnvironemntLimitsBatch.scheduleNewJob();
			response = ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
			system.assertNotEquals(null, response);
			ACNLM_GetEnvironemntLimitsBatch.scheduleNewJob();
			system.assertNotEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());
			system.assertNotEquals(response, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());
			ACNLM_GetEnvironemntLimitsBatch.abortJob();
			system.assertEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());	
		}else {
			ACNLM_GetEnvironemntLimitsBatch.scheduleNewJob();
			system.assertNotEquals(response, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());
			system.assertNotEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());
			ACNLM_GetEnvironemntLimitsBatch.abortJob();
			system.assertEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());	
			ACNLM_GetEnvironemntLimitsBatch.scheduleNewJob();
			system.assertNotEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());			
		}		
	}

	@isTest static void catchTest() {
		List<ACNLM_Environment__c> envList = ACNLM_TestHelper.createEnvironments(1);
		ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
		if (batch.jobInterval - 1 == 0){
			envList[0].ACNLM_Environment_Interval__c = batch.jobInterval - 2;
		}else envList[0].ACNLM_Environment_Interval__c = batch.jobInterval - 1;
		insert envList;
		system.assertEquals(1, [SELECT count() FROM ACNLM_Environment__c]);
		Test.startTest();
		batch.callAgain = false;
		batch.testUtility = true;
		ACNLM_TestHelper.staticMockResponse('ACNLM_CalloutMock');
		Database.executeBatch(batch, 100);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM ACNLM_Limit__c]);
	}
}