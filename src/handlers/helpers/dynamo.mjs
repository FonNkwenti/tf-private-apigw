
const {
    DynamoDBClient,
} = require("@aws-sdk/client-dynamodb");

const {
    DynamoDBDocumentClient,
    PutCommand,
    GetCommand,
    DeleteCommand,
    ScanCommand,
    QueryCommand
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

export const putItem = async (TableName, Item) =>
    await ddbDocClient.send(new PutCommand({ TableName, Item }));

export const getItem = async (TableName, Key) =>
    await ddbDocClient.send(new GetCommand({ TableName, Key }));

export const queryItemByIndex = async (query) =>
    await ddbDocClient.send(new QueryCommand(query));

export const scan = async (query) => ddbDocClient.send(new ScanCommand(query));

export const deleteItem = async (TableName, Key) =>
    await ddbDocClient.send(new DeleteCommand({ TableName, Key }));


