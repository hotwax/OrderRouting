# Order Routing

Order routing is a process within the domain of e-commerce, retail, and logistics that involves directing and managing the flow of customer orders from the point of sale to the point of fulfillment. The primary goal of order routing is to optimize the delivery of products or services to customers by determining the most efficient path for order processing and fulfillment.

## Key Components

1. **Routing Rules and Conditions:** Establishing rules and conditions that dictate how orders should be handled based on various factors such as product availability, warehouse locations, shipping methods, and customer preferences.

2. **Inventory Management:** Integrating with inventory systems to ensure that orders are fulfilled from the most appropriate and well-stocked locations, minimizing delays and backorders.

3. **Order Prioritization:** Determining the priority of orders based on factors like customer importance, service level agreements, or order urgency.

4. **Multi-Channel Integration:** Coordinating orders from various sales channels, such as online stores, brick-and-mortar locations, and third-party marketplaces.

5. **Real-Time Decision Making:** Making dynamic decisions during the order fulfillment process, taking into account real-time data on inventory levels, shipping costs, and delivery timelines.

6. **Routing Groups:** Organizing orders into routing groups based on specific criteria, allowing for targeted and efficient handling of similar types of orders.

7. **Automation:** Leveraging automation technologies to streamline the order routing process, reducing manual intervention and improving overall efficiency.

Effective order routing contributes to customer satisfaction by ensuring timely and accurate order delivery, minimizing shipping costs, and optimizing inventory management. It is a critical aspect of modern supply chain and logistics systems, especially in environments where orders are received from multiple channels and fulfilled through various distribution points.


# Login Instructions

This document provides instructions on how to authenticate using the login API and how to use the received credentials for subsequent API calls.

## Logging In

1. **Endpoint**: To log in, make a POST request to the following endpoint: `http://localhost:8080/rest/login`.

2. **Request Format**: The request should be made with the `Content-Type` header set to `application/x-www-form-urlencoded`. The body of the request must include the following parameters:
    - `username`: Your username.
    - `password`: Your password.

   Example using `curl`:
   ```bash
   curl -X POST http://localhost:8080/rest/login \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   -d 'username=YOUR_USERNAME&password=YOUR_PASSWORD'

**Successful Response**: Upon successful authentication, the API will return the following JSON response:

```json
{
  "loggedIn": true
}
```
## Retrieving the CSRF Token and Cookie

- **CSRF Token**: The response will include an `X-CSRF-Token` in the headers. This token is required for making subsequent API calls.
- **Cookie**: The response also sets a session cookie. Ensure that your HTTP client is configured to store and use cookies for subsequent requests.

### Example of extracting the CSRF token using curl

Assuming the use of a tool like `jq` to parse JSON:

```bash
csrf_token=$(curl -c cookie.txt -X POST http://localhost:8080/rest/login \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d 'username=YOUR_USERNAME&password=YOUR_PASSWORD' \
-i | grep 'X-CSRF-Token' | cut -d ' ' -f2)
```

## Making Authenticated API Calls

For all subsequent API calls after login:
- Include the `X-CSRF-Token` in the request headers.
- Ensure that the session cookie received during the login process is included with the request.

### Example using `curl`

```bash
curl -X GET http://localhost:8080/rest/someEndpoint \
-H 'X-CSRF-Token: YOUR_CSRF_TOKEN' \
-b cookie.txt
```
**Note**: Replace `YOUR_USERNAME`, `YOUR_PASSWORD`, and `YOUR_CSRF_TOKEN` with your actual username, password, and CSRF token, respectively. The method of extracting the CSRF token may vary depending on the tools and programming language you are using. The provided examples use common command-line tools.

