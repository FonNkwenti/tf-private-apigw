'use strict'

import { GetCommand } from "@aws-sdk/lib-dynamodb";
import { ddbDocClient } from "./libs/ddbDocClient.mjs";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

export const handler = async (event, context) => {
    console.log("Hello World from getClaim function");
    console.log("event===",JSON.stringify(event, null, 2))
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello World from getClaim function" }),
    };

}