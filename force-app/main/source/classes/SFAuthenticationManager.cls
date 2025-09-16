/**
 * Service class to handle OAuth 2.0 authentication with Salesforce
 * STUDENT VERSION - Complete the method implementations
 */
public class SFAuthenticationManager {

	private static final String TOKEN_ENDPOINT = '/services/oauth2/token';
	private static final String AUTHORIZE_ENDPOINT = '/services/oauth2/authorize';
	private static final String PKCE_GENERATOR_ENDPOINT = '/services/oauth2/pkce/generator';

	public static String defaultClientId;
	public static String defaultClientSecret;
	public static String defaultLoginUrl;
	public static String defaultRedirectUrl;

	private static void getDefaultValues(String configLabel) {
		if (String.isBlank(defaultClientId)
			|| String.isBlank(defaultClientSecret)
			|| String.isBlank(defaultLoginUrl)
			|| String.isBlank(defaultRedirectUrl)) {
		
			SF2SF_Configuration__mdt config = [
				SELECT client_id__c, client_secret__c, login_url__c, redirect_url__c
				FROM SF2SF_Configuration__mdt
				WHERE Label = :configLabel
				WITH SYSTEM_MODE
				LIMIT 1
			];
			
			if (String.isBlank(config.client_id__c)
				|| String.isBlank(config.client_secret__c)
				|| String.isBlank(config.login_url__c)
				|| String.isBlank(config.redirect_url__c)
			) {
				NullPointerException ex = new NullPointerException();
				ex.setMessage('SF2SF_Configuration__mdt value not found for label: ' + configLabel + '. Please check your configuration.');
				throw ex;
			}

			defaultClientId = config.client_id__c;
			defaultClientSecret = config.client_secret__c;
			defaultLoginUrl = config.login_url__c;
			defaultRedirectUrl = config.redirect_url__c;
		}
	}


	/**
	 * Central method to make OAuth token requests
	 * @param params Map of parameters to include in the request
	 * @param tokenUrl The full URL to the token endpoint
	 * @return Authentication response with token details or error
	 */
	private static AuthResponse makeTokenRequest(Map<String, String> params, String tokenUrl) {
		AuthResponse authResponse = new AuthResponse();

		try {
			HttpRequest req = new HttpRequest();
			Http http = new Http();
			req.setEndpoint(tokenUrl);
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			req.setHeader('Accept', 'application/json');

			String requestBody = '';
			if (params != null && !params.isEmpty()) {
				List<String> paramList = new List<String>();
				for (String key : params.keySet()) {
					String value = params.get(key);
					if (String.isNotBlank(value)) {
							paramList.add(
								EncodingUtil.urlEncode(key, 'UTF-8') + '=' + 
								EncodingUtil.urlEncode(value, 'UTF-8')
							);
					}
				}
				requestBody = String.join(paramList, '&');
			}
			req.setBody(requestBody);

			HttpResponse res = http.send(req);

			if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
				authResponse.isSuccess = true;

				if (String.isBlank(res.getBody())) {
					authResponse.isSuccess = false;
					authResponse.errorMessage = 'Failed to authenticate, Status code: ' + res.getStatusCode() + ' ' + res.getStatus();
					authResponse.errorDetails = res.getBody();
					return authResponse;
				}

				try {
					Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

					authResponse.accessToken = (String) responseMap.get('access_token');
					authResponse.refreshToken = (String) responseMap.get('refresh_token');
					authResponse.instanceUrl = (String) responseMap.get('instance_url');
					authResponse.tokenType = (String) responseMap.get('token_type');
					authResponse.expiresIn = (Integer) responseMap.get('expires_in');
					
				} catch (Exception parseEx) {
					authResponse.isSuccess = false;
					authResponse.errorMessage = 'Response received, but could not parse JSON.';
					authResponse.errorDetails = parseEx.getMessage();
				}
			}
		} catch (CalloutException calloutEx) {
			// Network/timeout errors
			authResponse.isSuccess = false;
			authResponse.errorMessage = 'Network or timeout error occurred';
			authResponse.errorDetails = calloutEx.getMessage();
		} catch (Exception ex) {
			// Any other unexpected errors
			authResponse.isSuccess = false;
			authResponse.errorMessage = 'Unexpected error occurred';
			authResponse.errorDetails = ex.getMessage();
		}

