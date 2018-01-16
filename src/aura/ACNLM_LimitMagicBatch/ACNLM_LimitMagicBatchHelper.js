({
	checkDataValidity : function(component){
	var action = component.get("c.checkDataValidity");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state==="SUCCESS"){
				if (response.getReturnValue() != null){
					console.log(response.getReturnValue());
	   	            this.showToast(component, response.getReturnValue()); 
				}else {
					this.getScheduledJob(component);
				}
	        }
	        else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        }
	            else if (state === "ERROR") {
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
	        }
	        else if (state === "INCOMPLETE") { console.log("No response from server or client is offline.") }
	            else if (state === "ERROR") {
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
	        }
	        else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        }
	            else if (state === "ERROR") {
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
	        }
	        else if (state === "INCOMPLETE") { 
	        	console.log("No response from server or client is offline.");
	        	this.showToast(component, "No response from server or client is offline."); 
	        }
	            else if (state === "ERROR") {
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