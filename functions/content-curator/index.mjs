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
        contentTitle: body?.contentTitle
      },
    });
    const resp = await docClient.send(command);
    return resp;
  } catch (err) {
    console.error(`Dynamodb PUT Error: ${err}`);
  }
};

const getPlaylists = async ({docClient, tableName, contentType, contentId}) => {
  try {
    const command = new QueryCommand({
      TableName: tableName,
      KeyConditionExpression: contentId ? '#cType = :cType AND begins_with(#cId, :cId)' : '#cType = :cType' ,
      ExpressionAttributeNames: { 
        '#cType': 'contentType',
        ...(contentId && { '#cId': 'contentId' }),
      },
      ExpressionAttributeValues: {
         ':cType': contentType,
         ...(contentId && { ':cId': contentId }),
      },
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
    resp = await getPlaylists({docClient, tableName: PLAYLISTS_DYNAMODB_TABLE, contentType: body.contentType});
  }
  else if (body.action === 'getItem' && body.contentId.length > 0) {
    resp = await getPlaylists({docClient, tableName: PLAYLISTS_DYNAMODB_TABLE, contentType: body.contentType, contentId: body.contentId});
  } else {
    throw new Error('Unknown Dynamodb Method');
  }
  return resp;
};
