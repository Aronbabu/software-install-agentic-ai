from dotenv import load_dotenv
from msal import ConfidentialClientApplication
import os
import jwt
import requests

load_dotenv()

TENANT_ID = os.getenv("TENANT_ID")
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")

AUTHORITY = f"https://login.microsoftonline.com/{TENANT_ID}"

app = ConfidentialClientApplication(
    CLIENT_ID,
    authority=AUTHORITY,
    client_credential=CLIENT_SECRET
)

result = app.acquire_token_for_client(
    scopes=["https://graph.microsoft.com/.default"]
)

if "access_token" in result:
    print("SUCCESS")
    print("Token acquired")
    print(result["access_token"][:50] + "...")
else:
    print("FAILED")
    print(result)

token = result["access_token"]

decoded = jwt.decode(
    token,
    options={"verify_signature": False}
)

print(decoded)


headers = {
    "Authorization": f"Bearer {token}"
}

response = requests.get(
    "https://graph.microsoft.com/v1.0/users?$top=1",
    headers=headers
)

print(response.status_code)
print(response.text)