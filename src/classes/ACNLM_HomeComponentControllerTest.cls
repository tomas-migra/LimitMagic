@isTest
private class ACNLM_HomeComponentControllerTest {
	
	@isTest static void getjobTest() {
		Test.startTest();
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		CronTrigger response = ACNLM_HomeComponentController.getjob();
		String settingName = ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName;
		String jobName = [SELECT Id, ACNLM_Name__c FROM ACNLM_BatchSettings__mdt WHERE DeveloperName =:settingName LIMIT 1].ACNLM_Name__c;
		if (response == null){
			system.assertEquals(0,[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name= :jobName LIMIT 1]);
		}else system.assertEquals(1,[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name= :jobName LIMIT 1]);
		Test.stopTest();
	}

	@isTest static void getjobNegativeTest() {
		Test.startTest();
		ACNLM_GetEnvironemntLimitsBatch.batchSettingsDeveloperName = 'test';
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		CronTrigger response = ACNLM_HomeComponentController.getjob();
		system.assertEquals(null, response);
		Test.stopTest();
	}

	@isTest static void getdataValidTest() {
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		ACNLM_HomeComponentController.getdataValid();
	}

	@isTest static void abortScheduleJobTest() {
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		CronTrigger response = ACNLM_HomeComponentController.getjob();
		if (response == null){
			ACNLM_HomeComponentController.scheduleNewJob();
			system.assertNotEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());	
			ACNLM_HomeComponentController.abortJob();
			system.assertEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());	
		}else {
			ACNLM_HomeComponentController.abortJob();
			system.assertEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());	
			ACNLM_HomeComponentController.scheduleNewJob();
			system.assertNotEquals(null, ACNLM_GetEnvironemntLimitsBatch.getScheduledJob());			
		}
	}
}