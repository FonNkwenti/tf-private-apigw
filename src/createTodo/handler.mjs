

export const createTodo = async (event, context) => {
    console.log("Hello World from createTodo function");
    console.log("event===",JSON.stringify(event, null, 2))
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello World from createTodo function" }),
    };

}