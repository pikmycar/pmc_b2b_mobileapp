import urllib.request
import json
import ssl

url = "https://api.pikmycar.com/api/v1/driver/send-main-driver-request"
headers = {
    "accept": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3ZDQwM2Q5ZS0zNTRiLTQ2NDUtYTY4YS04N2NhYjc3YzZiNTAiLCJleHAiOjE3Nzk3OTM5OTAsInR5cGUiOiJhY2Nlc3MiLCJyb2xlIjoic3VwcG9ydF9kcml2ZXIifQ.RuNqqByuI3Wev5YESfb8iYN4tejeutlYWJOFresvBNQ",
    "Content-Type": "application/json"
}

data = {
    "ticketId": "511c7bbb-0f82-42ef-baf8-2b7b709143a2",
    "supportDriverId": "7d403d9e-354b-4645-a68a-87cab77c6b50",
    "pickupLocation": "Chennai",
    "pickupLatitude": -90.0,
    "pickupLongitude": -180.0,
    "pickupGoogleMapsAddress": "Chennai",
    "dropLocation": "Chennai,tata",
    "dropLatitude": -90.0,
    "dropLongitude": -180.0,
    "dropGoogleMapsAddress": "Chennai,tata",
    "notes": "Support driver requesting Main Driver pickup",
    "sameVendorOnly": False
}

req = urllib.request.Request(
    url, 
    data=json.dumps(data).encode("utf-8"), 
    headers=headers, 
    method="POST"
)

# Disable SSL verification for safety in this scratch script if needed
context = ssl._create_unverified_context()

try:
    with urllib.request.urlopen(req, context=context) as response:
        print("Status Code:", response.status)
        print("Response Body:", response.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("HTTP Error Code:", e.code)
    print("Error Response Body:", e.read().decode("utf-8"))
except Exception as e:
    print("Generic Error:", str(e))
