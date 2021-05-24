/* Amplify Params - DO NOT EDIT
  PARAMS WILL BE HERE - COPY FROM COMMENT DOWN
Amplify Params - DO NOT EDIT */
const AWS = require('aws-sdk');
const graphqlQuery = require('./query.js').query;
const graphqlUpdate = require('./update.js').update;
const gql = require('graphql-tag');
const AWSAppSyncClient = require('aws-appsync').default;
require('es6-promise').polyfill();
require('isomorphic-fetch');

const url = process.env.<YOUR_ENDPOINT_FROM_PARAMS>;
const region = process.env.REGION;
AWS.config.update({
  region,
  credentials: new AWS.Credentials(
    process.env.AWS_ACCESS_KEY_ID,
    process.env.AWS_SECRET_ACCESS_KEY,
    process.env.AWS_SESSION_TOKEN
  ),
});
const credentials = AWS.config.credentials;
const appsyncClient = new AWSAppSyncClient(
  {
    url,
    region,
    auth: {
      type: 'AWS_IAM',
      credentials,
    },
    disableOffline: true,
  },
  {
    defaultOptions: {
      query: {
        fetchPolicy: 'network-only',
        errorPolicy: 'all',
      },
    },
  }
);

exports.handler = async (event) => {
	const userId = event?.detail?.DeviceId
    
  const queryRes = await appsyncClient.query({
    query: gql(graphqlQuery),
    variables: { id: userId }
  });

  const user = queryRes?.data?.getUser
  if (!user) {
    return {
      statusCode: 404,
      body: `User with id ${userId} not found in the database.`,
    };
  }

  const mutation = gql(graphqlUpdate)

  const version = user?._version
  const mutateRes = await appsyncClient.mutate({
    mutation,
    variables: { 
    	input: {
    		id: userId,
    		isSafe: event?.detail?.EventType === "ENTER",
    		_version: version
    	}
    }
  });    

  
  response = {
          statusCode: 200,
          body: mutateRes,
   };
  return response;
};
