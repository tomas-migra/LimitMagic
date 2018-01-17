({
	checkDataValidity : function(component){
	var action = component.get("c.checkDataValidity");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        var errorLabel = $A.get("$Label.c.ACNLM_NotCorrectDataError");
	        if(state==="SUCCESS"){
				if (response.getReturnValue() === null){
					this.getScheduledJob(component);
					component.set("v.newCustomSettings", false);
				}else if(response.getReturnValue() != errorLabel){
					component.set("v.newCustomSettings", true);
					component.set("v.spinnerShow", false);
				}else {
					console.log(response.getReturnValue());
	   	            this.showToast(component, response.getReturnValue());
				}
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);
                    	this.showToast(component, errors[0].message);
                    }
                } else { 
                	console.log("Unknown error");
   	                this.showToast(component, "Unknown error");             	
                }
            }
	    });
		$A.enqueueAction(action);
	},
	getBatchSettings : function(component){
	var action = component.get("c.getBatchSettings");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        var errorLabel = $A.get("$Label.c.ACNLM_NotCorrectDataError");
	        if(state==="SUCCESS"){
				component.set("v.customSettings", response.getReturnValue());
				this.showSettingSection(component, true);
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);
                    	this.showToast(component, errors[0].message);
                    }
                } else { 
                	console.log("Unknown error");
   	                this.showToast(component, "Unknown error");             	
                }
            }
	    });
		$A.enqueueAction(action);
	},
	getScheduledJob : function(component) {
	var action = component.get("c.getScheduledJob");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state==="SUCCESS"){
	        	console.log("SUCCES");
	        	component.set("v.scheduledJob", response.getReturnValue());
	            component.set("v.spinnerShow", false);
	        	var rowInTable = component.find('tableBody');
				if (response.getReturnValue() === null){
	            	$A.util.addClass(rowInTable, 'slds-hide');
	        	} else{
	            	$A.util.removeClass(rowInTable, 'slds-hide');
	        	}
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { console.log("Error message: " + errors[0].message); }
                } else { console.log("Unknown error"); }
            }
	    });
		$A.enqueueAction(action);
	},
	scheduleNewJob : function (component){
		component.set("v.spinnerShow", true);
		var action = component.get("c.scheduleNewJob");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state==="SUCCESS"){
	            this.getScheduledJob(component);
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);
                    	this.showToast(component, errors[0].message);
                    }
                } else { 
                	console.log("Unknown error");
   	                this.showToast(component, "Unknown error");             	
                }
            }
	    });
		$A.enqueueAction(action);
	},
	abortJob : function (component){
		component.set("v.spinnerShow", true);
		var action = component.get("c.abortJob");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state==="SUCCESS"){
	            this.getScheduledJob(component);
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);
                    	this.showToast(component, errors[0].message);
                    }
                } else { 
                	console.log("Unknown error");
   	                this.showToast(component, "Unknown error");             	
                }
            }
	    });
		$A.enqueueAction(action);
	},
	saveCustomSettings : function(component){
		component.set("v.spinnerShow", true);
		var action = component.get("c.saveCustomSettings");
		var newCustomSettings = component.get("v.newCustomSettings");
		action.setParams({ 
	    	"batchSettings" : component.get("v.customSettings"),
	    	"isNew" : newCustomSettings
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        var scheduledJob = component.get("v.scheduledJob");
	        if(state==="SUCCESS"){
	        	if (newCustomSettings ){this.abortJob(component)}
	        	component.set("v.newCustomSettings", false);
	        	this.showSettingSection(component, false);
	        	if(scheduledJob != null){
	        		this.abortJob(component);
	        		this.scheduleNewJob(component);
	        	}else component.set("v.spinnerShow", false);
	        } else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);
                    	this.showToast(component, errors[0].message);
                    }
                } else { 
                	console.log("Unknown error");
   	                this.showToast(component, "Unknown error");             	
                }
            }
	    });
		$A.enqueueAction(action);
	},
	showSettingSection : function(component, show){
		var jobSection = component.find("jobSection");
		var settingSection = component.find("settingSection");
		var editSettingsButtton = component.find("editSettingsButtton");
		var saveSettingsButtton = component.find("saveSettingsButtton");
		var cancelSettingsButtton = component.find("cancelSettingsButtton");
		var deleteJobButtton = component.find("deleteJobButtton");
		var scheduleJobButtton = component.find("scheduleJobButtton");
		if(show){
			$A.util.addClass(jobSection, 'slds-hide');
			$A.util.removeClass(settingSection, 'slds-hide');
			$A.util.addClass(editSettingsButtton, 'slds-hide');
			$A.util.removeClass(saveSettingsButtton, 'slds-hide');
			$A.util.removeClass(cancelSettingsButtton, 'slds-hide');
			$A.util.addClass(deleteJobButtton, 'slds-hide');
			$A.util.addClass(scheduleJobButtton, 'slds-hide');
		}else{
			$A.util.removeClass(jobSection, 'slds-hide');
			$A.util.addClass(settingSection, 'slds-hide');
			$A.util.removeClass(editSettingsButtton, 'slds-hide');
			$A.util.addClass(saveSettingsButtton, 'slds-hide');
			$A.util.addClass(cancelSettingsButtton, 'slds-hide');
			$A.util.removeClass(deleteJobButtton, 'slds-hide');
			$A.util.removeClass(scheduleJobButtton, 'slds-hide');
		}
	},
	showToast : function(component, errorMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "title": "Error!",
	        "message": errorMessage,
	        "type":"error"
	    });
	    toastEvent.fire();
	}
})