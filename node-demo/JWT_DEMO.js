const fs = require("fs");
const jwt = require("jsonwebtoken");
const axios = require("axios");

// CONFIG — UPDATE THESE 👇
const privateKey = fs.readFileSync("../certificates/jwt_private.key");
const consumerKey =
	"3MVG9KsVczVNcM8xcjZ60sf2.iPLZp3P_X9OCbqMDd2oQDl0ipG9u_5aZVq7qY_jEXw0OdmFvUHYtmBLoDXg4";
const username = "warren.salesforce+test@gmail.com"; // this must be a real user in Salesforce
const loginUrl = "https://login.salesforce.com"; // or test.salesforce.com for sandbox

// Replace with a real Account Id from your org
const accountId = "";
// 1. JWT CLAIMS
const payload = {
	iss: consumerKey,
	sub: username,
	aud: loginUrl,
	exp: Math.floor(Date.now() / 1000) + 300 // 5 minutes expiry
};

// 2. SIGN JWT
const token = jwt.sign(payload, privateKey, { algorithm: "RS256" });

// 3. SEND TO SALESFORCE TOKEN ENDPOINT
const params = new URLSearchParams();
params.append("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer");
params.append("assertion", token);

axios
	.post(`${loginUrl}/services/oauth2/token`, params)
	.then((response) => {
		console.log("\n✅ Access Token:", response.data.access_token);

		//  Account record API Call
		return axios.get(
			`${response.data.instance_url}/services/data/v59.0/sobjects/Account/${accountId}`,
			{
				headers: {
					Authorization: `Bearer ${response.data.access_token}`
				}
			}
		);
	})
	.then((res) => {
		console.log("\n✅ Sample API Call Success:\n", res.data);
	})
	.catch((error) => {
		console.error("\n❌ Error:", error.response?.data || error.message);
	});
