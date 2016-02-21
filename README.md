# OpenVAS
A good start to defensive security is identifing what vulnerbilites you have
in your network. There are a lot of vendors out there that will sell you scanning software
such as Tenable (Nessus and SecurityCenter), Qualys, NextPose, EyeRetina

But if you want to do yourself with open source software and for free, or just get 
an idea, of how scanners work. You can take a look at OpenVAS.

OpenVAS is comprised of many parts and is generally rough to install but here is a
script to install it. It has been tested on Ubuntu 14.04 LTS

## OpenVAS installer script.
After the script is installed navigate to http://127.0.0.1 and login with adminsitrive
username and password you created during installation.
if you cannot rememeber it or you want to add another admin account:

change admin password:
```BASH
openvasmd --user=admin --new-password=new_password
```

create a new admin user:
```BASH
openvasad -c add_user -u your_new_login_here -r Admin
```