		return authResponse;
	}

	/**
	 * Authenticate using username and password flow (grant_type=password)
	 * @param username Username for the org
	 * @param password Password + Security Token
	 * @param securityToken Security Token
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithPassword(String username, String password, String securityToken) {
		getDefaultValues('destination');
		
		if (String.isBlank(username)
			|| String.isBlank(password)
			|| String.isBlank(securityToken)
		){
				AuthResponse authResponse = new AuthResponse();
				authResponse.isSuccess = false;
				authResponse.errorMessage = 'Missing required parameters';
				authResponse.errorDetails = 'Username: ' + username + ', Password: ' + password + ', Security Token: ' + securityToken;
				return authResponse;
		}

		Map<String, String> params = new Map<String, String>{
			'grant_type' => 'password',
			'client_id' => defaultClientId,
			'client_secret' => defaultClientSecret,
			'username' => username,
			'password' => password + securityToken
		};
		string tokenUrl = defaultLoginUrl + TOKEN_ENDPOINT;

		return makeTokenRequest(params, tokenUrl);
	}

	/**
	 * Authenticate using client credentials flow (grant_type=client_credentials)
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithClientCredentials() {
		getDefaultValues('destination');
		
		Map<String, String> params = new Map<String, String>{
			'grant_type' => 'client_credentials',
			'client_id' => defaultClientId,
			'client_secret' => defaultClientSecret
		};
		string tokenUrl = defaultLoginUrl + TOKEN_ENDPOINT;
		
		return makeTokenRequest(params, tokenUrl);
	}

	/**
	 * JWT Bearer Token Flow authentication
	 * @param username Username for the org
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithJWT(String username) {
		getDefaultValues('destination');

		Auth.JWT jwt = new Auth.JWT();
		jwt.setSub(username);
		jwt.setAud('https://login.salesforce.com');
		jwt.setIss(defaultClientId);

		Auth.JWS jws = new Auth.JWS(jwt, 'jwtdemo');
		// Assignment said to retrieve this, but we never use it so I'm commenting it out, but here is how it would be done:
		// String token = jws.getCompactSerialization();
		String tokenEndpoint = defaultLoginUrl + TOKEN_ENDPOINT;
		Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
		String accessToken = bearer.getAccessToken();

		AuthResponse authResponse = new AuthResponse();
		if (String.isBlank(accessToken)) {
			authResponse.isSuccess = false;
			authResponse.errorMessage = 'Failed to retrieve access token using JWT';
		} else {
			authResponse.isSuccess = true;
			authResponse.accessToken = accessToken;
			authResponse.instanceUrl = defaultLoginUrl;
		}
		return authResponse;
	}

	/**
	 * Generate the authorization URL for Web Server Flow
	 * @param state Optional state parameter for CSRF protection
	 * @return Full authorization URL
	 */
	@AuraEnabled
	public static String generateAuthorizationUrl(String state) {
		getDefaultValues('destination');

		String authorizationUrl = defaultLoginUrl + AUTHORIZE_ENDPOINT;
		authorizationUrl += '?client_id=' + EncodingUtil.urlEncode(defaultClientId, 'UTF-8');
		authorizationUrl += '&redirect_uri=' + EncodingUtil.urlEncode(defaultRedirectUrl, 'UTF-8');
		authorizationUrl += '&response_type=code';

		// 'state' is an optional parameter so only add if provided
		if (String.isNotBlank(state)) {
			authorizationUrl += '&state=' + EncodingUtil.urlEncode(state, 'UTF-8');
		}

		return authorizationUrl;
	}

	/**
	 * Generate PKCE data for OAuth 2.0 authorization
	 * @return PkceResponse containing code verifier and challenge
	 */
	@AuraEnabled
	public static PkceResponse generatePkceData() {
		getDefaultValues('destination');

		PkceResponse pkceResponse = new PkceResponse();
		
		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint(defaultLoginUrl + PKCE_GENERATOR_ENDPOINT);
			req.setMethod('GET');
			req.setHeader('Content-Type', 'application/json');
			Http http = new Http();
			HttpResponse res = http.send(req);

			if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
				pkceResponse.isSuccess = true;

				if (String.isBlank(res.getBody())) {
					pkceResponse.isSuccess = false;
					pkceResponse.errorMessage = 'Failed to generate PKCE data, Status code: ' + res.getStatusCode() + ' ' + res.getStatus();
					pkceResponse.errorDetails = res.getBody();
					return pkceResponse;
				}

				try {
					Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
					
					pkceResponse.codeVerifier = (String) responseMap.get('code_verifier');
					pkceResponse.codeChallenge = (String) responseMap.get('code_challenge');
					pkceResponse.codeChallengeMethod = (String) responseMap.get('code_challenge_method');

				} catch (Exception parseEx) {
					pkceResponse.isSuccess = false;
					pkceResponse.errorMessage = 'Response received, but could not parse JSON.';
					pkceResponse.errorDetails = parseEx.getMessage();
				}
			}
		} catch (CalloutException calloutEx) {
			// Network/timeout errors
			pkceResponse.isSuccess = false;
			pkceResponse.errorMessage = 'Network or timeout error occurred';
			pkceResponse.errorDetails = calloutEx.getMessage();
		} catch (Exception ex) {
			// Any other unexpected errors
			pkceResponse.isSuccess = false;
			pkceResponse.errorMessage = 'Unexpected error occurred';
			pkceResponse.errorDetails = ex.getMessage();
		}

		return pkceResponse;
	}

	/**
	 * Generate authorization URL with PKCE support
	 * @param usePkce Whether to include PKCE parameters
	 * @param codeChallenge Code challenge from PKCE generation
	 * @param codeChallengeMethod Code challenge method from PKCE generation
	 * @return Full authorization URL with PKCE parameters if requested
	 */
	@AuraEnabled
	public static String generateAuthorizationUrlWithPkce(Boolean usePkce, String codeChallenge, String codeChallengeMethod) {
		getDefaultValues('destination');

		String authorizationUrl = defaultLoginUrl + AUTHORIZE_ENDPOINT;
		authorizationUrl += '?client_id=' + EncodingUtil.urlEncode(defaultClientId, 'UTF-8');
		authorizationUrl += '&redirect_uri=' + EncodingUtil.urlEncode(defaultRedirectUrl, 'UTF-8');
		authorizationUrl += '&response_type=code';

		if (usePkce && String.isNotBlank(codeChallenge) && String.isNotBlank(codeChallengeMethod)) {
			authorizationUrl += '&code_challenge=' + EncodingUtil.urlEncode(codeChallenge, 'UTF-8');
			authorizationUrl += '&code_challenge_method=' + EncodingUtil.urlEncode(codeChallengeMethod, 'UTF-8');
		}

		return authorizationUrl;
	}

	/**
	 * Exchange authorization code for access token (grant_type=authorization_code)
	 * @param code Authorization code received from the redirect
	 * @return Authentication response with token details or error
	 */
	@AuraEnabled
	public static AuthResponse exchangeCodeForToken(String code) {
		getDefaultValues('destination');
		
		Map<String, String> params = new Map<String, String>{
			'grant_type' => 'authorization_code',
			'code' => code,
			'client_id' => defaultClientId,
			'client_secret' => defaultClientSecret,
			'redirect_uri' => defaultRedirectUrl
		};
		String tokenUrl = defaultLoginUrl + TOKEN_ENDPOINT;

		return makeTokenRequest(params, tokenUrl);
	}

	/**
	 * Exchange authorization code for access token with PKCE support
	 * @param code Authorization code received from the redirect
	 * @param codeVerifier Code verifier for PKCE
	 * @return Authentication response with token details or error
	 */
	@AuraEnabled
	public static AuthResponse exchangeCodeForTokenWithPkce(String code, String codeVerifier) {
		getDefaultValues('destination');

		Map<String, String> params = new Map<String, String>{
			'grant_type' => 'authorization_code',
			'code' => code,
			'client_id' => defaultClientId,
			'client_secret' => defaultClientSecret,
			'redirect_uri' => defaultRedirectUrl
		};
		
		if (String.isNotBlank(codeVerifier)) {
			params.put('code_verifier', codeVerifier);
		}
		String tokenUrl = defaultLoginUrl + TOKEN_ENDPOINT;

		return makeTokenRequest(params, tokenUrl);
	}

	/**
	 * Refresh an existing access token using a refresh token
	 * Extra Credit: Implement this method
	 * @param refreshToken The refresh token from a previous authentication
	 * @return Authentication response with new token details or error
	 */
	public static AuthResponse refreshToken(String refreshToken) {
		getDefaultValues('destination');
		
		Map<String, String> params = new Map<String, String>{
			'grant_type' => 'refresh_token',
			'refresh_token' => refreshToken,
			'client_id' => defaultClientId,
			'client_secret' => defaultClientSecret
		};
		String tokenUrl = defaultLoginUrl + TOKEN_ENDPOINT;

		return makeTokenRequest(params, tokenUrl);
	}

	/**
	 * Class to encapsulate authentication response
	 */
	public class AuthResponse {
		@AuraEnabled
		public Boolean isSuccess;
		@AuraEnabled
		public String accessToken;

		@AuraEnabled
		public String refreshToken;
		@AuraEnabled
		public String instanceUrl;
		@AuraEnabled
		public String tokenType;
		@AuraEnabled
		public Integer expiresIn;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorDetails;
	}

	/**
	 * Class to encapsulate PKCE response
	 */
	public class PkceResponse {
		@AuraEnabled
		public Boolean isSuccess;
		@AuraEnabled
		public String codeVerifier;
		@AuraEnabled
		public String codeChallenge;
		@AuraEnabled
		public String codeChallengeMethod;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorDetails;
	}
}
