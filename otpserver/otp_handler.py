import random
import yagmail

# def generate_otp():
#     """Generate a 6-digit OTP."""
#     otp = random.randint(100000, 999999)
#     return otp
#
# def send_otp_email(receiver_email, otp):
#     """Send the OTP to the given email."""
#     try:
#         yag = yagmail.SMTP('isurumuniwije@gmail.com', 'ulwm yawm pugz pvga ')
#         subject = '''Medisense healthcare
#                     ----------------------
#                         Your OTP Code'''
#
#         content = f"Your OTP code is {otp}. Please use this to complete your verification."
#         yag.send(to=receiver_email, subject=subject, contents=content)
#         return True
#     except Exception as e:
#         print(f"Failed to send email: {e}")
#         return False
#
#
# import yagmail
# import random

import yagmail
import random


def generate_otp():
    """Generate a 6-digit OTP."""
    otp = random.randint(100000, 999999)
    return otp


def send_otp_email(receiver_email, otp):
    """Send the OTP to the given email with a more advanced design."""
    try:
        yag = yagmail.SMTP('isurumuniwije@gmail.com', 'ulwm yawm pugz pvga')

        subject = "Your OTP Code"

        # HTML Content for Email with inline CSS and advanced design
        html_content = f"""
        <html>
        <head>
            <style>
                @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
                body {{
                    font-family: 'Roboto', sans-serif;
                    background-color: #f7f9fc;
                    margin: 0;
                    padding: 0;
                    text-align: center;
                }}
                .container {{
                    max-width: 600px;
                    margin: 0 auto;
                    background-color: #fff;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
                }}
                .header {{
                    padding: 10px 0;
                }}
                .header img {{
                    width: 150px;
                    margin-bottom: 20px;
                }}
                .otp-code {{
                    font-size: 28px;
                    font-weight: bold;
                    color: #2c3e50;
                    letter-spacing: 5px;
                    margin: 20px 0;
                }}
                .otp-btn {{
                    display: inline-block;
                    padding: 15px 30px;
                    font-size: 16px;
                    background-color: #007bff;
                    color: white;
                    text-decoration: none;
                    border-radius: 5px;
                    margin: 20px 0;
                }}
                .footer {{
                    color: #888;
                    font-size: 12px;
                    padding-top: 20px;
                    border-top: 1px solid #eaeaea;
                }}
                .footer a {{
                    color: #007bff;
                    text-decoration: none;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <img src="https://cdn.discordapp.com/attachments/1294698254147125312/1296413979178045471/image.png?ex=6712331a&is=6710e19a&hm=e43ad1839c8014fadb0b941c9811f29dae7af9cba8fd3e66550806fe596d46cc&" alt="Company Logo" />
                </div>
                <h2 style="color: #333;">Your One-Time Password (OTP)</h2>
                <p style="font-size: 18px; color: #555;">
                    Use the following OTP code to complete your verification. The code is valid for 10 minutes.
                </p>
                <div class="otp-code">{otp}</div>
                <a href="#" class="otp-btn">Verify Now</a>
                <p style="color: #999;">If you did not request this OTP, please ignore this email.</p>
                <div class="footer">
                    <p>&copy; 2024 Your Company. All rights reserved.</p>
                    <p>
                        <a href="#">Privacy Policy</a> | <a href="#">Terms of Service</a>
                    </p>
                </div>
            </div>
        </body>
        </html>
        """

        # Send email with HTML content
        yag.send(to=receiver_email, subject=subject, contents=html_content)
        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False
