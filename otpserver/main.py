from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from otp_handler import generate_otp, send_otp_email

app = FastAPI()

class OTPRequest(BaseModel):
    email: EmailStr

@app.post("/send-otp/")
def send_otp(request: OTPRequest):
    otp = generate_otp()
    if send_otp_email(request.email, otp):
        return {"message": "OTP sent successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send OTP")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
