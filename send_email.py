import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

# Email and SMTP Configuration
sender_email = "voostockupdate@gmail.com"
sender_password = "ifaw uzac cxcb znox"
receiver_email = "jjcochrane19@gmail.com"

# Create a multipart message and set headers
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = receiver_email
message["Subject"] = "VOO Stock Update"

# Add body to email
body = "VOO From 10/1/2022 through today."
message.attach(MIMEText(body, "plain"))

# Open the file in binary mode
filename = "voo.png"
with open(filename, "rb") as attachment:
    # Add file as application/octet-stream
    # Email client can usually download this automatically as attachment
    part = MIMEBase("application", "octet-stream")
    part.set_payload(attachment.read())

# Encode file in ASCII characters to send by email    
encoders.encode_base64(part)

# Add header as key/value pair to attachment part
part.add_header(
    "Content-Disposition",
    f"attachment; filename= {filename}",
)

# Add attachment to message and convert message to string
message.attach(part)
text = message.as_string()

# Log in to server using secure context and send email
try:
    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, receiver_email, text)
    print("Email sent successfully!")
except Exception as e:
    print(f"Error sending email: {e}")