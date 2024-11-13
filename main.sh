#!/bin/bash

APP_NAME="kusho"

# machine id
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/.config/$APP_NAME"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    CONFIG_DIR="$APPDATA/$APP_NAME"
else
    echo "Unsupported OS"
    exit 1
fi


UUID_FILE="$CONFIG_DIR/saved_uuid.txt"
TEST_FILE="$CONFIG_DIR/tests.json"
: > "$TEST_FILE"
mkdir -p "$CONFIG_DIR"

if [[ -f "$UUID_FILE" ]]; then
    saved_uuid=$(cat "$UUID_FILE")
else
    new_uuid=$(uuidgen)
    saved_uuid="$new_uuid"
    echo "$new_uuid" > "$UUID_FILE"
fi


# Collect API details from user input
read -r -p "Enter the test suite name (optional): " test_suite_name
test_suite_name=${test_suite_name:-""}

read -r -p "Enter the HTTP method (e.g., GET, POST): " method
method=${method:-"GET"}

read -r -p "Enter the API URL: " url
url=${url:-"https://example.com"}

read -r -p "Enter a description for this API (optional): " api_desc
api_desc=${api_desc:-""}

read -r -p "Enter headers as a JSON string (e.g., {\"Content-Type\":\"application/json\"}): " headers
headers=${headers:-"{}"}

read -r -p "Enter path parameters as a JSON string (e.g., {\"id\":\"123\"}): " path_params
path_params=${path_params:-"{}"}

read -r -p "Enter query parameters as a JSON string (e.g., {\"key\":\"value\"}): " query_params
query_params=${query_params:-"{}"}

read -r -p "Enter JSON body (e.g., {\"data\":\"value\"}): " json_body
json_body=${json_body:-"{}"}


# Generate tests (API Call)
api_info=$(cat <<EOF
{
    "method": "$method",
    "url": "$url",
    "api_desc": "$api_desc",
    "headers": $headers,
    "path_params": $path_params,
    "query_params": $query_params,
    "json_body": $json_body
}
EOF
)


json_payload=$(cat <<EOF
{
    "machine_id": "$saved_uuid",
    "api_info": $api_info,
    "test_suite_name": "$test_suite_name"
}
EOF
)

test_cases=()
clear
curl -X POST "https://be.kusho.ai/vscode/generate/streaming" \
     -H "Content-Type: application/json" \
     -H "X-KUSHO-SOURCE: npm" \
     -d "$json_payload" --no-buffer | while read -r line; do
    
    if [[ "$line" == "[DONE]" ]]; then
        echo "Generation completed."
        break
    fi

    if [[ "$line" == *"event:limit_error\ndata:"* ]]; then
        echo "Error: You have reached the limit of 5 test suites. Please use the KushoAI web app for more."
        exit 1
    fi

    if [[ "$line" == "event:test_case" ]]; then
        test_case=""
    elif [[ "$line" == data:* ]]; then
        test_case_json=$(echo "$line" | sed 's/^data://')
        # test_cases+=("$test_case_json")
        echo "$test_case_json" >> "$TEST_FILE"
    fi

    # save all test in file here else it disappears
    # printf "$test_cases" > "$TEST_FILE"
done

#test stuff
# test_cases=$(cat "$TEST_FILE")
while IFS= read -r line; do
    test_cases+=("$line")
done < "$TEST_FILE"

clear
echo "All received test cases:"
for index in "${!test_cases[@]}"; do
    echo "Test Case $index: ${test_cases[$index]}"
    echo
done

extract_value() {
    echo "$1" | sed -n "s/.*\"$2\": *\"\([^\"]*\)\".*/\1/p"
}

