import { LightningElement, track, wire } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import generatePkceData from "@salesforce/apex/SFAuthenticationManager.generatePkceData";
import generateAuthorizationUrlWithPkce from "@salesforce/apex/SFAuthenticationManager.generateAuthorizationUrlWithPkce";
import exchangeCodeForTokenWithPkce from "@salesforce/apex/SFAuthenticationManager.exchangeCodeForTokenWithPkce";
import getLimits from "@salesforce/apex/SFExternalCalloutWithToken.getLimits";
import createAccount from "@salesforce/apex/SFExternalCalloutWithToken.createAccount";

export default class OAuthWebFlow extends NavigationMixin(LightningElement) {
	@track currentStep = 1;
	@track authCode = "";
	@track accessToken = "";
	@track instanceUrl = "";
	@track identity = {};
	@track request = "";
	@track response = "";
	@track accountId = "";
	@track accountCreated = false;
	@track usePkce = false;
	@track pkceData = {};
	@track codeVerifier = "";
	@track activeTab = "step1";
	// Tab navigation mapping
	tabSteps = {
		step1: { prev: null, next: "step2" },
		step2: { prev: "step1", next: "step3" },
		step3: { prev: "step2", next: "step4" },
		step4: { prev: "step3", next: null }
	};

	connectedCallback() {
		// Try to retrieve any stored PKCE data when component initializes
		this.retrievePkceData();
	}

	retrievePkceData() {
		try {
			// Check if we have stored PKCE data in session storage
			const storedPkceData = sessionStorage.getItem("pkceData");
			if (storedPkceData) {
				this.pkceData = JSON.parse(storedPkceData);
				this.usePkce = true;
				this.codeVerifier = this.pkceData.codeVerifier;
				console.log("Retrieved stored PKCE data:", {
					pkceData: this.pkceData,
					usePkce: this.usePkce,
					codeVerifier: this.codeVerifier
				});
				console.log("Retrieved stored PKCE data:", this.pkceData);
				console.log("Retrieved stored PKCE data:", this.codeVerifier);
				console.log("Retrieved stored PKCE data:", this.usePkce);
			}
		} catch (error) {
			console.error("Error retrieving PKCE data from storage:", error);
		}
	}

	@wire(CurrentPageReference)
	getUrlParams(currentPageReference) {
		console.log(currentPageReference);
		if (currentPageReference) {
			this.urlParams = currentPageReference.state;
			console.log(this.urlParams);
			if (this.urlParams.code) {
				this.authCode = this.urlParams.code;
				this.currentStep = 2;
				this.activeTab = "step2";
				console.log(this.authCode);
				// Try to retrieve PKCE data if we got a code
				this.retrievePkceData();
			}
		}
	}

	// Display flags
	get showLoginHost() {
		return this.template.querySelector("lightning-tabset").activeTabValue === "step1";
	}

	get showAccessToken() {
		return this.accessToken !== "";
	}

	get showIdentity() {
		return Object.keys(this.identity).length > 0;
	}

	get hasResponse() {
		return this.request !== "" || this.response !== "";
	}

	get formattedIdentity() {
		return JSON.stringify(this.identity, null, 2);
	}

	// Set active tab using the recommended approach
	setActiveTab(tabValue) {
		const tabset = this.template.querySelector("lightning-tabset");
		if (tabset) {
			tabset.activeTabValue = tabValue;
		}
	}

	// Navigation handlers
	handleNextTab(event) {
		const currentTab = event.target.dataset.currentTab;
		const nextTab = this.tabSteps[currentTab].next;

		if (nextTab) {
			this.setActiveTab(nextTab);
			// Update current step based on tab
			this.currentStep = parseInt(nextTab.replace("step", ""));
		}
	}

	handlePreviousTab(event) {
		const currentTab = event.target.dataset.currentTab;
		const prevTab = this.tabSteps[currentTab].prev;

		if (prevTab) {
			this.setActiveTab(prevTab);
			// Update current step based on tab
			this.currentStep = parseInt(prevTab.replace("step", ""));
		}
	}

	// Event handlers
	handleTabChange(event) {
		// We'll keep this to handle user tab changes
		// No need to manually set activeTabValue as the component handles it
	}

	handleAuthCodeChange(event) {
		this.authCode = event.target.value;
	}

	handleUsePkceChange(event) {
		this.usePkce = event.target.checked;

		// Clear stored PKCE data if PKCE is disabled
		if (!this.usePkce) {
			sessionStorage.removeItem("pkceData");
			this.pkceData = {};
		}
	}

	async generatePkce() {
		try {
			this.request = `Calling SFAuthenticationManager.generatePkceData`;
			this.response = "Generating PKCE code verifier and challenge...";

			const result = await generatePkceData();

			if (result.isSuccess) {
				console.log("PKCE Data:", result);
				this.pkceData = {
					codeVerifier: result.codeVerifier,
					codeChallenge: result.codeChallenge,
					codeChallengeMethod: result.codeChallengeMethod
				};

				// Store PKCE data in session storage to persist across navigation
				sessionStorage.setItem("pkceData", JSON.stringify(this.pkceData));

				this.codeVerifier = result.codeVerifier;

				this.response = `PKCE data generated successfully:\nCode challenge: ${result.codeChallenge}\nCode challenge method: ${result.codeChallengeMethod}`;
				return this.pkceData;
			} else {
				throw new Error(result.errorMessage || "PKCE generation failed");
			}
		} catch (error) {
			console.error("Error generating PKCE:", error);
			this.response = `Error generating PKCE: ${error.message || "Unknown error"}`;
			throw error;
		}
	}

