'use strict'

import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { ddbDocClient } from "./libs/ddbDocClient.mjs";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))
    if (event.httpMethod !=="POST") {
        throw new Error(`Expecting POST method, received ${event.httpMethod}`);
    }

    if (event.queryStringParameters.memberId === null) {
        throw new Error(`memberId missing`);   
    } else if (event.queryStringParameters.policyId === null) {
        throw new Error(`policyId missing`);
    } else if (event.queryStringParameters.memberName === null) {
        throw new Error(`memberName missing`);
    }

    const {memberId, policyId, memberName} = event.queryStringParameters

    const parsedBody = JSON.parse(event.body || {})
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
    let response;
    const command = new PutCommand(params)
    try {
        const data = await ddbDocClient.send(command)
        console.log("Success, claim created", data)
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
    console.log("response===", params.Item)
    return response
}
