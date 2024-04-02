import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const ddbConfig ={
    region: "eu-central-1",
    endpoint: "XXXXXXXXXXXXXXXXXXXXX"
}

const client = new DynamoDBClient({region: "eu-central-1"});
export const ddbDocClient = DynamoDBDocumentClient.from(client);