	async handleAuthorize() {
		try {
			let codeChallenge = "";
			let codeChallengeMethod = "";

			// If PKCE is enabled, generate the code challenge
			if (this.usePkce) {
				try {
					const pkceData = await this.generatePkce();
					codeChallenge = pkceData.codeChallenge;
					codeChallengeMethod = pkceData.codeChallengeMethod;
				} catch (error) {
					// Error already handled in generatePkce
					return;
				}
			}

			// Get authorization URL from Apex
			const authUrl = await generateAuthorizationUrlWithPkce({
				usePkce: this.usePkce,
				codeChallenge: codeChallenge,
				codeChallengeMethod: codeChallengeMethod
			});

			// Navigate to authorization URL
			const navRef = {
				type: "standard__webPage",
				attributes: {
					url: authUrl
				}
			};

			this.request = "GET " + navRef.attributes.url;
			this.response = "HTTP/1.1 302 Found\nLocation: " + navRef.attributes.url;

			this[NavigationMixin.Navigate](navRef);
		} catch (error) {
			console.error("Error during authorization:", error);
			this.response = `Error during authorization: ${error.message || "Unknown error"}`;
		}
	}

	async handleExchangeCode() {
		// Show loading state (optional)
		this.response = "Exchanging authorization code...";

		console.log("PKCE Data:", this.pkceData);
		console.log("Use PKCE:", this.usePkce);
		console.log("codeVerifier:", this.codeVerifier);

		// Update request display
		const requestParams = {
			code: this.authCode
		};

		if (this.usePkce && this.codeVerifier) {
			requestParams.codeVerifier = this.codeVerifier;
			console.log("Using code verifier for PKCE:", this.codeVerifier);
		}

		this.request = `Calling SFAuthenticationManager.exchangeCodeForTokenWithPkce with:\n${JSON.stringify(requestParams, null, 2)}`;

		try {
			// Call the Apex method using the imperative pattern
			const result = await exchangeCodeForTokenWithPkce(requestParams);

			if (result.isSuccess) {
				// Store the tokens
				this.accessToken = result.accessToken;
				this.instanceUrl = result.instanceUrl;

				// Update response display
				this.response = "Successfully exchanged authorization code for access token";

				// Move to next step
				this.currentStep = 3;
				this.setActiveTab("step3");

				// Clear PKCE data after successful exchange
				sessionStorage.removeItem("pkceData");
			} else {
				// Handle error from successful call but failed operation
				this.response = `Error: ${result.errorMessage}`;
			}
		} catch (error) {
			// Handle any unexpected errors or Apex exceptions
			console.error("Error exchanging auth code:", error);
			this.response = `Error: ${error.body?.message || error.message || "Unknown error occurred"}`;
		}
	}

	async handleFetchIdentity() {
		// Show loading state
		this.response = "Fetching identity information...";

		// Update request display
		this.request = `Calling SFExternalCalloutWithToken.getLimits with:\nToken: ${this.accessToken.substring(0, 10)}...\nInstance URL: ${this.instanceUrl}`;

		try {
			// Call the Apex method directly
			const limitsData = await getLimits({
				accessToken: this.accessToken,
				instanceUrl: this.instanceUrl
			});

			console.log("Limits data:", limitsData);

			if (!limitsData.error) {
				// Store the identity information (using limits info as identity for this example)
				this.identity = limitsData;

				// Update response display
				this.response = "Successfully fetched identity information";

				// Move to next step
				this.currentStep = 4;
				this.setActiveTab("step4");
			} else {
				// Handle error
				this.response = `Error: ${limitsData.error}`;
			}
		} catch (error) {
			// Handle any unexpected errors or Apex exceptions
			console.error("Error fetching identity:", error);
			this.response = `Error: ${error.body?.message || error.message || "Unknown error occurred"}`;
		}
	}

	async handleCreateAccount() {
		// Show loading state
		this.response = "Creating account...";
		this.accountCreated = false;

		// Update request display
		this.request = `Calling SFExternalCalloutWithToken.createAccount with:\nToken: ${this.accessToken.substring(0, 10)}...\nInstance URL: ${this.instanceUrl}`;

		try {
			// Call the Apex method directly
			const accountResult = await createAccount({
				accountName: "LWC Created Account",
				accessToken: this.accessToken,
				instanceUrl: this.instanceUrl
			});

			console.log("Account creation result:", accountResult);

			if (accountResult.isSuccess) {
				// Store the account ID
				this.accountId = accountResult.accountId;
				this.accountCreated = true;

				// Update response display
				this.response = `Successfully created account with ID: ${this.accountId}`;
			} else {
				// Handle error
				this.response = `Error: ${accountResult.errorMessage}`;
			}
		} catch (error) {
			// Handle any unexpected errors or Apex exceptions
			console.error("Error creating account:", error);
			this.response = `Error: ${error.body?.message || error.message || "Unknown error occurred"}`;
		}
	}
}
