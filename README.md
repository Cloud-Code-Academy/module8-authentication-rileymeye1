# Cloud Code Academy - Integration Developer Program

## Assignment 7: Salesforce Authentication & OAuth Integration

This assignment focuses on implementing secure authentication mechanisms for Salesforce-to-Salesforce integrations using OAuth 2.0 flows, including Web Server Flow and JWT Bearer Token Flow for server-to-server authentication.

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:

- Configure Connected Apps for OAuth authentication flows
- Implement Web Server Flow for user-based authentication
- Set up JWT Bearer Token Flow for server-to-server authentication
- Create and manage self-signed certificates for JWT authentication
- Configure Experience Cloud sites with OAuth components
- Handle secure token management and refresh mechanisms
- Implement proper security configurations for API-only users

## 📋 Assignment Overview

In this assignment, you will be implementing comprehensive authentication mechanisms for Salesforce integrations. You'll work with both user-interactive OAuth flows and server-to-server JWT authentication, ensuring secure and reliable communication between Salesforce orgs.

### Architecture Overview

This assignment uses a **two-org architecture**:

- **Source Org**: Contains your authentication code (`SFAuthenticationManager.cls`) and Experience Cloud site with OAuth components
- **Destination Org**: Contains the Connected App configuration, integration user, and certificate management

**Authentication Flow Direction**: Source Org → Destination Org

- Your **source org** authenticates TO your **destination org**
- The **destination org** acts as the OAuth provider/authorization server
- The **source org** acts as the OAuth client/consumer

Your implementation must:

1. Set up Connected Apps with proper OAuth scopes and security settings in the **destination org**
2. Implement Web Server Flow authentication in **source org's** Experience Cloud
3. Configure JWT Bearer Token Flow with certificate-based authentication (certificates in **destination org**, code in **source org**)
4. Create secure API-only user profiles for integration purposes in the **destination org**
5. Handle token refresh and error scenarios appropriately

## 🔨 Prerequisites

1. Two Salesforce Developer orgs:
    - **Source Org**: Where you'll deploy the authentication code and Experience Cloud site
    - **Destination Org**: Where you'll create the Connected App and integration user
2. Experience Cloud license enabled in **source org** (where the callback page will be created)
3. OpenSSL installed for certificate generation
4. Node.js environment for JWT testing
5. Understanding of OAuth 2.0 authentication flows
6. Basic knowledge of public key cryptography

## ✍️ Assignment Tasks

Your tasks for this assignment include:

### Phase 1: Connected App Configuration

1. Create a Connected App in the **destination org** with proper OAuth settings
2. Configure callback URLs pointing to your **source org's** Experience Cloud site
3. Set up Remote Site Settings in the **source org** for cross-org communication
4. Deploy necessary metadata to both orgs (authentication classes to source, Connected App to destination)

### Phase 2: Integration User Setup

1. Create an Integration User in the **destination org** with "Salesforce API Only System" profile
2. Configure OAuth scopes for API access, identity, and refresh tokens
3. Assign necessary permissions for cross-org data access

### Phase 3: SFAuthenticationManager Implementation

1. **Complete the `SFAuthenticationManager.cls` implementation**:
    - Implement `makeTokenRequest()` method for HTTP OAuth requests
    - Complete `authenticateWithPassword()` for username/password flow
    - Implement `authenticateWithClientCredentials()` for client credentials flow
    - Complete `authenticateWithJWT()` using self-signed certificates in Salesforce
    - Implement `generateAuthorizationUrl()` for Web Server Flow
    - Complete `generatePkceData()` and `generateAuthorizationUrlWithPkce()` for PKCE support
    - Implement `exchangeCodeForToken()` and `exchangeCodeForTokenWithPkce()` for authorization code exchange

### Phase 4: Web Server Flow Implementation

1. Enable Experience Cloud (LWR) in **source org**
2. Deploy OAuth lightning web component (oAuthWebFlow) to the Experience Cloud home page and a new page /callback (LWC components are already provided)
    - This component takes URL parameters and uses them to generate the authorization URL and handle the callback
3. Create and configure the `/callback` page for OAuth redirects in the **source org's** Experience Cloud site
4. Configure public access settings for guest users in the **source org**
5. Grant access to authentication Apex classes for the Experience Cloud site's guest user profile
6. Coonfigure destination org's Connected App to redirect to the /callback page in the source org's Experience Cloud site

