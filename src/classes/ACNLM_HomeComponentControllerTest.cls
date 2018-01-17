@isTest
private class ACNLM_HomeComponentControllerTest {
	
	@isTest static void getjobTest() {
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		ACNLM_Batch_settings__c settings = ACNLM_TestHelper.createBatchSettings();
		insert settings;
		ACNLM_HomeComponentController.getjob();
		String jobName = ACNLM_GetEnvironemntLimitsBatch.batchSettingsName;
		CronTrigger response = ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
		if (response == null){
			system.assertEquals(0,[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name= :jobName LIMIT 1]);
		}else system.assertEquals(1,[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name= :jobName LIMIT 1]);
	}

	@isTest static void getjobNegativeTest() {
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		ACNLM_HomeComponentController.getjob();
		String jobName = ACNLM_GetEnvironemntLimitsBatch.batchSettingsName;
		CronTrigger response = ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
		system.assertEquals(null, response);
	}

	@isTest static void abortScheduleJobTest() {
		ACNLM_Batch_settings__c settings = ACNLM_TestHelper.createBatchSettings();
		insert settings;
		ACNLM_HomeComponentController ACNLM_HomeComponentController = new ACNLM_HomeComponentController();
		CronTrigger response = ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
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