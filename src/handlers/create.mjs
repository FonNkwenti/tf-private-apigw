'use strict'

import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { ddbDocClient } from "./libs/ddbDocClient.mjs";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

// export const handler = async (event, context) => {
//     console.log("Hello World from createClaim function");
//     console.log("event===",JSON.stringify(event, null, 2))
//     return {
//         statusCode: 200,
//         body: JSON.stringify({ message: "Hello World from c function" }),
//     };

// }


export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))
    if (event.httpMethod !=="POST") {
        throw new Error(`Expecting POST method, received ${event.httpMethod}`);
    }
    const {memberId, policyId, memberName} = event.queryStringParameters

    const parsedBody = JSON.parse(event.body)
    console.info("parsedBody==", parsedBody)
    const now = new Date().toISOString()
    const claimId = randomUUID()
   

    const params = {
        TableName:  tableName,
        Item: {
            PK: `MEMBER#${memberId}`,
            SK: `CLAIM#${claimId}`,
            ...parsedBody,
            policyId, 
            memberName,
            createdAt: now,
            updatedAt: now,
    }
    
}
console.log("params===", params)
    let response;
    const command = new PutCommand(params)
    try {
        const data = await ddbDocClient.send(command)
        console.log("Success, note created", data)
        response = {
            statusCode: 201,
            body: JSON.stringify(params.Item),
        }

            
        } catch (err) {
            console.log("Error", err)
            response = {
                statusCode: err.statusCode || 500,
                body: JSON.stringify({err})
            }
        }
    console.log("response===", response)
    return response
}
