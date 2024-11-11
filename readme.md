# kusho-cli

### What is KushoAI?

If you've been woken up at odd hours because your API broke in prod for some trivial reason or you've just gotten bored of testing APIs manually everytime you make a small change, you've come to right place. :smile:

KushoAI is an **AI Agent for API testing** which generates **exhaustive test suites for your APIs in minutes** – all you need to do is input your API information and sit back while KushoAI figures out what real-world scenarios can occur for your API in production and write ready-to-execute tests for them.

`kusho-cli` is a command line tool for using KushoAI which allows you to generate test suites for your APIs directly from CLI. To access our full suite of features, you can use the [KushoAI web application](https://kusho.ai).

### Installation

For local installation
```bash
npm i kusho-cli
```

or you can use this for installing it globally
```bash
npm i kusho-cli -g
```

### Usage

- Invoke `kusho-cli` using this
```bash
npx kusho-cli
```
- You will be prompted to enter details about your API like HTTP method, URL, headers, query/path params, request body.
- Wait while KushoAI generates tests for your API using above entered details. This generally takes 2-3 minutes.
- Once the generation is completed, you'll see the tests displayed as a numbered list. Use the number to run a test like this
```bash
--------------------
Test Case 12:
{"description": "Test with a valid identifier in Roman numeral format for 'query_params.key'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "V"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "f01a9524-14d1-41df-9b9b-dc6a039d0e03", "test_suite_id": 19019}
--------------------
Test Case 13:
{"description": "Test without the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": ""}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "77061233-4e70-40df-9fbd-a5abac5bce85", "test_suite_id": 19019}
--------------------
Test Case 14:
{"description": "Test with an invalid format of Identifier for 'query_params.key'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "invalidFormat"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "c6828701-d441-4560-81bb-55d6395ba6b2", "test_suite_id": 19019}
--------------------
Test Case 15:
{"description": "Test with mixed case characters in the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "mIxEdCaSe"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "cd9c2587-0826-408e-a7e9-65286c627481", "test_suite_id": 19019}
--------------------
Test Case 16:
{"description": "Test with a valid format for the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "validIdentifier"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "a946b37a-f183-432f-89ec-f31203a1cac3", "test_suite_id": 19019}
--------------------
Test Case 17:
{"description": "Test with a negative value for the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": -123}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "06b3c5f0-f7d7-49ee-bed3-3a130a7940d3", "test_suite_id": 19019}
--------------------
Test Case 18:
{"description": "Test with an identifier containing punctuation for the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "punct;uation"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "efb5fb98-da95-487c-8516-3c18d5900072", "test_suite_id": 19019}
--------------------
Test Case 19:
{"description": "Test with an identifier containing emojis for the 'key' identifier field in 'query_params'", "request": {"method": "get", "url": "https://localhost:8080/hello", "api_desc": "", "headers": {}, "path_params": {}, "query_params": {"key": "emojis\ud83d\ude00"}, "json_body": {}}, "categories": ["Other"], "types": ["Business Logic"], "fields": ["query_params.key"], "uuid": "6021f63a-0192-4e2d-9410-c2c56f2b6732", "test_suite_id": 19019}
--------------------

Select an option:
1. List all test cases
2. Execute all test cases
3. Run a specific test case
4. Exit

> 3 17
```
- Alternatively, you can run all tests using option 2   


For a detailed product walkthrough of the KushoAI web application, you can watch the video [here](https://www.youtube.com/watch?v=4z4pI5N0_7o).

<br>

> NOTE: This CLI version of KushoAI has limited features at the moment. For our full suite of features, you can use the [KushoAI web application](https://kusho.ai). 
