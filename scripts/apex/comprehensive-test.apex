/**
 * Comprehensive Manual Testing Script for SFAuthenticationManager
 *
 * INSTRUCTIONS:
 * 1. Update the configuration values in SFAuthenticationManager.cls first:
 *    - DEFAULT_CLIENT_ID: Your Connected App's Consumer Key
 *    - DEFAULT_CLIENT_SECRET: Your Connected App's Consumer Secret
 *    - DEFAULT_LOGIN_URL: Your org's login URL
 *    - DEFAULT_REDIRECT_URL: Your Experience Cloud callback URL
 *
 * 2. Update the values below with your actual credentials
 * 3. Run this script in Developer Console (Execute Anonymous)
 * 4. Review the debug logs for authentication results
 */

// =============================================================================
// UPDATE THESE VALUES WITH YOUR ACTUAL CREDENTIALS
// =============================================================================
String username = 'your-integration-user@yourorg.com';
String password = 'YourPassword123';
String securityToken = 'YourSecurityToken123';

// =============================================================================
// TEST VARIABLES
// =============================================================================
SFAuthenticationManager.AuthResponse authResponse = null;
Map<String, Object> limits = null;
SFExternalCalloutWithToken.CreateAccountResult createAccountResult = null;
String testTimestamp = String.valueOf(DateTime.now().getTime());

System.debug('=================================================================');
System.debug('STARTING COMPREHENSIVE AUTHENTICATION TESTING');
System.debug('Test Timestamp: ' + testTimestamp);
System.debug('=================================================================');

