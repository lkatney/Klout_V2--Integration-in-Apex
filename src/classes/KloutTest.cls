@isTest
private class KloutTest {
	
	@isTest static void testKloutIntegration() {
		// Implement test code
		setupData();

		//set mutimock responses


		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		multimock.setStaticResource('http://test-integration@XXXX.com/identity.json/twitter?screenName=salesforce&key=XXXXXXX-RANDOM-KEY', 'Klout_UserDetails');
		multimock.setStaticResource('http://test-integration@XXXX.com/user.json/296386/score?key=XXXXXXX-RANDOM-KEY', 'Klout_UserScore');
		multimock.setStaticResource('http://test-integration@XXXX.com/user.json/296386/topics?key=XXXXXXX-RANDOM-KEY', 'Klout_UserTopics');
		multimock.setStaticResource('http://test-integration@XXXX.com/user.json/296386/influence?key=XXXXXXX-RANDOM-KEY', 'Klout_Userinfluence');
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');

		// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);

		Test.startTest();
			//Test salesforce twitterUsername
			Klout.getEverything('salesforce');
		Test.stopTest();


	}


	private static void setupData(){

		//insert Custom seeting values to be used
		Klout_Setup__c setup 	= new Klout_Setup__c();
		setup.Name 				= 'Setup';
		setup.API_KEY__c    	= 'XXXXXXX-RANDOM-KEY';
		setup.URI__c 			= 'http://test-integration@XXXX.com/';
		insert setup;
		system.debug('####'+setup);
	}
	
}