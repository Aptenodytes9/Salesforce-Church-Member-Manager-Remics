# What is Remics?

Remics is Salesforce Lightning Web Components Software for Christian churches.  
It can manage information on congregations attending church, their families, and survivors.  
It also has the Functions to manage congregational giving information and integrate with other accounting management systems.  
This system is packaged for Salesforce administrators and developers.

![Image](https://user-images.githubusercontent.com/29101328/160239487-5d3185ce-3714-434b-85b3-82796619e3bb.png)

# Features

- Management of Church Member Information
- nagement of information on family and clan members of church members
- Management of donation information
- Assistance in preparing weekly reports
- Support for the preparation of memorial services for the called
- Support for preparation of church general meetings
- Accounting System Linkage Functions

# Installing the app using a Scratch Org

1. Set up your environment. The steps include:

   - Enable Dev Hub
   - Install Salesforce CLI
   - Install Visual Studio Code

1. If you haven't already done so, authorize your hub org and provide it with an alias:

   ```
   sfdx auth:web:login -d -a hoge
   ```

1. Clone the repository:

   ```
   git clone https://github.com/Aptenodytes9/Salesforce-Church-Member-Manager-Remics
   cd remics
   ```

1. Create a scratch org and provide it with an alias:

   ```
   sfdx force:org:create -s -f config/project-scratch-def.json -a remics
   ```

1. Push the app to your scratch org:

   ```
   sfdx force:source:push
   ```

1. Assign the user permission set to the default user:

   ```
   sfdx force:user:permset:assign -n hoge_User
   ```

1. Assign the below permission sets to the admin user:

   ```
   sfdx force:user:permset:assign -n hoge_Admin
   ```

   ```
   sfdx force:user:permset:assign -n hoge_Export_Lane
   ```

1. Open the scratch org:

   ```
   sfdx force:org:open
   ```

# License

This software is released under the [MIT license](https://en.wikipedia.org/wiki/MIT_License).
