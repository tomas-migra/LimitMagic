({
    handleRecordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        	// record is loaded (render other component which needs record data value)
        	console.log('Record is loaded successfully.',component.get("v.envRecord"));
		   	helper.refreshThisEnv(component);
    	}
    }
})