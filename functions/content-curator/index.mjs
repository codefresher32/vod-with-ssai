import { DynamoDBDocumentClient, PutCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const putPlaylist = async (docClient, tableName, body) => {
  try {
    const command = new PutCommand({
      TableName: tableName,
      Item: {
        contentType: body?.contentType,
        contentId: body?.contentId,
        contentDescription: body?.contentDescription,
        adBreaks: body?.adBreaks,
        thumbnail: body?.thumbnail,
      },
    });
    const resp = await docClient.send(command);
    return resp;
  } catch (err) {
    console.error(`Dynamodb PUT Error: ${err}`);
  }
};

const getPlaylists = async (docClient, tableName, contentType) => {
  try {
    const command = new QueryCommand({
      TableName: tableName,
      KeyConditionExpression: '#cType = :cType',
      ExpressionAttributeNames: { '#cType': 'contentType' },
      ExpressionAttributeValues: { ':cType': contentType },
    });
    const resp = await docClient.send(command);
    return resp;
  } catch (err) {
    console.error(`Dynamodb PUT Error: ${err}`);
  }
};

export const handler = async(event) => {
  console.info(`EVENT: ${JSON.stringify(event)}`);

  const { PLAYLISTS_DYNAMODB_TABLE } = process.env;
  const body = JSON.parse(event.body);
  
  let resp = '';
  if (body.action === 'putItem') {
    resp = await putPlaylist(docClient, PLAYLISTS_DYNAMODB_TABLE, body);
  } else if (body.action === 'getItem' && !body.contentId) {
    resp = await getPlaylists(docClient, PLAYLISTS_DYNAMODB_TABLE, body.contentType);
  } else {
    throw new Error('Unknown Dynamodb Method');
  }
  return resp;
};
