/* Amplify Params - DO NOT EDIT
  API_MUSTERPOINTLOCATIONAPI_GRAPHQLAPIENDPOINTOUTPUT
  API_MUSTERPOINTLOCATIONAPI_GRAPHQLAPIIDOUTPUT
  ENV
  REGION
Amplify Params - DO NOT EDIT */

const https = require('https')
const AWS = require('aws-sdk')
const urlParse = require('url').URL
const region = process.env.REGION
const appsyncUrl = process.env.API_MUSTERPOINTLOCATIONAPI_GRAPHQLAPIENDPOINTOUTPUT

const request = (queryDetails, appsyncUrl, apiKey) => {
  const req = new AWS.HttpRequest(appsyncUrl, region)
  const endpoint = new urlParse(appsyncUrl).hostname.toString()

  req.method = 'POST'
  req.path = '/graphql'
  req.headers.host = endpoint
  req.headers['Content-Type'] = 'application/json'
  req.body = JSON.stringify(queryDetails)

  if (apiKey) {
    req.headers['x-api-key'] = apiKey
  } else {
    const signer = new AWS.Signers.V4(req, 'appsync', true)
    signer.addAuthorization(AWS.config.credentials, AWS.util.date.getDate())
  }

  return new Promise((resolve, reject) => {
    const httpRequest = https.request({ ...req, host: endpoint }, (result) => {
      result.on('data', (data) => {
        resolve(JSON.parse(data.toString()))
      })
    })

    httpRequest.write(req.body)
    httpRequest.end()
  })
}

const updateSafetyMutation = /* GraphQL */ `
  mutation updateUser($input: UpdateUserInput!) {
      updateUser(input: $input){
        id
        isSafe
        username
        createdAt
        updatedAt
        _lastChangedAt
        _version
        _deleted
      }
    }
`
const queryUser = /* GraphQL */ `
  query getUser($id: ID!) {
        getUser (id: $id) {
            id
            username
            isSafe
            _version
         }
    }
`

exports.handler = async (event) => {
  const userId = event?.detail?.DeviceId
  console.log('new geofence event:', event)

  var queryResult = await request(
      {
        query: queryUser,
        variables: { id: userId },
      },
      appsyncUrl
    )
  console.log('query result', queryResult)


  const user = queryResult?.data?.getUser
  if (!user) {
    return {
      statusCode: 404,
      body: `User with id ${userId} not found in the database.`,
    };
  }

  const version = user?._version
  var result = await request(
    {
      query: updateSafetyMutation,
      variables: {
        input: {
            id: userId,
            isSafe: event?.detail?.EventType === "ENTER",
            _version: version
        },
      },
    },
    appsyncUrl
  )
  console.log('appsync result', result)
}
