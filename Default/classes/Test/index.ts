import RDK, { Data, InitResponse, Response, StepResponse } from "@retter/rdk";

const rdk = new RDK();

export async function authorizer(data: Data): Promise<Response> {
    return { statusCode: 401 };
}

export async function init(data: Data): Promise<Data> {
    data.state.public = {
        message: "Hello World"
    }
    return data
}

export async function getState(data: Data): Promise<Response> {
    return { statusCode: 200, body: data.state };
}

export async function sayHello(data: Data): Promise<Data> {
    data.response = {
        statusCode: 200,
        body: { message: data.state.public.message },
    };
    return data;
}
