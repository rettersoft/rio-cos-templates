import RDK, { Data, Response } from '@retter/rdk';

const rdk = new RDK();

export async function authorizer(data: Data): Promise<Response> {
    const { identity, methodName } = data.context;
    if (methodName === 'setState' && identity === 'developer') return { statusCode: 204 };

    return { statusCode: 403 };
}

export async function init(data: Data): Promise<Data> {
    data.state.public = { message: 'Hello, World!' };
    return data;
}

export async function getState(data: Data): Promise<Response> {
    return {
        statusCode: 200,
        body: data.state,
        headers: { 'x-rio-state-version': data.version.toString() }
    };
}

export async function setState(data: Data): Promise<Response> {
    const { state, version } = data.request.body || {};
    if (data.version !== version) {
        return {
            statusCode: 409,
            body: {
                message: `Your state version (${version}) is behind the current version (${data.version}).`,
            },
        };
    }

    data.state = state;
    return { statusCode: 204 };
}

export async function sayHello(data: Data): Promise<Data> {
    data.response = {
        statusCode: 200,
        body: {
            message: data.state.public?.message,
        },
    };
    return data;
}
