## Muster Point Tracker

Location data is a vital ingredient in today's applications, enabling capabilities ranging from asset tracking to location-based marketing.

With Amazon Location Service, you can easily add capabilities such as maps, points of interest, geocoding, routing, geofences, and tracking to applications. You retain control of your location data with Amazon Location, so you can combine proprietary data with data from the service. Amazon Location provides cost-effective location-based services (LBS) using high-quality data from global, trusted providers Esri and HERE Technologies.

## Architecture Overview
<img src="/images/architecture.png"/> 

## Stack
- **Front-end** - SwiftUI, iOS 12+, AWS Amplify for authentication/authorization and API communication, AWS SDK for Amazon Location Service APIs
- **Backend** - Amazon Location Service, Amazon EventBridge, Amazon Cognito, AWS AppSync, and Amazon DynamoDB

## Deploying the solution

### Prerequisites

For this walkthrough, you should have the following prerequisites: 

*	An AWS account
*	A MacOS operating system
*	XCode version 11.4 or later
*	Node.js v12.x or later 
*	npm v5.x or later
*	git v2.14.1 or later
*	Cocoapods

### Setting up Amazon Location Services

The first step of our solution consists of creating a new tracker and geofence collection on Amazon Location Services. Let’s start with the geofence collection:

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	Choose *Create geofence collection*. 
4.	Fill out the following boxes:
    1. Name – Enter a unique name. For example, ExampleGeofenceCollection. 
    2. Description – Enter an optional description. 
5.	Choose *Create geofence collection*. 

You will now add the geofences that represent your muster points. These geofences are created using GeoJSON files. You can use tools, such as geojson.io, at no charge, to draw your geofences graphically and save the output GeoJSON file. With the file ready, we can populate our collection:
1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	From the Geofence collections list, select the name link for the target geofence collection. 
4.	Under *Geofences*, choose *Create geofences*. 
5.	In the *Add geofences* window, drag and drop your GeoJSON into the window. 
6.	Choose *Add geofences*. 

Our next step is to create a Tracker. This tracker will be used on the iOS client to detect any changes in position that the user generates. These changes are pushed back to Amazon Location Services, which analyzes the position against the geofence collection, previously created. If an ENTER or EXIT events are detected, Amazon EventBridge is triggered.
1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Trackers*. 
3.	Choose *Create tracker*. 
4.	Fill out the following boxes:
    1. Name – Enter a unique name.
    2. Description – Enter an optional description. 
5.	Choose *Create tracker*. 


Now that you have a geofence collection and a tracker, you can link them together so that location updates are automatically evaluated against all of your geofences. When device positions are evaluated against geofences, events are generated. We will come back later to to set an action to these events. Let’s link a tracker resource to a geofence collection, first.

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose Trackers. 
3.	Under *Device trackers*, select the name link of the target tracker. 
4.	Under *Linked Geofence Collections*, choose *Link Geofence Collection*. 
5.	In the *Linked Geofence Collection* window, select a geofence collection from the dropdown menu.
6.	Choose *Link*. 
After you link the tracker resource, it will be assigned an **Active** status. Take note of your **Geofence collection** and **Tracker** names.

### Mobile Clients – AWS Amplify

#### Project download and configuration

