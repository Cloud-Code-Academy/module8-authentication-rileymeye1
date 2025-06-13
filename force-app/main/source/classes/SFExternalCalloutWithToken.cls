/**
 * Service class to handle callouts to external Salesforce org using a provided access token
 */
public class SFExternalCalloutWithToken {
	// API endpoints
	private static final String LIMITS_ENDPOINT = '/services/data/v63.0/limits';
	private static final String ACCOUNT_ENDPOINT = '/services/data/v63.0/sobjects/Account';

	/**
	 * Gets the org limits from the external Salesforce org
	 * @param accessToken The OAuth access token to use for authentication
	 * @param instanceUrl The instance URL of the Salesforce org
	 * @return Map containing the limits information
	 */
	@AuraEnabled
	public static Map<String, Object> getLimits(String accessToken, String instanceUrl) {
		if (String.isBlank(accessToken) || String.isBlank(instanceUrl)) {
			return new Map<String, Object>{
				'error' => 'Access token and instance URL are required'
			};
		}

		// Create HTTP request for limits
		HttpRequest req = new HttpRequest();
		req.setEndpoint(instanceUrl + LIMITS_ENDPOINT);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setHeader('Content-Type', 'application/json');

		// Send request
		Http http = new Http();
		HttpResponse res;

		try {
			res = http.send(req);

			if (res.getStatusCode() == 200) {
				Map<String, Object> limitsInfo = (Map<String, Object>) JSON.deserializeUntyped(
					res.getBody()
				);
				return limitsInfo;
			} else {
				System.debug(
					'Error getting limits: ' + res.getStatusCode() + ' ' + res.getStatus()
				);
				System.debug('Response body: ' + res.getBody());
				return new Map<String, Object>{
					'error' => 'Failed to get limits: ' + res.getStatus()
				};
			}
		} catch (Exception e) {
			System.debug('Exception getting limits: ' + e.getMessage());
			return new Map<String, Object>{ 'error' => 'Exception: ' + e.getMessage() };
		}
	}

	/**
	 * Creates an Account in the external Salesforce org
	 * @param accountName Name of the account to create
	 * @param accessToken The OAuth access token to use for authentication
	 * @param instanceUrl The instance URL of the Salesforce org
	 * @return Result object with success/failure information and account ID
	 */
	@AuraEnabled
	public static CreateAccountResult createAccount(
		String accountName,
		String accessToken,
		String instanceUrl
	) {
		if (String.isBlank(accessToken) || String.isBlank(instanceUrl)) {
			CreateAccountResult result = new CreateAccountResult();
			result.isSuccess = false;
			result.errorMessage = 'Access token and instance URL are required';
			return result;
		}

		// Prepare account data
		Map<String, Object> accountData = new Map<String, Object>{
			'Name' => accountName,
			'Description' => 'Created from external org via API',
			'Industry' => 'Technology',
			'Type' => 'Customer'
		};

		// Create HTTP request for account creation
		HttpRequest req = new HttpRequest();
		req.setEndpoint(instanceUrl + ACCOUNT_ENDPOINT);
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setBody(JSON.serialize(accountData));

		// Send request
		Http http = new Http();
		HttpResponse res;

		try {
			res = http.send(req);

			if (res.getStatusCode() == 201) {
				// 201 Created
				Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
					res.getBody()
				);

				CreateAccountResult result = new CreateAccountResult();
				result.isSuccess = true;
				result.accountId = (String) responseData.get('id');
				return result;
			} else {
				System.debug(
					'Error creating account: ' + res.getStatusCode() + ' ' + res.getStatus()
				);
				System.debug('Response body: ' + res.getBody());

				CreateAccountResult result = new CreateAccountResult();
				result.isSuccess = false;
				result.errorMessage =
					'Failed to create account: ' +
					res.getStatus() +
					' - ' +
					res.getBody();
				return result;
			}
		} catch (Exception e) {
			System.debug('Exception creating account: ' + e.getMessage());

			CreateAccountResult result = new CreateAccountResult();
			result.isSuccess = false;
			result.errorMessage = 'Exception: ' + e.getMessage();
			return result;
		}
	}

	/**
	 * Class to encapsulate account creation result
	 */
	public class CreateAccountResult {
		@AuraEnabled
		public Boolean isSuccess;
		@AuraEnabled
		public String accountId;
		@AuraEnabled
		public String errorMessage;
	}
}
