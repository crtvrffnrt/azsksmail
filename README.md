```bash
git clone https://github.com/crtvrffnrt/azsksmail.git \
&& chmod +x ./azsksmail/azsksmail.sh \
&& bash azsksmail/azsksmail.sh \
       -SmtpServer "fallback.mail.protection.outlook.com." \
       -To "helpdesk@fallback.onmicrosoft.com" \
       -From "helpdesk@fallback.onmicrosoft.com" \
       -Subject "Test Email" \
       -Firstname "John" \
       -Lastname "Doe"
```
