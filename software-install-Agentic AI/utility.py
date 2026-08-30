
import uuid
import secrets
from sqlalchemy.orm import Session
from app.db import SessionLocal
from app.models.security import AppUser, ServiceAccountCredential

def create_servicenow_api_key():
    """
    Create API key for ServiceNow service account
    Run this once to set up ServiceNow integration
    """
    db = SessionLocal()
    
    try:
        # Get the servicenow_svc user
        user = db.query(AppUser).filter(
            AppUser.username == "servicenow_svc"
        ).first()
        
        if not user:
            print("❌ servicenow_svc user not found")
            return
        
        # Generate a secure API key
        api_key = f"svc_{secrets.token_urlsafe(32)}"
        
        # Create credential record
        credential = ServiceAccountCredential(
            id=uuid.uuid4(),
            user_id=user.id,
            service_name="SERVICENOW",
            api_key=api_key,
            active=True,
            description="ServiceNow integration API key for auto-queueing requests"
        )
        
        db.add(credential)
        db.commit()
        
        print(f"✅ ServiceNow API Key Created!")
        print(f"   User: {user.username}")
        print(f"   API Key: {api_key}")
        print(f"\n🔐 Share this with ServiceNow team:")
        print(f"   Add header: X-API-Key: {api_key}")
        print(f"   Endpoint: POST http://your-api-host/api/v1/jobs")
        
        return api_key
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    create_servicenow_api_key()