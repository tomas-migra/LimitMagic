({
	refreshThisEnv : function(component) {
	var action = component.get("c.callFromQuickAction");
	    action.setParams({ 
	    	"env" : component.get("v.envRecord")
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state==="SUCCESS" && response.getReturnValue() == null){
	            $A.get('e.force:refreshView').fire();
	        }
	        if(state==="SUCCESS" && response.getReturnValue() != null){
	            $A.get('e.force:refreshView').fire();
	            this.showToast(component, response.getReturnValue());
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
	        $A.get("e.force:closeQuickAction").fire();
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