// =============================================================================
// TEST 1: PASSWORD FLOW
// =============================================================================
System.debug('\n--- TEST 1: PASSWORD FLOW ---');
try {
	authResponse = SFAuthenticationManager.authenticateWithPassword(
		username,
		password,
		securityToken
	);

	if (authResponse.isSuccess) {
		System.debug('✓ Password authentication SUCCESSFUL');
		System.debug(
			'Access Token: ' +
			(authResponse.accessToken != null
				? authResponse.accessToken.substring(0, 20) + '...'
				: 'NULL')
		);
		System.debug('Instance URL: ' + authResponse.instanceUrl);
		System.debug('Token Type: ' + authResponse.tokenType);
		System.debug('Expires In: ' + authResponse.expiresIn + ' seconds');

		// Test external callout with password token
		limits = SFExternalCalloutWithToken.getLimits(
			authResponse.accessToken,
			authResponse.instanceUrl
		);
		if (limits.containsKey('error')) {
			System.debug('✗ External callout FAILED: ' + limits.get('error'));
		} else {
			System.debug('✓ External callout SUCCESSFUL - Retrieved org limits');
		}

		// Test account creation with password token
		createAccountResult = SFExternalCalloutWithToken.createAccount(
			'Password Test Account ' + testTimestamp,
			authResponse.accessToken,
			authResponse.instanceUrl
		);

		if (createAccountResult.isSuccess) {
			System.debug(
				'✓ Account creation SUCCESSFUL - Account ID: ' + createAccountResult.accountId
			);
		} else {
			System.debug('✗ Account creation FAILED: ' + createAccountResult.errorMessage);
		}
	} else {
		System.debug('✗ Password authentication FAILED');
		System.debug('Error: ' + authResponse.errorMessage);
		System.debug('Details: ' + authResponse.errorDetails);
	}
} catch (Exception e) {
	System.debug('✗ Password flow EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TEST 2: CLIENT CREDENTIALS FLOW
// =============================================================================
System.debug('\n--- TEST 2: CLIENT CREDENTIALS FLOW ---');
try {
	authResponse = SFAuthenticationManager.authenticateWithClientCredentials();

	if (authResponse.isSuccess) {
		System.debug('✓ Client credentials authentication SUCCESSFUL');
		System.debug(
			'Access Token: ' +
			(authResponse.accessToken != null
				? authResponse.accessToken.substring(0, 20) + '...'
				: 'NULL')
		);
		System.debug('Instance URL: ' + authResponse.instanceUrl);
		System.debug('Token Type: ' + authResponse.tokenType);
		System.debug('Expires In: ' + authResponse.expiresIn + ' seconds');

		// Test external callout with client credentials token
		limits = SFExternalCalloutWithToken.getLimits(
			authResponse.accessToken,
			authResponse.instanceUrl
		);
		if (limits.containsKey('error')) {
			System.debug('✗ External callout FAILED: ' + limits.get('error'));
		} else {
			System.debug('✓ External callout SUCCESSFUL - Retrieved org limits');
		}

		// Test account creation with client credentials token
		createAccountResult = SFExternalCalloutWithToken.createAccount(
			'Client Credentials Test Account ' + testTimestamp,
			authResponse.accessToken,
			authResponse.instanceUrl
		);

		if (createAccountResult.isSuccess) {
			System.debug(
				'✓ Account creation SUCCESSFUL - Account ID: ' + createAccountResult.accountId
			);
		} else {
			System.debug('✗ Account creation FAILED: ' + createAccountResult.errorMessage);
		}
	} else {
		System.debug('✗ Client credentials authentication FAILED');
		System.debug('Error: ' + authResponse.errorMessage);
		System.debug('Details: ' + authResponse.errorDetails);
	}
} catch (Exception e) {
	System.debug('✗ Client credentials flow EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TEST 3: JWT BEARER TOKEN FLOW
// =============================================================================
System.debug('\n--- TEST 3: JWT BEARER TOKEN FLOW ---');
try {
	authResponse = SFAuthenticationManager.authenticateWithJWT(username);

	if (authResponse.isSuccess) {
		System.debug('✓ JWT authentication SUCCESSFUL');
		System.debug(
			'Access Token: ' +
			(authResponse.accessToken != null
				? authResponse.accessToken.substring(0, 20) + '...'
				: 'NULL')
		);
		System.debug('Instance URL: ' + authResponse.instanceUrl);
		System.debug('Token Type: ' + authResponse.tokenType);
		System.debug('Expires In: ' + authResponse.expiresIn + ' seconds');

		// Test external callout with JWT token
		limits = SFExternalCalloutWithToken.getLimits(
			authResponse.accessToken,
			authResponse.instanceUrl
		);
		if (limits.containsKey('error')) {
			System.debug('✗ External callout FAILED: ' + limits.get('error'));
		} else {
			System.debug('✓ External callout SUCCESSFUL - Retrieved org limits');
		}

		// Test account creation with JWT token
		createAccountResult = SFExternalCalloutWithToken.createAccount(
			'JWT Test Account ' + testTimestamp,
			authResponse.accessToken,
			authResponse.instanceUrl
		);

		if (createAccountResult.isSuccess) {
			System.debug(
				'✓ Account creation SUCCESSFUL - Account ID: ' + createAccountResult.accountId
			);
		} else {
			System.debug('✗ Account creation FAILED: ' + createAccountResult.errorMessage);
		}
	} else {
		System.debug('✗ JWT authentication FAILED');
		System.debug('Error: ' + authResponse.errorMessage);
		System.debug('Details: ' + authResponse.errorDetails);
	}
} catch (Exception e) {
	System.debug('✗ JWT flow EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TEST 4: TOKEN REFRESH FLOW (If refresh token available)
// =============================================================================
System.debug('\n--- TEST 4: TOKEN REFRESH FLOW ---');
try {
	// First get a token with refresh capability (password flow usually provides refresh token)
	authResponse = SFAuthenticationManager.authenticateWithPassword(
		username,
		password,
		securityToken
	);

	if (authResponse.isSuccess && authResponse.refreshToken != null) {
		System.debug('✓ Got refresh token: ' + authResponse.refreshToken.substring(0, 20) + '...');

		// Test the refresh token
		SFAuthenticationManager.AuthResponse refreshResponse = SFAuthenticationManager.refreshToken(
			authResponse.refreshToken
		);

		if (refreshResponse.isSuccess) {
			System.debug('✓ Token refresh SUCCESSFUL');
			System.debug(
				'New Access Token: ' +
				(refreshResponse.accessToken != null
					? refreshResponse.accessToken.substring(0, 20) + '...'
					: 'NULL')
			);
			System.debug('New Instance URL: ' + refreshResponse.instanceUrl);

			// Test external callout with refreshed token
			limits = SFExternalCalloutWithToken.getLimits(
				refreshResponse.accessToken,
				refreshResponse.instanceUrl
			);
			if (limits.containsKey('error')) {
				System.debug(
					'✗ External callout with refreshed token FAILED: ' + limits.get('error')
				);
			} else {
				System.debug('✓ External callout with refreshed token SUCCESSFUL');
			}
		} else {
			System.debug('✗ Token refresh FAILED');
			System.debug('Error: ' + refreshResponse.errorMessage);
			System.debug('Details: ' + refreshResponse.errorDetails);
		}
	} else {
		System.debug('✗ No refresh token available for testing refresh flow');
		if (authResponse.refreshToken == null) {
			System.debug('Refresh token is NULL - check Connected App OAuth scopes');
		}
	}
} catch (Exception e) {
	System.debug('✗ Token refresh flow EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TEST 5: PKCE GENERATION (Extra Credit)
// =============================================================================
System.debug('\n--- TEST 5: PKCE GENERATION ---');
try {
	SFAuthenticationManager.PkceResponse pkceResponse = SFAuthenticationManager.generatePkceData();

	if (pkceResponse.isSuccess) {
		System.debug('✓ PKCE generation SUCCESSFUL');
		System.debug(
			'Code Verifier: ' +
			(pkceResponse.codeVerifier != null
				? pkceResponse.codeVerifier.substring(0, 20) + '...'
				: 'NULL')
		);
		System.debug(
			'Code Challenge: ' +
			(pkceResponse.codeChallenge != null
				? pkceResponse.codeChallenge.substring(0, 20) + '...'
				: 'NULL')
		);
		System.debug('Code Challenge Method: ' + pkceResponse.codeChallengeMethod);

		// Test generating authorization URL with PKCE
		String pkceAuthUrl = SFAuthenticationManager.generateAuthorizationUrlWithPkce(
			true,
			pkceResponse.codeChallenge,
			pkceResponse.codeChallengeMethod
		);
		System.debug('PKCE Authorization URL: ' + pkceAuthUrl);
	} else {
		System.debug('✗ PKCE generation FAILED');
		System.debug('Error: ' + pkceResponse.errorMessage);
		System.debug('Details: ' + pkceResponse.errorDetails);
	}
} catch (Exception e) {
	System.debug('✗ PKCE generation EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TEST 6: AUTHORIZATION URL GENERATION
// =============================================================================
System.debug('\n--- TEST 6: AUTHORIZATION URL GENERATION ---');
try {
	String authUrl = SFAuthenticationManager.generateAuthorizationUrl(
		'test-state-' + testTimestamp
	);
	System.debug('Generated Authorization URL: ' + authUrl);

	if (
		authUrl.contains('client_id') &&
		authUrl.contains('redirect_uri') &&
		authUrl.contains('response_type=code')
	) {
		System.debug('✓ Authorization URL contains required parameters');
	} else {
		System.debug('✗ Authorization URL missing required parameters');
	}
} catch (Exception e) {
	System.debug('✗ Authorization URL generation EXCEPTION: ' + e.getMessage());
	System.debug('Stack Trace: ' + e.getStackTraceString());
}

// =============================================================================
// TESTING COMPLETE
// =============================================================================
System.debug('\n=================================================================');
System.debug('COMPREHENSIVE AUTHENTICATION TESTING COMPLETE');
System.debug('Review the debug logs above to verify your implementation');
System.debug('=================================================================');
