/**
 * Service class to handle OAuth 2.0 authentication with Salesforce
 * STUDENT VERSION - Complete the method implementations
 */
public class SFAuthenticationManager {
	// Endpoint for token requests
	private static final String TOKEN_ENDPOINT = '/services/oauth2/token';
	private static final String AUTHORIZE_ENDPOINT = '/services/oauth2/authorize';
	private static final String PKCE_GENERATOR_ENDPOINT = '/services/oauth2/pkce/generator';

	// Configuration values
	public static final String DEFAULT_CLIENT_ID = 'DUMMY_CLIENT_ID_FOR_STUDENT_LEARNING';
	public static final String DEFAULT_CLIENT_SECRET = 'DUMMY_CLIENT_SECRET_FOR_STUDENT_LEARNING';
	public static final String DEFAULT_LOGIN_URL = 'https://student-org.my.salesforce.com';
	public static final String DEFAULT_REDIRECT_URL = 'https://student-org.my.site.com/callback';

	/**
	 * Central method to make OAuth token requests
	 * TODO: Complete this method implementation
	 * @param params Map of parameters to include in the request
	 * @param tokenUrl The full URL to the token endpoint
	 * @return Authentication response with token details or error
	 */
	private static AuthResponse makeTokenRequest(Map<String, String> params, String tokenUrl) {
		// TODO: Create HTTP request
		// TODO: Set endpoint, method, and headers
		// TODO: Convert parameters to URL encoded string
		// TODO: Set request body
		// TODO: Send the request and handle response
		// TODO: Parse success and error responses

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * Authenticate using username and password flow (grant_type=password)
	 * TODO: Complete this method implementation
	 * @param username Username for the org
	 * @param password Password + Security Token
	 * @param securityToken Security Token
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithPassword(
		String username,
		String password,
		String securityToken
	) {
		// TODO: Prepare parameters map with:
		// - grant_type: 'password'
		// - client_id: DEFAULT_CLIENT_ID
		// - client_secret: DEFAULT_CLIENT_SECRET
		// - username: username
		// - password: password + securityToken

		// TODO: Call makeTokenRequest with params and token URL

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * Authenticate using client credentials flow (grant_type=client_credentials)
	 * TODO: Complete this method implementation
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithClientCredentials() {
		// TODO: Prepare parameters map with:
		// - grant_type: 'client_credentials'
		// - client_id: DEFAULT_CLIENT_ID
		// - client_secret: DEFAULT_CLIENT_SECRET

		// TODO: Call makeTokenRequest with params and token URL

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * JWT Bearer Token Flow authentication
	 * TODO: Complete this method implementation
	 * @param username Username for the org
	 * @return Authentication response with token details or error
	 */
	public static AuthResponse authenticateWithJWT(String username) {
		// TODO: Create JWT using Auth.JWT class
		// TODO: Set sub (username), aud (audience), and iss (client_id)
		// TODO: Create JWS (JSON Web Signature) with the JWT
		// TODO: Get the compact serialization (token string)
		// TODO: Create JWTBearerTokenExchange and get access token

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * Generate the authorization URL for Web Server Flow
	 * TODO: Complete this method implementation
	 * @param state Optional state parameter for CSRF protection
	 * @return Full authorization URL
	 */
	@AuraEnabled
	public static String generateAuthorizationUrl(String state) {
		// TODO: Build authorization URL with:
		// - DEFAULT_LOGIN_URL + AUTHORIZE_ENDPOINT
		// - client_id parameter (URL encoded)
		// - redirect_uri parameter (URL encoded)
		// - response_type=code
		// - state parameter if provided (URL encoded)

		// STUB: Return placeholder URL for now
		return 'URL_NOT_IMPLEMENTED_YET';
	}

	/**
	 * Generate PKCE data for OAuth 2.0 authorization
	 * TODO: Complete this method implementation
	 * @return PkceResponse containing code verifier and challenge
	 */
	@AuraEnabled
	public static PkceResponse generatePkceData() {
		// TODO: Create HTTP request to PKCE generator endpoint
		// TODO: Set method to GET and content-type header
		// TODO: Send request and handle response
		// TODO: Parse response for code_verifier, code_challenge, and code_challenge_method

		// STUB: Return empty response for now
		PkceResponse pkceResponse = new PkceResponse();
		pkceResponse.isSuccess = false;
		pkceResponse.errorMessage = 'Method not implemented yet';
		return pkceResponse;
	}

	/**
	 * Generate authorization URL with PKCE support
	 * TODO: Complete this method implementation
	 * @param usePkce Whether to include PKCE parameters
	 * @param codeChallenge Code challenge from PKCE generation
	 * @param codeChallengeMethod Code challenge method from PKCE generation
	 * @return Full authorization URL with PKCE parameters if requested
	 */
	@AuraEnabled
	public static String generateAuthorizationUrlWithPkce(
		Boolean usePkce,
		String codeChallenge,
		String codeChallengeMethod
	) {
		// TODO: Build base authorization URL like generateAuthorizationUrl
		// TODO: Add PKCE parameters if usePkce is true:
		// - code_challenge (URL encoded)
		// - code_challenge_method (URL encoded)

		// STUB: Return placeholder URL for now
		return 'URL_NOT_IMPLEMENTED_YET';
	}

	/**
	 * Exchange authorization code for access token (grant_type=authorization_code)
	 * TODO: Complete this method implementation
	 * @param code Authorization code received from the redirect
	 * @return Authentication response with token details or error
	 */
	@AuraEnabled
	public static AuthResponse exchangeCodeForToken(String code) {
		// TODO: Prepare parameters map with:
		// - grant_type: 'authorization_code'
		// - code: code
		// - client_id: DEFAULT_CLIENT_ID
		// - client_secret: DEFAULT_CLIENT_SECRET
		// - redirect_uri: DEFAULT_REDIRECT_URL

		// TODO: Call makeTokenRequest with params and token URL

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * Exchange authorization code for access token with PKCE support
	 * TODO: Complete this method implementation
	 * @param code Authorization code received from the redirect
	 * @param codeVerifier Code verifier for PKCE
	 * @return Authentication response with token details or error
	 */
	@AuraEnabled
	public static AuthResponse exchangeCodeForTokenWithPkce(String code, String codeVerifier) {
		// TODO: Prepare parameters map like exchangeCodeForToken
		// TODO: Add code_verifier parameter if provided
		// TODO: Call makeTokenRequest with params and token URL

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
	}

	/**
	 * Refresh an existing access token using a refresh token
	 * Extra Credit: Implement this method
	 * TODO: Complete this method implementation
	 * @param refreshToken The refresh token from a previous authentication
	 * @return Authentication response with new token details or error
	 */
	public static AuthResponse refreshToken(String refreshToken) {
		// TODO: Prepare parameters map with:
		// - grant_type: 'refresh_token'
		// - refresh_token: refreshToken
		// - client_id: DEFAULT_CLIENT_ID
		// - client_secret: DEFAULT_CLIENT_SECRET

		// TODO: Call makeTokenRequest with params and token URL

		// STUB: Return empty response for now
		AuthResponse authResponse = new AuthResponse();
		authResponse.isSuccess = false;
		authResponse.errorMessage = 'Method not implemented yet';
		return authResponse;
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