### Phase 5: JWT Bearer Token Flow

This phase involves implementing **two different JWT approaches**:

#### 5A: Salesforce-Native JWT (Primary Implementation)

1. Generate self-signed certificates using OpenSSL (Mac/Linux instructions provided)
2. Upload the **public certificate (.crt file)** to **destination org** in Certificate and Key Management
3. Configure the Connected App in **destination org** to use the uploaded certificate
4. Reference the certificate name in your `authenticateWithJWT()` implementation in **source org**
5. Test JWT authentication flow using Salesforce Apex classes

#### 5B: Node.js JWT Demo (Extra Credit)

1. Use the **private key (.key file)** with the Node.js demo for local JWT generation
2. Update the Connected App's certificate when switching between Salesforce and Node.js testing
3. Compare JWT token generation between Salesforce Apex and Node.js implementations

## 🔗 Connected App Configuration

Your Connected App must be created in the **destination org** with the following settings:

### OAuth Settings

- **Callback URL**: `https://{source-org-instance}.my.site.com/callback` (points to your **source org's** Experience Cloud site)
- **OAuth Scopes**:
    - Access the identity URL service (id)
    - Access and manage your data (api)
    - Perform requests on your behalf at any time (refresh_token, offline_access)

### Security Settings

- Enable OAuth introspection
- Configure IP restrictions if required
- Set session timeout policies

### JWT Certificate Configuration

For JWT Bearer Token Flow, you'll need to manage certificates differently for each testing approach:

- **Salesforce Apex JWT**: Upload the **public certificate (.crt)** to the Connected App
- **Node.js JWT Demo**: Upload the **public certificate (.crt)** to the Connected App (same certificate, different usage of private key)

## 🌐 Experience Cloud Configuration

For the Web Server Flow implementation in your **source org**:

1. **Enable Experience Cloud LWR**

    - Navigate to Setup → Experience Management → Sites in your **source org**
    - Create new Experience Cloud site with Lightning Web Runtime (LWR)

2. **Deploy OAuth Component**

    - Deploy the provided OAuth LWC component (`oAuthWebFlow`) to your **source org**
    - Add the component to the Experience Cloud site's home page
    - Configure component properties to point to your **destination org's** Connected App

3. **Create Callback Page**

    - Create `/callback` page in Experience Builder within your **source org's** Experience Cloud site
    - Add callback handling component to process OAuth responses from the **destination org**
    - Ensure the callback URL matches what's configured in your **destination org's** Connected App

4. **Public Access Configuration**
    - Enable "Public Access Enabled" in General Settings for your **source org's** Experience Cloud site
    - Grant Guest User access to `SFAuthenticationManager` and `SFExternalCalloutWithToken` classes in the **source org**

## 🔐 JWT Bearer Token Flow Implementation

This assignment implements **two distinct JWT approaches** that use the same certificate pair but in different ways:

### Certificate Generation (Mac/Linux)

Use the following OpenSSL commands to generate your certificate pair:

```bash
# Generate private key
openssl genrsa -out jwt_private.key 2048

# Generate certificate signing request
openssl req -new -key jwt_private.key -out jwt.csr

# Generate self-signed certificate (valid for 1 year)
openssl x509 -req -days 365 -in jwt.csr -signkey jwt_private.key -out jwt.crt
```

**Note**: For Windows users, you can use Git Bash, WSL, or install OpenSSL for Windows to run these commands.

### Approach 1: Salesforce-Native JWT (Primary Implementation)

This approach uses Salesforce's built-in JWT classes and certificate management:

#### Certificate Setup for Salesforce JWT

1. Upload the **public certificate (`jwt.crt`)** to your **destination org**
2. Navigate to Setup → Certificate and Key Management in **destination org**
3. Create a Certificate record and give it a memorable name (e.g., 'jwtsource')
4. Configure your **destination org's** Connected App to use this certificate
5. Reference this certificate name in your JWT implementation

#### JWT Token Implementation in Salesforce Apex

Complete the `authenticateWithJWT()` method in `SFAuthenticationManager.cls` (deployed to **source org**) using the following pattern:

```apex
Auth.JWT jwt = new Auth.JWT();
jwt.setSub(username);
jwt.setAud('https://login.salesforce.com'); // or your destination org's login URL
jwt.setIss(DEFAULT_CLIENT_ID); // Consumer Key from destination org's Connected App

// Create the object that signs the JWT bearer token
// 'jwtsource' should be the name of your certificate in the destination org
Auth.JWS jws = new Auth.JWS(jwt, 'jwtsource');
String token = jws.getCompactSerialization();
String tokenEndpoint = DEFAULT_LOGIN_URL + '/services/oauth2/token';

Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);

// Get the access token
String accessToken = bearer.getAccessToken();
```

### Approach 2: Node.js JWT Demo (Extra Credit)

This approach uses the **private key directly** with Node.js libraries for JWT generation:

#### Certificate Setup for Node.js JWT

1. Use the **private key (`jwt_private.key`)** file directly in the Node.js application
2. The **same public certificate (`jwt.crt`)** must be uploaded to your **destination org's** Connected App
3. When testing Node.js JWT, ensure the Connected App references the correct certificate

#### Key Differences Between Approaches

| Aspect                  | Salesforce-Native JWT                                 | Node.js JWT Demo                |
| ----------------------- | ----------------------------------------------------- | ------------------------------- |
| **Location**            | Runs in **source org** Apex                           | Runs locally on your machine    |
| **Certificate Usage**   | References certificate by name in **destination org** | Uses private key file directly  |
| **Private Key Storage** | Managed by Salesforce (secure)                        | Local file system               |
| **JWT Library**         | Salesforce Auth.JWT classes                           | Node.js `jsonwebtoken` library  |
| **Token Signing**       | Salesforce handles signing with stored certificate    | Manual signing with private key |
| **Testing**             | Execute Apex methods in Developer Console             | Run `node JWT_DEMO.js`          |

#### Important Note on Certificate Management

When switching between testing approaches, you may need to:

1. Ensure the **same public certificate** is uploaded to your **destination org's** Connected App
2. Verify the certificate name matches what's referenced in your Apex code
3. Update the Connected App's certificate configuration if testing different certificate pairs

## 🧪 Testing Your Implementation

### Manual Apex Testing (No Automated Test Classes)

**Important**: This assignment uses manual testing with System.debug statements rather than automated test classes. You'll need to:

1. **Update Configuration Values** in `SFAuthenticationManager.cls` (deployed to **source org**):

    - Replace `DEFAULT_CLIENT_ID` with your **destination org's** Connected App Consumer Key
    - Replace `DEFAULT_CLIENT_SECRET` with your **destination org's** Connected App Consumer Secret
    - Replace `DEFAULT_LOGIN_URL` with your **destination org's** login URL
    - Replace `DEFAULT_REDIRECT_URL` with your **source org's** Experience Cloud callback URL

2. **Test Authentication Flows** using the provided test scripts in `/scripts/apex/`:

    - **Quick Test**: Use `hello.apex` for basic authentication testing
    - **Comprehensive Test**: Use `comprehensive-test.apex` for detailed testing with full error handling
    - **Password Flow**: Execute `SFAuthenticationManager.authenticateWithPassword()` in Developer Console
    - **Client Credentials Flow**: Test `SFAuthenticationManager.authenticateWithClientCredentials()`
    - **JWT Flow**: Execute `SFAuthenticationManager.authenticateWithJWT()` with your **destination org's** integration user
    - **Web Server Flow**: Navigate to your **source org's** Experience Cloud site and test OAuth login
    - **Token Refresh**: Verify that expired tokens are properly refreshed using `refreshToken()`
    - **Integration Testing**: Use `SFExternalCalloutWithToken.cls` methods with your acquired tokens

3. **Use System.debug Statements** to verify:
    - Authentication responses contain valid access tokens
    - Instance URLs are correctly returned
    - External callouts succeed with acquired tokens
    - Error handling works for invalid credentials
    - Token refresh functionality operates correctly

## 🔗 JWT Demo Testing (Extra Credit)

Use the provided Node.js demo to test JWT token generation with local certificates:

1. Navigate to the `node-demo` folder
2. Run `npm install` to install dependencies
3. Place your private key file (`jwt_private.key`) in the `certificates` folder
4. Configure your **destination org's** Consumer Key in `JWT_DEMO.js`
5. Execute `node JWT_DEMO.js` to test local JWT token generation
6. Compare the locally generated tokens with your Salesforce Apex implementation
7. Ensure your **destination org's** Connected App is configured with the same certificate for both approaches

**Extra Credit Requirements**:

- Successfully generate JWT tokens using Node.js with your local private key
- Demonstrate token validation against your **destination org**
- Document any differences between local and Salesforce JWT implementations
- Complete `refreshToken()` method for token refresh flow and test it
- Show how the same certificate pair works for both Salesforce-native and Node.js JWT approaches

## ⚙️ Environment Configuration

### env.json Setup

1. Create `env.json` from the provided `env.json.example` template
2. Use the Salesforce CLI to populate org details:
    ```bash
    sf org display env --json > env.json
    ```
3. Add your Consumer Key and private key information
4. Ensure this file is included in `.gitignore` for security

### Required Environment Variables

- `CONSUMER_KEY`: Connected App Consumer Key
- `PRIVATE_KEY_PATH`: Path to your JWT private key
- `USERNAME`: Integration user username
- `LOGIN_URL`: Salesforce login URL (production or sandbox)

## 🎯 Success Criteria

Your implementation should:

- Successfully authenticate using both Web Server Flow and JWT Bearer Token Flow
- Handle token refresh automatically when tokens expire
- Implement proper error handling for authentication failures
- Maintain secure storage of sensitive authentication data
- Pass all authentication test scenarios
- Follow security best practices for OAuth implementation

## 💡 Tips

- Store sensitive data like private keys and consumer secrets securely
- Use Named Credentials when possible for credential management
- Implement retry logic for network-related authentication failures
- Test with both sandbox and production authentication endpoints
- Monitor API limits when implementing token refresh mechanisms
- Use System.debug statements for troubleshooting authentication flows

## 📚 Resources

- [OAuth Authorization Flows](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_flows.htm)
- [JWT Bearer Token Flow](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [Connected App Configuration](https://help.salesforce.com/s/articleView?id=sf.connected_app_create.htm)
- [Experience Cloud Setup](https://help.salesforce.com/s/articleView?id=sf.networks_getting_started.htm)
- [Apex Auth Class Reference](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_namespace_Auth.htm)
- [Certificate and Key Management](https://help.salesforce.com/s/articleView?id=sf.security_keys_about.htm)

## 🏆 Extra Credit - Optional Challenges

Once you've completed the basic implementation, try these challenges:

1. **Node.js JWT Implementation** - Implement JWT token generation using Node.js with your local private key certificates and demonstrate successful authentication against your Salesforce org
2. Implement PKCE (Proof Key for Code Exchange) for enhanced security
3. Create a refresh token rotation mechanism
4. Add support for SAML SSO integration
5. Implement OAuth device flow for IoT scenarios
6. Create a comprehensive logging system for authentication events
7. Build a token management dashboard using Lightning Web Components

## 🛠️ Existing Implementation Files

The following files are already provided and should not require modifications:

- `SFExternalCalloutWithToken.cls` - Handles authenticated callouts (already implemented)
- OAuth LWC components in `/lwc` folder - Pre-built components for Experience Cloud (already implemented)
- Permission sets for integration users

**Files requiring implementation**:

- `SFAuthenticationManager.cls` - Complete all TODO methods for OAuth flows

## ❓ Support

If you need help:

- Review the OAuth 2.0 and JWT documentation
- Check the Salesforce authentication trailhead modules
- Use the provided Node.js demo for JWT testing
- Verify your Connected App configuration
- Reach out to your instructor for guidance

---

Happy coding! 🚀

_This is part of the Cloud Code Academy Integration Developer certification program._

## Copyright

© 2025 Cloud Code. All rights reserved.

This software is provided under the Cloud Code Developer Kickstart Program License (CCDKPL) Version 1.0.
The software is licensed, not sold, and is intended for personal educational purposes only as part of the Cloud Code Developer Kickstart Program.

See the full license terms in LICENSE.md for more details regarding usage restrictions, ownership, warranties, and limitations of liability.