1.	Follow the instructions [in this link](https://docs.amplify.aws/start/getting-started/installation/q/integration/ios) to install Amplify and configure the CLI.
2.	Clone this code repository

```
$ git clone git@github.com:aws-samples/amazon-location-service-musterpoint-tracker-ios.git
```

3.	Switch to the project's folder

```
$ cd amazon-location-service-musterpoint-tracker-ios
```

4.	Run the following command to install the **Amplify Libraries** and the **AWS Location SDK**:

```
pod install –repo-update
```

4.	Open your project by running on the terminal:

```
xed .
```

#### Init the Amplify project

1.	Initialize the Amplify project by opening a terminal and running:

```
amplify init
```

2.	Enter the following when prompted:

```
? Enter a name for the project
    MusterPointApp
? Enter a name for the environment
    dev
? Choose your default editor:
    Xcode (Mac OS only)
? Choose the type of app that you're building
    ios
Using default provider  awscloudformation
? Select the authentication method you want to use:
    AWS Profile
? Please choose the profile you want to use
    Default
```

Upon successfully running amplify init, you should see two new created files in your project directory: amplifyconfiguration.json and awsconfiguration.json. If the files are not there, they need to be manually moved to your XCode project folder. This is required so that Amplify libraries know how to reach your provisioned backend resources. Make sure that the file target is point to your client projects.

#### Add the Amplify categories

Now that the Amplify project was created, we will add the categories that will complement the project.

1.	Add the authentication category by opening a terminal and running:

```
amplify add auth
```

2.	Enter the following when prompted:

```
? Do you want to use the default authentication and security configuration?
Default configuration with Social Provider (Federation)
? How do you want users to be able to sign in? 
Username
? Do you want to configure advanced settings? 
No, I am done.
? What domain name prefix do you want to use? 
testamplifyd8a72b55-d8a72b55
? Enter your redirect signin URI: 
myapp://
? Do you want to add another redirect signin URI 
No
? Enter your redirect signout URI: 
myapp://
? Do you want to add another redirect signout URI
No
? Select the social providers you want to configure for your user pool:
	<No selection, press enter>
```

3.	Push the changes to the backend by running:

```
amplify push
```

With the auth category configured, we can now configure the API which will connect our front-end to the User table on DynamoDB.

1.	Add the API category by opening a terminal and running:

```
amplify add api
```

2.	Enter the following when prompted:

```
? Please select from one of the below mentioned services: 
GraphQL
? Provide API name: 
musterPointLocationAPI
? Choose the default authorization type for the API 
Amazon Cognito User Pool
? Do you want to configure advanced settings for the GraphQL API 
Yes, I want to make some additional changes.
? Configure additional auth types? 
Yes
? Choose the additional authorization types you want to configure for the API 
IAM
? Enable conflict detection? 
Yes
? Select the default resolution strategy 
Auto Merge
? Do you have an annotated GraphQL schema? 
No
? Choose a schema template: 
Single object with fields (e.g., “Todo” with ID, name, description)
```

With the API category added, we now have a GraphQL endpoint with two authentication modes configured: **Amazon Cognito User Pools**, for front-end authentication and authorization; and **IAM**, to authorize a Lambda function access to access your AppSync APIs, which will be configured in the next step.
3.	Now open the autogenerated file in *<project-dir>/amplify/backend/api/musterPointLocationAPI/schema.graphql* and add the content from *supporting-files/schema.graphql*. 
4.	Run the following command to generate the model files on your XCode project:

```
amplify codegen models
```

5.	Push the changes to the backend by running:

```
amplify push
```

Finally, we can add the last category, Function, to the project. This will create a Lambda function that will be triggered when the user crosses a Geofence created in Amazon Location Services.
1.	Add the Function category by opening a terminal and running:

```
amplify add function
```

2.	Enter the following when prompted:

```
? Select which capability you want to add: 
Lambda function (serverless function)
? Provide an AWS Lambda function name: 
musterPointLocationFunction
? Choose the runtime that you want to use: 
NodeJS
? Choose the function template that you want to use: 
Hello World
? Do you want to configure advanced settings? 
Yes
? Do you want to access other resources in this project from your Lambda function? 
Yes
? Select the categories you want this function to have access to. 
api
? Select the operations you want to permit on musterPointLocationAPI 
Query, Mutation
? Do you want to invoke this function on a recurring schedule? 
No
? Do you want to configure Lambda layers for this function? 
No
? Do you want to edit the local lambda function now? 
No
```

3.	Copy the files from the folder *supporting-files/function* to *<project-dir>/amplify/backend/function/musterPointLocationFunction/* 
	- Do not modify the header on **index.js**, specially if you created a different name for your API.
4.	Push the changes to the backend by running:

```
amplify push
```

#### Configure your iOS application with Amazon Location Services

Configure unauthenticated and authenticated users to allow access to Amazon Location

1.	Navigate to the root of your project and run the following command:

```
amplify console auth
```

2.	Select Identity Pool from *Which console?* when prompted.
3.	You will be navigated to the Amazon Cognito console. Click on *Edit identity pool* in the top right corner of the page.
4.	Open the drop down for *Unauthenticated identities*, choose *Enable access to unauthenticated identities*, and then press *Save Changes*.
5.	Click on *Edit identity pool once more*. Make a note of the name of the Unauthenticated role. For example, *amplify-<project_name>-<env_name>-<id>-unauthRole*.
6.	Open the AWS Identity and Access Management (IAM) console to manage roles.
7.	In the Search field, enter the name of your unauthRole noted above and click on it.
8.	Click *+Add inline policy*, then click on the JSON tab.
9.	Fill in the [ARN] placeholder with the ARN of your tracker which you noted above and replace the contents of the policy with the below.

```json
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": "geo:BatchUpdateDevicePosition",
           "Resource": "[ARN]"
       }
   ]
}
```

10.	To allow access to the geofences repeat the steps 5-9, but taking note of the Authenticated Role.
11.	Fill in the [ARN] placeholder with the ARN of your geofence collection which you noted above and replace the contents of the policy with the below.

```json
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": "geo:ListGeofences",
           "Resource": "[ARN]"
       }
   ]
}
```

#### Modify your plist files

Now we have all Amplify categories configured in our project, let’s take a look at the code that is collecting the geofences and tracking the user’s movement. 

1.	Open your project by running on the terminal:

```
xed .
```

2.	Open awsconfiguration.json and add the following lines to the end of the file:

```json
"Location": {
    "Default": {
        "Region": "<REGION ie: us-west-2>"
    }
}
```

3.	Open the file *info.plist* inside the folder *muster-point-client*. Change the value of the key *TrackerName* and *GeofencesName* to the Tracker name and Geofence collection name created on **Setting up Amazon Location Services**.

### Create the Amazon EventBridge rule

The last piece we need to configure is how we should act when the user crosses a Geofence and generates an **ENTER** or **EXIT** event.

1.	Open the Amazon EventBridge console at https://console.aws.amazon.com/events/
2.	Choose *Create rule*. 
3.	Enter a Name for the rule, and, optionally, a description. 
4.	Under *Define pattern*, choose *Event pattern*. 
5.	Under *Event matching pattern*, choose 8Pre-defined pattern by service*. 
6.	In *Service provider*, select *AWS*. Then, in *Service name*, select *Amazon Location Service*. Finally, in *Event type*, select *Location Geofence Event*
7.	Scroll down to *Select targets*, set the target as *Lambda Function*, and set the function you created using the Amplify CLI. If you are following this guide, it should be called **musterPointLocationFunction-dev**.
8.	Click on *Create*. 

### Test the application

This solution has two apps: **muster-point-patrol** and **muster-point-client**. Build and run muster-point-client, first. Click the sign in button and create a new account. After that, you will see a map centered in the user’s location alongside the geofences that were created by you, previously.

<img src="/images/client-1.png"  width="300" height="600" /> 

Now build and run the muster-point-patrol app. Since both apps are sharing the same Amplify backend, you can choose to either create a new user or sign in with the user previously created in the muster-point-client app. After signing in, you will see a page with all the created users. The red background represents the users that are not safe (not inside a muster point).
	
<img src="/images/patrol-1.png"  width="300" height="600" /> 

Back to the client app, start moving until you enter a muster point. When this happens, the user is automatically marked as safe and that is also reflected in the patrol application. If the user leaves the muster point, they are marked as not-safe, again.

<img src="/images/client-2.png"  width="300" height="600" />  <img src="/images/patrol-2.png"  width="300" height="600" /> 
	
### Cleaning up

#### Delete Amplify resources
1.	On the terminal, navigate to your project folder and run the following command:

```
amplify delete
```

2.	Select yes, when prompted.

#### Delete Amazon Location Services resources

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	Select the Geofence collection you created and click *Delete geofence collection*
4.	Type *delete* in the field and press *Delete*.
5.	In the left navigation pane, choose *Trackers*
6.	Select the Tracker you created and click *Delete tracker*
7.	Type delete in the field and press *Delete*.

#### Delete Amazon Event Bridge resources
1.	Open the Amazon EventBridge console at https://console.aws.amazon.com/events/
2.	Navigate to *Events* -> *Rules*
3.	Select the rule you want to delete.
4.	Click *Delete*.
5.	Click *Delete*, again, when prompted.


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

