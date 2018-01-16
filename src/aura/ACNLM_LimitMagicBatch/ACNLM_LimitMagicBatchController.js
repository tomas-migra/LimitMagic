({
    doInit : function(component, event, helper) {
	    helper.checkDataValidity(component);
	},
	createJob : function(component, event, helper){
		helper.scheduleNewJob(component);
	},
	deleteJob : function(component, event, helper){
		helper.abortJob(component);
	}
})