({
    doInit : function(component, event, helper) {
	    helper.checkDataValidity(component);
	},
	createJob : function(component, event, helper){
		helper.scheduleNewJob(component);
	},
	deleteJob : function(component, event, helper){
		helper.abortJob(component);
	},
	editSettings : function(component, event, helper){
		helper.getBatchSettings(component);		
	},
	cancelSettins : function(component, event, helper){
		helper.showSettingSection(component,false);
	},
	saveSettings : function(component, event, helper){
		var fieldList = component.find("batchSettingInput");
		var validity = true;
		for (var i = 0; i < fieldList.length; i++) {
			if (validity != false){
				validity = fieldList[i].get("v.validity").valid;
			}
		}
		if (validity){
			helper.saveCustomSettings(component);
		}
	}
})