@isTest
global class MissingWebUserListCtrlTests implements HttpCalloutMock{

    @isTest
    static void getExternalUsers(){
        String response = '[{"id":1234, "name": "Test Missing User1", "username": "Test1", "email": "Test1@test.com", "company": {"name": "Test 1 Company"}},'+
            				'{"id":4567, "name": "Test Missing User2", "username": "Test2", "email": "Test2@test.com", "company": {"name": "Test 2 Company"}}]';
        
        MissingWebUserListCtrlTests mock = new MissingWebUserListCtrlTests(200, response);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        MissingWebUserListCtrl.MissingUserWrapper actual = MissingWebUserListCtrl.getMissingUsers();
        Test.stopTest();
        
        
        System.assertEquals(2, actual.missingUsers.size(), 'Incorrect Number of users Returned');
        System.assertEquals('1234', actual.missingUsers[0].id, 'Incorrect Id');
        System.assertEquals('Test Missing User1', actual.missingUsers[0].name, 'Incorrect name');
        System.assertEquals('Test1', actual.missingUsers[0].username, 'Incorrect username');
        System.assertEquals('Test1@test.com', actual.missingUsers[0].email, 'Incorrect email');
        System.assertEquals('Test 1 Company', actual.missingUsers[0].company, 'Incorrect company');
        System.assertEquals(false, actual.missingUsers[0].premium, 'Incorrect premium');
    }
    
    @isTest
    static void getExternalUsersCheckPremiumAsTrue(){
        String response = '[{"id":1234, "name": "Test Missing User1", "username": "Test1", "email": "Test1@test.com", "company": {"name": "Johns Group"}},'+
            				'{"id":4567, "name": "Test Missing User2", "username": "Test2", "email": "Test2@test.com", "company": {"name": "Considine-Lockman"}}]';
        
        MissingWebUserListCtrlTests mock = new MissingWebUserListCtrlTests(200, response);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        MissingWebUserListCtrl.MissingUserWrapper actual = MissingWebUserListCtrl.getMissingUsers();
        Test.stopTest();
        
        
        System.assertEquals(2, actual.missingUsers.size(), 'Incorrect Number of users Returned');
        System.assertEquals('1234', actual.missingUsers[0].id, 'Incorrect Id');
        System.assertEquals('Test Missing User1', actual.missingUsers[0].name, 'Incorrect name');
        System.assertEquals('Test1', actual.missingUsers[0].username, 'Incorrect username');
        System.assertEquals('Test1@test.com', actual.missingUsers[0].email, 'Incorrect email');
        System.assertEquals('Johns Group', actual.missingUsers[0].company, 'Incorrect company');
        System.assertEquals(true, actual.missingUsers[0].premium, 'Incorrect premium');
        System.assertEquals(true, actual.missingUsers[1].premium, 'Incorrect premium');
    }
    
    @isTest
    static void getExternalUsersApiError(){
        String response = '[{"id":1234, "name": "Test Missing User1", "username": "Test1", "email": "Test1@test.com", "company": {"name": "Test 1 Company"}},'+
            				'{"id":4567, "name": "Test Missing User2", "username": "Test2", "email": "Test2@test.com", "company": {"name": "Test 2 Company"}}]';
        
        MissingWebUserListCtrlTests mock = new MissingWebUserListCtrlTests(404, response);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        MissingWebUserListCtrl.MissingUserWrapper actual = MissingWebUserListCtrl.getMissingUsers();
        Test.stopTest();
        
        
        System.assertEquals(0, actual.missingUsers.size(), 'Incorrect Number of users Returned');
    }
    
    @isTest
    static void insertMissingUsers(){
        String response = '[{"id":"1234", "name": "Test Missing User1", "username": "Test1", "email": "Test1@test.com", "company": {"name": "Johns Group"}}]';
        
        MissingWebUserListCtrlTests mock = new MissingWebUserListCtrlTests(200, response);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        MissingWebUserListCtrl.MissingUserWrapper externalUsers = MissingWebUserListCtrl.getMissingUsers();
        
        String jsonString = JSON.serialize(externalUsers.missingUsers);
        String webUsersInsertStatus = MissingWebUserListCtrl.insertMissingUsers(jsonString);
        Test.stopTest();
        
        List<Web_User__c> webUsers = [SELECT Id, IsPremium__c, Name FROM Web_User__c];
        
       System.assertEquals(1, webUsers.size(), 'Incorrect Number of Web Users Inserted');
       System.assertEquals(true, webUsers[0].IsPremium__c, 'Incorrect premium');
       System.assertEquals('Missing Web Users Inserted Successfully', webUsersInsertStatus, 'Incorrect Status');
    }
    
     @isTest
    static void externalUserAlreadyExistsWithSameWebSiteId(){
         String response = '[{"id":1234, "name": "Test Missing User1", "username": "Test1", "email": "Test1@test.com", "company": {"name": "Test 1 Company"}},'+
            				'{"id":4567, "name": "Test Missing User2", "username": "Test2", "email": "Test2@test.com", "company": {"name": "Test 2 Company"}},'+
             				'{"id":7890, "name": "Test Missing User2", "username": "Test2", "email": "Test2@test.com", "company": {"name": "Test 2 Company"}}]';
        
        MissingWebUserListCtrlTests mock = new MissingWebUserListCtrlTests(200, response);
        Test.setMock(HttpCalloutMock.class, mock);
        
		insertWebUser();        
        
        Test.startTest();
        MissingWebUserListCtrl.MissingUserWrapper externalUsers = MissingWebUserListCtrl.getMissingUsers();
        String webUsersInsertionStatus = MissingWebUserListCtrl.insertMissingUsers(JSON.serialize(externalUsers.missingUsers));
        Test.stopTest();
        
        List<Web_User__c> webUsers = [SELECT Id, Name FROM Web_User__c];
        
       System.assertEquals(1, webUsers.size(), 'Incorrect Number of Web Users Inserted');
        System.assertEquals(false, webUsers[0].IsPremium__c, 'Incorrect premium');
       System.assertEquals('User Already Exists with same webbsite Id : Test Name, ', webUsersInsertionStatus, 'Incorrect Status');
    }
    
    public static void insertWebUser(){
        Web_User__c webUser = new Web_User__c();
        webUser.Name = 'Test Name';
        webUser.Username__c = 'Test userName';
        webUser.Email__c = 'TestEmail@test.com';
        webUser.Company__c = 'Test Company';
        webUser.Web_Site_Id__c = '1234';
        insert webUser;
    }
    
    public Integer statusCode {get; private set;}
    public String responseBody {get; private set;}
    
    public MissingWebUserListCtrlTests(Integer statusCode, String response){
        this.statusCode = statusCode;
        this.responseBody = response;
    }
    
     global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody(responseBody);
        return response;
    }
}