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
#Adapted from https://github.com/Haayhur/postech-anthropic-proxy (..because reading codes is eaiser than reading official docs, you know).
API_URL_Claude_A45 = "https://genai.postech.ac.kr/agent/api/a45/anthropic/messages"

def query_robi_api(message: str, api_key: str, API_URL: str, api_format: str) -> dict:
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    
    # Configure payload and headers based on the endpoint's expected format
    if api_format == "v2":
        headers["Authorization"] = api_key
        payload = {"message": message}
    elif api_format == "v1":
        payload = {"message": message}
    elif api_format == "anthropic-a45":
        payload = {
            "model": "claude-sonnet-4-6", 
            "max_tokens": 4096,
            "messages": [
                {"role": "user", "content": message}
            ]
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
    parser = argparse.ArgumentParser(
        description="CLI client for the Robi G LLM API."
    )
    
    parser.add_argument(
        "message", 
        type=str, 
        nargs="?", 
        default="안녕하세요", 
        help="The prompt/message to send to the LLM."
    )
    
    parser.add_argument(
        "-k", "--api-key", 
        type=str, 
        default=os.environ.get("ROBI_API_KEY"),
        help="Your API key. Alternatively, set the ROBI_API_KEY environment variable."
    )

    # Added claude-a45 to target the new endpoint explicitly
    parser.add_argument(
        "-m", "--model",
        type=str,
        choices=["gpt", "gemini", "claude", "claude-a45"],
        default="claude-a45",
        help="Select the LLM provider to query (default: gemini)."
    )

    parser.add_argument(
        "--raw",
        action="store_true",
        help="Output the raw JSON payload instead of the cleanly formatted message text."
    )

    args = parser.parse_args()

    if not args.api_key:
        print(
            "Error: API key is missing.\n"
            "Provide it using the --api-key/-k flag or set the ROBI_API_KEY environment variable.", 
            file=sys.stderr
        )
        sys.exit(1)

    # Map model choice to its respective URL and API format routing
    model_routing = {
        "gpt": (API_URL_GPT, "v1"),
        "gemini": (API_URL_Gemini, "v2"),
        "claude": (API_URL_Claude, "v2"),
        "claude-a45": (API_URL_Claude_A45, "anthropic-a45")
    }
    
    selected_url, api_format = model_routing[args.model]

    result = query_robi_api(args.message, args.api_key, selected_url, api_format)
    
    if args.raw:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        # Handle Output Formatting based on response shape
        if api_format == "anthropic-a45":
            # Standard Anthropic response shape
            if isinstance(result, dict) and "content" in result and len(result["content"]) > 0:
                print(result["content"][0].get("text", ""))
            else:
                print("[!] Warning: Unexpected Anthropic response structure.", file=sys.stderr)
                print(json.dumps(result, indent=2, ensure_ascii=False))
        else:
            # Legacy Robi response shape
            if isinstance(result, dict) and "message" in result:
                print(result["message"])
            else:
                print("[!] Warning: 'message' key missing in response. Falling back to raw JSON.", file=sys.stderr)
                print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
