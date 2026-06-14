#!/usr/bin/env python3
import argparse
import json
import os
import sys
import requests

# API Configuration
API_URL_GPT = "https://genai.postech.ac.kr/agent/api/a1/gpt"
API_URL_Gemini = "https://genai.postech.ac.kr/agent/api/a2/gemini"
API_URL_Claude = "https://genai.postech.ac.kr/agent/api/a3/claude"

def query_robi_api(message: str, api_key: str, API_URL: str, v2: bool) -> dict:
    if v2:
        headers = {
            "x-api-key": api_key,
            "Authorization": api_key,
            "Content-Type": "application/json"
        }
    else:
        headers = {
            "x-api-key": api_key,
            "Content-Type": "application/json"
        }
        
    payload = {
        "message": message
    }
    
    response = None
    try:
        response = requests.post(API_URL, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"[-] API Request failed: {e}", file=sys.stderr)
        if response is not None and response.text:
            print(f"[-] Server Response: {response.text}", file=sys.stderr)
        sys.exit(1)

def main():
    # Set up terminal argument parsing
    parser = argparse.ArgumentParser(
        description="CLI client for the Robi G LLM API."
    )
    
    # Message positional argument (defaults to '안녕하세요' if not provided)
    parser.add_argument(
        "message", 
        type=str, 
        nargs="?", 
        default="안녕하세요", 
        help="The prompt/message to send to the LLM."
    )
    
    # Optional API Key flag (falls back to ROBI_API_KEY environment variable)
    parser.add_argument(
        "-k", "--api-key", 
        type=str, 
        default=os.environ.get("ROBI_API_KEY"),
        help="Your API key. Alternatively, set the ROBI_API_KEY environment variable."
    )

    # Model Selection flag
    parser.add_argument(
        "-m", "--model",
        type=str,
        choices=["gpt", "gemini", "claude"],
        default="gemini",
        help="Select the LLM provider to query (default: gemini)."
    )

    # New flag to toggle between clean text and raw JSON
    parser.add_argument(
        "--raw",
        action="store_true",
        help="Output the raw JSON payload instead of the cleanly formatted message text."
    )

    args = parser.parse_args()

    # Validate API key presence
    if not args.api_key:
        print(
            "Error: API key is missing.\n"
            "Provide it using the --api-key/-k flag or set the ROBI_API_KEY environment variable.", 
            file=sys.stderr
        )
        sys.exit(1)

    # Map model choice to its respective URL and API version (v2 flag)
    model_routing = {
        "gpt": (API_URL_GPT, False),
        "gemini": (API_URL_Gemini, True),
        "claude": (API_URL_Claude, True)
    }
    
    selected_url, is_v2 = model_routing[args.model]

    # Execute the request
    result = query_robi_api(args.message, args.api_key, selected_url, is_v2)
    
    # Handle Output Formatting
    if args.raw:
        # Prints full raw JSON structure
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        # Extracts and cleanly renders the Markdown string
        if isinstance(result, dict) and "message" in result:
            print(result["message"])
        else:
            # Fallback defensively if the API response structure changes
            print("[!] Warning: 'message' key missing in response. Falling back to raw JSON.", file=sys.stderr)
            print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
