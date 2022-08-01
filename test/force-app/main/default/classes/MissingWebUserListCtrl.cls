/**
* Created by jesus.cantero on 13/05/2021.
*/

public with sharing class MissingWebUserListCtrl {
    
    @AuraEnabled
    public static MissingUserWrapper getMissingUsers(){
        
        List<ExternalUsersResponse> externalUsers = getExternalUsers();
        
        MissingUserWrapper MissingUserWrapper = new MissingUserWrapper();
        List<MissingUser> missingUsers = new List<MissingUser>();
        
        for(ExternalUsersResponse externalUser : externalUsers){
            MissingUser missingUser = new MissingUser();
            missingUser.id = externalUser.id;
            missingUser.name = externalUser.name;
            missingUser.userName = externalUser.username;
            missingUser.email = externalUser.email;
            missingUser.company = externalUser.company.name;
            missingUser.premium = externalUser.company.name == 'Johns Group' || externalUser.company.name == 'Considine-Lockman' ? true : false;
            missingUsers.add(missingUser);
        }
        
        MissingUserWrapper.missingUsers = MissingUsers;
        return MissingUserWrapper;
    }
    
    public static List<ExternalUsersResponse> getExternalUsers(){        
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://jsonplaceholder.typicode.com/users');
        
        HttpResponse response = http.send(request);
        
        List<ExternalUsersResponse> responseBody = new List<ExternalUsersResponse>();
        
        if(response.getStatusCode() == 200){
            responseBody = (List<ExternalUsersResponse>) JSON.deserialize(response.getBody(), List<ExternalUsersResponse>.class);
        }
        return responseBody;
    }
    
    public class MissingUserWrapper{
        @AuraEnabled public List<MissingUser> missingUsers {get; set;}
    }
    
    public class MissingUser{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String userName;
        @AuraEnabled public String email;
        @AuraEnabled public String company;
        @AuraEnabled public Boolean premium;
    }
    
    @AuraEnabled
    public static String insertMissingUsers(String jsonString){
        
        List<MissingUser> usersList = (List<MissingUser>) JSON.deserialize(jsonString, List<MissingUser>.class);
        
        List<Web_User__c> webUsers = new List<Web_User__c>();
        
        Set<String> webSiteIds = new Set<String>();
        for(MissingUser user : usersList){
            webSiteIds.add(user.id);
            Web_User__c webUser = new Web_User__c();
            webUser.Name = user.name;
            webUser.Username__c = user.userName;
            webUser.Email__c = user.email;
            webUser.Company__c = user.company;
            webUser.Web_Site_Id__c = user.id;
            webUsers.add(webUser);
        }
        
        List<Web_User__c> existingWebUsers = [SELECT Id, Name FROM Web_User__c WHERE Web_Site_Id__c IN: webSiteIds];
        
        if(existingWebUsers.size() > 0 && existingWebUsers != null){
            String errorMessage = '';
            for(Web_User__c user : existingWebUsers){
                errorMessage += user.Name+', ';
			}            
            return 'User Already Exists with same webbsite Id : '+errorMessage;
        }else if(webUsers.size() > 0 && webUsers != null){
            insert webUsers;
            return 'Missing Web Users Inserted Successfully';
        }
        return 'Fail';
    }
}