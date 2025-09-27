import ballerinax/ai;
import ballerina/http;

listener ai:Listener OrderProcessingAgentListener = new (listenOn = check http:getDefaultListener());

service /OrderProcessingAgent on OrderProcessingAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check _OrderProcessingAgentAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