# Display menu options in a loop
while true; do
    echo "Select an option:"
    echo "1. List all test cases"
    echo "2. Execute all test cases"
    echo "3. Run a specific test case"
    echo "4. Exit"
    read -r -p "Enter your choice (1, 2, 3 or 4): " choice

    case "$choice" in
        1)
            echo "Listing all test cases:"
            for i in "${!test_cases[@]}"; do
                echo "Test Case $((i+1)):"
                echo "${test_cases[$i]}"
                echo "--------------------"
            done
            ;;
        2)
            echo "Executing all test cases..."
            for test_case in "${test_cases[@]}"; do
                method=$(extract_value "$test_case" "method")
                url=$(extract_value "$test_case" "url")
                headers=$(extract_value "$test_case" "headers")
                path_params=$(extract_value "$test_case" "path_params")
                query_params=$(extract_value "$test_case" "query_params")
                json_body=$(extract_value "$test_case" "json_body")

                if [[ -n "$path_params" && "$path_params" != "{}" ]]; then
                    for key in $(echo "$path_params" | jq -r 'keys[]'); do
                        value=$(echo "$path_params" | jq -r --arg key "$key" '.[$key]')
                        url=${url//\{$key\}/$value}
                    done
                fi

                query_string=""
                if [[ -n "$query_params" && "$query_params" != "{}" ]]; then
                    query_string=$(echo "$query_params" | jq -r 'to_entries | map("\(.key)=\(.value | @uri)") | join("&")')
                    url="$url?$query_string"
                fi

                curl_headers=""
                if [[ -n "$headers" && "$headers" != "{}" ]]; then
                    for key in $(echo "$headers" | jq -r 'keys[]'); do
                        value=$(echo "$headers" | jq -r --arg key "$key" '.[$key]')
                        curl_headers+=" -H \"$key: $value\""
                    done
                fi

                echo -e "\nExecuting test case $test_index: $test_case"
                echo ""
                curl -X "$method" "$url" $curl_headers -H "Content-Type: application/json" -d "$json_body"
                echo ""
                
                json_payload=$(cat <<EOF
                {
                "name": "npm_run",
                "machine_id": "$saved_uuid"
                }
                EOF
                )

                curl -s -X POST "https://be.kusho.ai/events/log/public" \
                    -H "Content-Type: application/json" \
                    -d "$json_payload" > /dev/null
            done
            ;;
        3)
            read -r -p "Enter the test case number to execute (1-${#test_cases[@]}): " test_index
            if ((test_index >= 1 && test_index <= ${#test_cases[@]})); then
                i=$((test_index - 1))
                test_case="${test_cases[$i]}"
                
                method=$(extract_value "$test_case" "method")
                url=$(extract_value "$test_case" "url")
                headers=$(extract_value "$test_case" "headers")
                path_params=$(extract_value "$test_case" "path_params")
                query_params=$(extract_value "$test_case" "query_params")
                json_body=$(extract_value "$test_case" "json_body")

                # Replace placeholders in URL with path parameters if any
                if [[ -n "$path_params" && "$path_params" != "{}" ]]; then
                    for key in $(echo "$path_params" | jq -r 'keys[]'); do
                        value=$(echo "$path_params" | jq -r --arg key "$key" '.[$key]')
                        url=${url//\{$key\}/$value}
                    done
                fi

                # Build query parameters if any
                query_string=""
                if [[ -n "$query_params" && "$query_params" != "{}" ]]; then
                    query_string=$(echo "$query_params" | jq -r 'to_entries | map("\(.key)=\(.value | @uri)") | join("&")')
                    url="$url?$query_string"
                fi

                # Add headers to the curl command
                curl_headers=""
                if [[ -n "$headers" && "$headers" != "{}" ]]; then
                    for key in $(echo "$headers" | jq -r 'keys[]'); do
                        value=$(echo "$headers" | jq -r --arg key "$key" '.[$key]')
                        curl_headers+=" -H \"$key: $value\""
                    done
                fi

                echo -e "\nExecuting test case $test_index: $test_case"
                echo ""
                curl -X "$method" "$url" $curl_headers -H "Content-Type: application/json" -d "$json_body"
                echo ""
            else
                echo "Invalid test case number. Please enter a number between 1 and ${#test_cases[@]}."
            fi
            ;;
        4)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
    echo
done
