/**
 * ACNLM_GetEnvironemntLimitsBatch - Class which store all logic for retrieveing limits. 
 * Limits are retreived by batch, quick action on Environemnt object, List button on Env. List view and page button on Env. page
 * This class extend ACNLM_RefreshLimitMagicController and ACNLM_HomeComponentController.
 * This class is controller for ACNLM_LimitMagicBatch and ACNLM_LimitMagicOnce Lightning components.
 * Uses Custom metedata types, Custom label, Named credentials 
 * 
 * Limit Magic
 * @author  Tomas Migra (Accenture)
 * @created 2018-01-01
 * @version 1.0
 * 
 */
global class ACNLM_GetEnvironemntLimitsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	Final String jobEndpoint;
	Final String jobName;
	@TestVisible Final Integer jobInterval; 
	Final Integer jobSize;
	@TestVisible Boolean callAgain;
	@TestVisible Boolean testUtility = false;
	Boolean dataValid = false;
	Datetime now = datetime.now();
	String query = 'SELECT Id, ACNLM_NamedCredentials__c, ACNLM_Next_summary__c, ACNLM_Last_summary__c, ACNLM_Last_refresh__c, ACNLM_Environment_Interval__c, ACNLM_Notification_threshold__c FROM ACNLM_Environment__c WHERE ACNLM_Environment_Interval__c != 0 AND ACNLM_Environment_Interval__c != null AND (ACNLM_Next_refresh__c <= :now OR ACNLM_Last_refresh__c = null)';
	String errorMessage;
	@TestVisible static String batchSettingsDeveloperName = 'Main_settings';
	List<ACNLM_LimitMapping__mdt> limitMappings;
	Map<Id, Datetime> mapLastRefresh = new Map<Id, Datetime>(); 
	
	String threshold;
	String thresholdText;
	String thresholdTable;
	String summaryText;
	String summaryTable;

	/*Checks if LimitMappings and BatchSettings Custom metadata type exists if yes populate its values to variables*/
	global ACNLM_GetEnvironemntLimitsBatch(){
		List<ACNLM_BatchSettings__mdt> batchSettings = [SELECT Id, ACNLM_Name__c, ACNLM_Interval__c, ACNLM_Size__c, ACNLM_Call_again__c, ACNLM_Endpoint__c FROM ACNLM_BatchSettings__mdt WHERE DeveloperName =:batchSettingsDeveloperName LIMIT 1]; //Main_settings
		limitMappings = [SELECT DeveloperName, MasterLabel,Max_Field_API__r.QualifiedApiName ,Rem_Field_API__r.QualifiedApiName, (SELECT DeveloperName, MasterLabel,Max_Field_API__r.QualifiedApiName,Rem_Field_API__r.QualifiedApiName FROM LimitMappingChildren__r) FROM ACNLM_LimitMapping__mdt LIMIT 50000];
		if (!limitMappings.isEmpty() && !batchSettings.isEmpty()){
			jobEndpoint = batchSettings[0].ACNLM_Endpoint__c;
			jobName = batchSettings[0].ACNLM_Name__c;
			jobInterval = Integer.valueof(batchSettings[0].ACNLM_Interval__c); 
			jobSize =  Integer.valueof(batchSettings[0].ACNLM_Size__c);
			callAgain = batchSettings[0].ACNLM_Call_again__c;
			dataValid = true;
		} else errorMessage = System.Label.ACNLM_NotCorrectDataError;
	}
	
	/*Batch*/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/*Execute method is called also by button and quick actions*/
   	global void execute(Database.BatchableContext BC, List<ACNLM_Environment__c> scope) {
		List<ACNLM_Limit__c> listOfLimit = new List<ACNLM_Limit__c>();
		List<ACNLM_Environment__c> listOfEnv = new List<ACNLM_Environment__c>();
		for (ACNLM_Environment__c env : scope){
			threshold = null;
			thresholdText = null;
			thresholdTable = null;
			summaryText = null;
			summaryTable = null;
			mapLastRefresh.put(env.Id, env.ACNLM_Last_refresh__c);
			if (dataValid){//batchSettings or limitMapping correct
				errorMessage = null;
				HttpResponse response = getResponse(env.ACNLM_NamedCredentials__c);
				system.debug(response);
				if(response == null){//Mostly Named credential didnt found error from try catch
					listOfEnv.add(updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c)));
					system.debug(errorMessage);
				}
				else if (response.getStatus() == 'OK'){//Correct response
					System.debug(response.getbody());
					listOfLimit.add(createLimit(env, response.getbody()));
					listOfEnv.add(updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c)));
				}
				else if (response.getBody() != ''){//Mostly user not active
					List<ParseError> errorList = (List<ParseError>)JSON.deserialize(response.getbody(), List<ParseError>.class);
					System.debug(errorList);
					errorMessage = errorList[0].message;
					listOfEnv.add(updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c)));
				}
				else {//Wrong url in named credential
					System.debug(response);
					errorMessage = response.getStatus();
					listOfEnv.add(updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c)));
				}
			} else {
				listOfEnv.add(updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c)));//batchSettings or limitMapping not exist
			}
		}
		try{
			insert listOfLimit;
			update listOfEnv;
		} catch (Exception e){
			System.debug('ERROR:' + e);
			for (ACNLM_Environment__c env : listOfEnv){
				env.ACNLM_Status__c = 'Error';
				env.ACNLM_Message__c = e.getMessage();
				env.ACNLM_Last_refresh__c = mapLastRefresh.get(env.Id);
				errorMessage = e.getMessage();
			}update listOfEnv;
		}
	}
	
	/*Schedules batch again if all finished succesfully*/
	global Void finish(Database.BatchableContext BC) {
		if (dataValid && callAgain){
			ACNLM_GetEnvironemntLimitsBatch batch = new ACNLM_GetEnvironemntLimitsBatch();
       		System.scheduleBatch(batch, jobName, jobInterval, jobSize);
		}
	}
	
	/*If custom button pressed, and all data correct create Limits if not Error message on Environemnt filled in*/
	global static void callFromButtons(Set<Id> envIds){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		List<ACNLM_Environment__c> listOfEnv = new List<ACNLM_Environment__c> ([SELECT Id, ACNLM_NamedCredentials__c, ACNLM_Next_summary__c, ACNLM_Last_summary__c, ACNLM_Last_refresh__c, ACNLM_Environment_Interval__c, ACNLM_Notification_threshold__c FROM ACNLM_Environment__c WHERE Id IN :envIds]);
		List<ACNLM_Environment__c> listOfErrorEnv = new List<ACNLM_Environment__c> ();
		for (ACNLM_Environment__c env : listOfEnv){
			if (!ACNLM_GetEnvironemntLimitsBatch.dataValid){
				env = ACNLM_GetEnvironemntLimitsBatch.updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c));
				listOfErrorEnv.add(env);
			}
		}
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid && !listOfEnv.isEmpty()){
			ACNLM_GetEnvironemntLimitsBatch.execute(null, listOfEnv);
		}else if (!ACNLM_GetEnvironemntLimitsBatch.dataValid && !listOfErrorEnv.isEmpty()){
			update listOfErrorEnv;
		}
	}

  	/**
	 *Controller for ACNLM_LimitMagicOnce Lightning component
	 *If custom button pressed, and all data correct create Limits if not Error message on Environemnt filled in*/
	@AuraEnabled
	global static String callFromQuickAction(ACNLM_Environment__c env){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid){
			List<ACNLM_Environment__c> listOfEnv = new List<ACNLM_Environment__c>();
			listOfEnv.add(env);
			ACNLM_GetEnvironemntLimitsBatch.execute(null, listOfEnv);
			return ACNLM_GetEnvironemntLimitsBatch.errorMessage;
		}else {
			update ACNLM_GetEnvironemntLimitsBatch.updateEnv(env.Id, Integer.valueOf(env.ACNLM_Environment_Interval__c));
			return ACNLM_GetEnvironemntLimitsBatch.errorMessage;
		}
	}
  	/**
	 *Controller for ACNLM_LimitMagicOnce Lightning component
	 *Checks data if valid return null if not return error message*/
	@AuraEnabled
	global static String checkDataValidity(){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid){
			return null;
		}return ACNLM_GetEnvironemntLimitsBatch.errorMessage;
	}

	/**
	 *Controller for ACNLM_LimitMagicBatch Lightning component
	 *If data valid query Limit magic scheduledJob and return it*/
	@AuraEnabled
	global static CronTrigger getScheduledJob(){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid){
			List<CronTrigger> scheduledJobs = new List<CronTrigger>([SELECT Id, CreatedBy.Name,CreatedDate,NextFireTime,CronJobDetail.JobType,CronJobDetail.Name,StartTime FROM CronTrigger WHERE CronJobDetail.Name= :ACNLM_GetEnvironemntLimitsBatch.jobName LIMIT 1]);
			if (!scheduledJobs.isEmpty()){
				return scheduledJobs[0];
			}
		}
		return null;
	}

	/**
	 *Controller for ACNLM_LimitMagicBatch Lightning component
	 *If data valid get Scheduled job if null schedule new one, if alredy scheduled aborts it first and schedule new*/
	@AuraEnabled
	global static void scheduleNewJob(){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid){
			CronTrigger scheduledJob = getScheduledJob();
			if (scheduledJob == null){
				ACNLM_GetEnvironemntLimitsBatch.finish(null);
			}else {
				abortJob();
				ACNLM_GetEnvironemntLimitsBatch.finish(null);
			}
		}
	}

	/**
	 *Controller for ACNLM_LimitMagicBatch Lightning component
	 *If data valid get Scheduled job if not null aborts it*/
	@AuraEnabled
	global static void abortJob(){
		ACNLM_GetEnvironemntLimitsBatch ACNLM_GetEnvironemntLimitsBatch = new ACNLM_GetEnvironemntLimitsBatch();
		if (ACNLM_GetEnvironemntLimitsBatch.dataValid){
			CronTrigger scheduledJob = getScheduledJob();
			if (scheduledJob != null){
				System.AbortJob(scheduledJob.Id);
			}
		}
	}

	/*Getting JSON response, using Named Credential and endpoint from custom metadata BatchSettings */
	private HttpResponse getResponse(String NamedCredential){
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:'+NamedCredential+jobEndpoint);
		req.setMethod('GET');
		Http http = new Http();
		try{
			system.debug('Anydatatype_msg');
			HTTPResponse resp = http.send(req);
			system.debug('Anydatatype_msg');
			return resp;
		} catch (System.CalloutException e){
			System.debug('ERROR:' + e);
			errorMessage = e.getMessage();
		}
		return null;
	}

	/*Parsing JSON from getResponse and storing data to Limit object, also creating table for Summary and Notification Email*/
	private ACNLM_Limit__c createLimit (ACNLM_Environment__c env, String responseBody){
		ACNLM_Limit__c limitRec = new ACNLM_Limit__c();
		limitRec.ACNLM_Timestamp__c = datetime.now();
		if (testUtility){
			limitRec.ACNLM_Environment__c = null;
		}else limitRec.ACNLM_Environment__c = env.Id;
		String thresholdValue = '';
		String thresholdTextValue = '';
		String thresholdTableValue = addRowToTable(null,null,null,'Header');
		String summaryTextValue = '';
		String summaryTableValue = addRowToTable(null,null,null,'Header');
		Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
		for (ACNLM_LimitMapping__mdt limitMapping : limitMappings){
			if(jsonMap.containsKey(limitMapping.DeveloperName)){
				String jsonSubset = JSON.serialize(jsonMap.get(limitMapping.DeveloperName));
				ParseSucces jsonValue = (ParseSucces)JSON.deserialize(jsonSubset, ParseSucces.class);
				limitRec.put(limitMapping.Max_Field_API__r.QualifiedApiName, jsonValue.Max);
				limitRec.put(limitMapping.Rem_Field_API__r.QualifiedApiName, jsonValue.Remaining);
				if (jsonValue.Max != 0 && ((Decimal)jsonValue.Max-(Decimal)jsonValue.Remaining)/(Decimal)jsonValue.Max*100 >= env.ACNLM_Notification_threshold__c){
					thresholdValue += limitMapping.MasterLabel+'\n';
					thresholdTextValue += limitMapping.MasterLabel+' : '+jsonValue.Max+'/'+jsonValue.Remaining+' = '+(((Decimal)jsonValue.Max-(Decimal)jsonValue.Remaining)/(Decimal)jsonValue.Max*100).round()+'%\n';
					thresholdTableValue += addRowToTable(limitMapping.MasterLabel,jsonValue.Max,jsonValue.Remaining,'Body');
				}if (jsonValue.Max != 0 && (env.ACNLM_Next_summary__c <= datetime.now() || env.ACNLM_Last_summary__c == null)){
					summaryTextValue += limitMapping.MasterLabel+' : '+jsonValue.Max+'/'+jsonValue.Remaining+' = '+(((Decimal)jsonValue.Max-(Decimal)jsonValue.Remaining)/(Decimal)jsonValue.Max*100).round()+'%\n';
					if (((Decimal)jsonValue.Max-(Decimal)jsonValue.Remaining)/(Decimal)jsonValue.Max*100 >= env.ACNLM_Notification_threshold__c){
						summaryTableValue += addRowToTable(limitMapping.MasterLabel,jsonValue.Max,jsonValue.Remaining,'BodyThreshold');
					}else{
						summaryTableValue += addRowToTable(limitMapping.MasterLabel,jsonValue.Max,jsonValue.Remaining,'Body');
					}
				}	
				Map<String, Object> jsonMapChild = (Map<String, Object>)JSON.deserializeUntyped(jsonSubset);
				for (ACNLM_LimitMappingChild__mdt limitMappingChild : limitMapping.LimitMappingChildren__r){
					if(jsonMapChild.containsKey(limitMappingChild.DeveloperName)){
						String jsonSubsetChild = JSON.serialize(jsonMapChild.get(limitMappingChild.DeveloperName));
						ParseSucces jsonValueChild = (ParseSucces)JSON.deserialize(jsonSubsetChild, ParseSucces.class);
						limitRec.put(limitMappingChild.Max_Field_API__r.QualifiedApiName, jsonValueChild.Max);
						limitRec.put(limitMappingChild.Rem_Field_API__r.QualifiedApiName, jsonValueChild.Remaining);
						if (jsonValueChild.Max != 0 && ((Decimal)jsonValueChild.Max-(Decimal)jsonValueChild.Remaining)/(Decimal)jsonValueChild.Max*100 >= env.ACNLM_Notification_threshold__c){
							thresholdValue += limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel+'\n';
							thresholdTextValue += limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel+' : '+jsonValueChild.Max+'/'+jsonValueChild.Remaining+' = '+(((Decimal)jsonValueChild.Max-(Decimal)jsonValueChild.Remaining)/(Decimal)jsonValueChild.Max*100).round()+'%\n';
							thresholdTableValue += addRowToTable(limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel,jsonValueChild.Max,jsonValueChild.Remaining,'Body');
						}if (jsonValueChild.Max != 0 && (env.ACNLM_Next_summary__c <= datetime.now() || env.ACNLM_Last_summary__c == null)){
							summaryTextValue += limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel+' : '+jsonValueChild.Max+'/'+jsonValueChild.Remaining+' = '+(((Decimal)jsonValueChild.Max-(Decimal)jsonValueChild.Remaining)/(Decimal)jsonValueChild.Max*100).round()+'%\n';
							if (((Decimal)jsonValueChild.Max-(Decimal)jsonValueChild.Remaining)/(Decimal)jsonValueChild.Max*100 >= env.ACNLM_Notification_threshold__c){
								summaryTableValue += addRowToTable(limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel,jsonValueChild.Max,jsonValueChild.Remaining,'BodyThreshold');
							}else{
								summaryTableValue += addRowToTable(limitMapping.MasterLabel+'.'+limitMappingChild.MasterLabel,jsonValueChild.Max,jsonValueChild.Remaining,'Body');							
							}
						}
					}
				}
			}
		}
		threshold = thresholdValue;
		thresholdText = thresholdTextValue;
		thresholdTableValue += addRowToTable(null,null,null,'Footer');
		thresholdTable = thresholdTableValue;
		summaryText = summaryTextValue;
		summaryTableValue += addRowToTable(null,null,null,'Footer');
		summaryTable = summaryTableValue;
		return limitRec;
	}

	/*Creating Summary and Notification email table*/
	private String addRowToTable (String Label, Integer Max, Integer Rem, String type){
		String tableRow = '';
		if (type == 'Header'){
			tableRow += '<table border="1" cellpadding="5" colspan="1" rowspan="1" style="width:100%"><tr style="background-color: #4f6128">';
			tableRow += '<td><font color="white"><b>Limit name</td>';
			tableRow += '<td align="center"><font color="white">Max</td>';
			tableRow += '<td align="center"><font color="white">Remaining</td>';
			tableRow += '<td align="center"><font color="white">Used</b></td>';
			tableRow += '</tr>';
		}
		else if(type == 'Footer'){
			tableRow += '</tbody></table>';
		}
		else if(type == 'BodyThreshold'){
			tableRow += '<tr style="background-color: #ff0000">';
        	tableRow += '<td><font color="#3F3D33">'+Label+'</td>';
        	tableRow += '<td align="right"><font color="#3F3D33">'+Max+'</td>';
        	tableRow += '<td align="right"><font color="#3F3D33">'+Rem+'</td>';
         	tableRow += '<td align="right"><font color="#3F3D33">'+(((Decimal)Max-(Decimal)Rem)/(Decimal)Max*100).round()+'%</td>';
        	tableRow += '</tr>';
		}
		else{
			tableRow += '<tr>';
        	tableRow += '<td><font color="#3F3D33">'+Label+'</td>';
        	tableRow += '<td align="right"><font color="#3F3D33">'+Max+'</td>';
        	tableRow += '<td align="right"><font color="#3F3D33">'+Rem+'</td>';
         	tableRow += '<td align="right"><font color="#3F3D33">'+(((Decimal)Max-(Decimal)Rem)/(Decimal)Max*100 ).round()+'%</td>';
        	tableRow += '</tr>';
		}
		return tableRow;
	}

	/*Update values on Environment record*/
	private ACNLM_Environment__c updateEnv(Id envId, Integer envInterval){
		ACNLM_Environment__c env = new ACNLM_Environment__c();
		env.Id = envId;
		env.ACNLM_Message__c = errorMessage;
		env.ACNLM_Notification_Limits__c = threshold;
		env.ACNLM_Notification_Limits_Text__c = thresholdText;
		env.ACNLM_Notification_Limits_Table__c = thresholdTable;
		env.ACNLM_Summary_Limits_Text__c = summaryText;
		env.ACNLM_Summary_Limits_Table__c = summaryTable;
		if (errorMessage == null){
			env.ACNLM_Last_refresh__c = datetime.now();
			env.ACNLM_Status__c = 'OK';
			env.ACNLM_Message__c = '-';
			if (summaryText != '' && summaryText != null){
				env.ACNLM_Last_summary__c = datetime.now();
			}
		}else {
			env.ACNLM_Status__c = 'Error';
		}
		if (dataValid){
			if (envInterval != null && envInterval != 0 && math.mod(envInterval, jobInterval)!= 0){
				env.ACNLM_Environment_Interval__c = jobInterval * math.ceil((Decimal)envInterval / (Decimal)jobInterval);
			}
		}
		return env;
	}

	private class ParseError{
		private String errorCode;
		private String message;
	}

	private class ParseSucces{
		public Integer Max;
		public Integer Remaining;
	}
}
