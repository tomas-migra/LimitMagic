@isTest
public class ACNLM_TestHelper implements HttpCalloutMock {
	public static String responseType = null;

    public static HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        if (responseType == 'Unauthorized'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e; 
        }else if (responseType == 'Session expired'){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}]');
            res.setStatusCode(200);
            return res;
        }else {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('');
            res.setStatusCode(200);
            res.setStatus('Response is empty.');
            return res;
        }
    }

    public static Void staticMockResponse(String staticResource){
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResource);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
	}

    public static List<ACNLM_Environment__c> createEnvironments(Integer numOfEnvironemnts){
        List<ACNLM_Environment__c> envList = new List<ACNLM_Environment__c>(); 
        for (Integer i = 0; i < numOfEnvironemnts; i++) {
            ACNLM_Environment__c env = new ACNLM_Environment__c();
            env.Name = 'TestEnv'+numOfEnvironemnts;
            env.ACNLM_Next_refresh__c = datetime.now();
            env.ACNLM_Environment_Interval__c = 1;
            env.ACNLM_Summary_Interval__c = 1;
            env.ACNLM_Notification_Threshold__c = 2;
            env.ACNLM_NamedCredentials__c = 'test'+i;
            envList.add(env);
        }
        return envList;
    }

    public static ACNLM_Batch_settings__c createBatchSettings(){
        ACNLM_Batch_settings__c settings = new ACNLM_Batch_settings__c();
        settings.ACNLM_Endpoint__c = '/services/data/v41.0/limits';
        settings.ACNLM_Interval__c = 60;
        settings.ACNLM_Size__c = 200;
        settings.Name = 'LimitMagic';
        return settings;
    }
}