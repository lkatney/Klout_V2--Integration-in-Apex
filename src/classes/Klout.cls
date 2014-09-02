public class Klout {

	private Static Final String KLOUT_API_KEY;
	private Static Final String KLOUT_URI;


	Static {
		Klout_Setup__c setup = Klout_Setup__c.getInstance('Setup');
		if(setup != null){
			KLOUT_API_KEY 	= setup.API_KEY__c;
			KLOUT_URI		= setup.URI__c;
		}else{
			throw new KloutException('No configuration found in custom settings');		
		}
	}

	/**
		method to get everything about user
	*/
	public static KloutResponse getEverything(String username){

		KloutResponse response = new KloutResponse();

		//1. Get User id by Twitter Username
		KloutUserDetails userDetails = getUserIdByTwitterUserName(username);
		response.userDetails = userDetails;

		//2. Get Users Score
		KloutUserScore scoreDetails = getUserScore(userDetails.id);
		response.scoreDetails = scoreDetails;

		//3. Get User Topics
		KloutUserTopics topicDetails = getUserTopics(userDetails.id);
		response.topicDetails = topicDetails;

		//4. Get User Influence
		KloutUserInfluence influenceDetails = getUserInfluence(userDetails.id);
		response.influenceDetails = influenceDetails;

		return response;
	}

	/**
		Method to get User Details
	*/

	public static KloutUserDetails getUserIdByTwitterUserName(String username){

		KloutUserDetails userDetails;

		if(String.isNotBlank(username)){
			String endpoint = KLOUT_URI + 'identity.json/twitter?screenName='+username+'&key='+KLOUT_API_KEY;
			String userDetailsBody = makeCallout(endpoint,'GET');

			userDetails = (KloutUserDetails)JSON.deserialize(userDetailsBody, KloutUserDetails.class);
			

		}else{
			throw new KloutException('Blank username found');		
		}

		return userDetails;
	}

	/**
		Method to get User's Scores
	*/
	public static KloutUserScore getUserScore(String userId){

		KloutUserScore scoreDetails;

		if(String.isNotBlank(userId)){
			String endpoint = KLOUT_URI + 'user.json/'+userId+'/score?key='+KLOUT_API_KEY;
			String scoreDetailsBody = makeCallout(endpoint,'GET');

			scoreDetails = (KloutUserScore)JSON.deserialize(scoreDetailsBody, KloutUserScore.class);
		}else{
			throw new KloutException('Blank klout userId found');
		}

		return scoreDetails;
	}


	/**
		Method to get User's Topics
	*/
	public static KloutUserTopics getUserTopics(String userId){

		KloutUserTopics topicDetails;

		if(String.isNotBlank(userId)){
			String endpoint = KLOUT_URI + 'user.json/'+userId+'/topics?key='+KLOUT_API_KEY;
			String topicDetailsBody = makeCallout(endpoint,'GET');

			//change response slightly to parse it correctly
			topicDetailsBody = '{ "topics" : ' + topicDetailsBody + '}';
			topicDetails = (KloutUserTopics)JSON.deserialize(topicDetailsBody, KloutUserTopics.class);
		}else{
			throw new KloutException('Blank klout userId found');
		}

		return topicDetails;
	}

	/**
		Method to get User's Influence
	*/
	public static KloutUserInfluence getUserInfluence(String userId){

		KloutUserInfluence influenceDetails;

		if(String.isNotBlank(userId)){
			String endpoint = KLOUT_URI + 'user.json/'+userId+'/influence?key='+KLOUT_API_KEY;
			String influenceDetailsBody = makeCallout(endpoint,'GET');

			influenceDetails = (KloutUserInfluence)JSON.deserialize(influenceDetailsBody, KloutUserInfluence.class);
		}else{
			throw new KloutException('Blank klout userId found');
		}

		return influenceDetails;
	}

	/**
		Generic method to make callouts
	*/
	public static String makeCallout(String endpoint, String method){

		String response;

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod(method);
		Http http = new Http();
		HTTPResponse res = http.send(req);

		if(res.getStatusCode() == 200){
			response = res.getBody();
		}else{

			throw new KloutException('Recieved exception while integrating with Klout');
			system.debug('============= ERROR LOGGED ===============');
			system.debug('Status Code: '+res.getStatusCode());
			system.debug('Status Message: '+ res.getStatus());
			system.debug('Body: '+res.getBody());
			system.debug('===========================================');
		}
		

		return response;
	}

	/**
	***********************************************************************************************
	************************************* RESPONSE CLASSES *******************************************
	*************************************************************************************************
	*/

	public class KloutResponse {
		KloutUserDetails userDetails;
		KloutUserScore scoreDetails;
		KloutUserTopics topicDetails;
		KloutUserInfluence influenceDetails;
	}

	//wrapper class to get user id
	public class KloutUserDetails{
		String id;
		String network;
	}

	//Wrapper classes to get user's score
	public class KloutUserScore{
		Double score;
		ScoreDelta scoreDelta;
		String bucket;
	}

	public class ScoreDelta{
		Double dayChange;
		Double weekChange;
		Double monthChange;
	}


	//Wrapper classes to get user's topics
	public class KloutUserTopics {
		List<Topic> topics;
	}

	public class Topic{
		String id;
		String displayName;
		String name;
		String slug;
		String imageUrl;
		String displayType;
		String topicType;
	}

	//Wrapper Classes to get User's influencers & influencees

	public class KloutUserInfluence{
		List<MyInfluencers> myInfluencers;
		List<MyInfluencers> myInfluencees;
		Integer myInfluencersCount;
		Integer myInfluenceesCount;
	}

	public class MyInfluencers {
		public Entity entity;
	}

	public class Entity {
		public String id;
		public Payload payload;
	}

	public class Payload {
		public String kloutId;
		public String nick;
		public Score score;
		public ScoreDeltas scoreDeltas;
	}

	public class Score {
		public Double score;
		public String bucket;
	}

	public class ScoreDeltas {
		public Double dayChange;
		public Double weekChange;
		public Double monthChange;
	}


	/**
		Custom Exception
	*/

	public class KloutException extends Exception{}
}