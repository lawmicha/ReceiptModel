# DataStore w/ Auth Directive (Issue #403)

Model schema from https://github.com/aws-amplify/amplify-ios/issues/403 See `schema.graphql` 

Some doc https://github.com/aws-amplify/amplify-ios/issues/395#issuecomment-634967688

## Steps

1. `pod install`

2. `amplify init`
```
? Enter a name for the project `ReceiptModel`
? Enter a name for the environment `dev`
? Choose your default editor: `Visual Studio Code`
? Choose the type of app that you're building `ios`
? Do you want to use an AWS profile? `Yes`
```

3. `amplify add api`
```
? Please select from one of the below mentioned services: `GraphQL`
? Provide API name: `receiptmodel`
? Choose the default authorization type for the API `Amazon Cognito User Pool`
 How do you want users to be able to sign in? `Username`
 Do you want to configure advanced settings? `No, I am done.`
? Do you want to configure advanced settings for the GraphQL API `Yes, I want to make some additional changes.`
? Configure additional auth types? `No`
? Configure conflict detection? `Yes`
? Select the default resolution strategy `Auto Merge`
? Do you have an annotated GraphQL schema? `Yes`
? Provide your schema file path: `schema.graphql`
```
4. `amplify push`
```
? Are you sure you want to continue? `Yes`
? Do you want to generate code for your newly created GraphQL API `No`
```

5. `amplify codegen models` if you need models different from the ones checked in for this schema. Then add the model files to your project target by deleting the old ones, dragging ini the new ones.


6. `amplify console auth` 
```
? Which console `User Pool`
```

7. Go to Users and groups, Creae user, use a 
- username `user1`
- password `password`
- un-check `send an invitation to this new user?`
- un-check `mark phone number as verified?`
- check `mark email as verified` and enter an email

8. Go to App clients and note down the `App client id` for the "clientWeb" client

9. `amplify console api`
```
? Please select from one of the below mentioned services: `GraphQL`
```
10. Click on Login with User Pools
- Enter the `App client Id` from step 8 as ClientId
- Username 'user1'
- Password 'password`

11. When prompt to enter a new password, use the same one.

This code example has the same `user1` and `password` hardcoded for the `Amplify.Auth.SignIn` call

12. Open the workspace file, build and run the project.
- Verbose logging is enabled so you'll see subscriptions failing due to user not authenticated in the console logs
- Click on Sign In


