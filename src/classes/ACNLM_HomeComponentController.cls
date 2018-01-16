public with sharing class ACNLM_HomeComponentController {

    private Boolean dataValid;
    public Boolean getdataValid(){
        return dataValid;
    }
    public CronTrigger getjob() {
        String errorMessage = ACNLM_GetEnvironemntLimitsBatch.checkDataValidity();
        if(errorMessage != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            dataValid = false;
            return null;
        }else {
            dataValid = true;
            return ACNLM_GetEnvironemntLimitsBatch.getScheduledJob();
        }
    }

    public PageReference scheduleNewJob() {
        ACNLM_GetEnvironemntLimitsBatch.scheduleNewJob();
        return null;
    }

    public PageReference abortJob() {
        ACNLM_GetEnvironemntLimitsBatch.abortJob();
        return null;
    }
}