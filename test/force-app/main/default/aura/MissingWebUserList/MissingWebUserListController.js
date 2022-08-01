/**
 * Created by jesus.cantero on 13/05/2021.
 */

({
    
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Id', fieldName: 'id', type: 'text'},
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'User Name', fieldName: 'userName', type: 'text'},
            {label: 'Email', fieldName: 'email', type: 'text'},
            {label: 'Company Name', fieldName: 'company', type: 'text'},
            {label: 'Premium User', fieldName: 'premium', type: 'check'}
        ]);
        var action = cmp.get("c.getMissingUsers");
        action.setCallback(this, function(result){
            var state = result.getState();
            var response = result.getReturnValue();
            console.log('response --->',response);
            if (state === "SUCCESS") {
                cmp.set("v.data", response.missingUsers);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    loadMissingUsers: function(cmp, event, helper){
        var allRows = JSON.stringify(cmp.get('v.data'));
                
        var action = cmp.get("c.insertMissingUsers");
        action.setParams({"jsonString" : allRows});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result  --> ',result);
                if(result.startsWith("User Already Exists")){
                    alert(result);
                }else if(result === "Missing Web Users Inserted Successfully"){
                    alert(result);
                }
            }
        });
        
        $A.enqueueAction(action);
	}
});