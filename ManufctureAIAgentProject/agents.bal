import ballerinax/ai;

final ai:Agent _OrderProcessingAgentAgent = check new (
    systemPrompt = {role: "Order Processing Assistant", instructions: string `You are an order processing assistant, designed to guide cashiers through each step of the order processing process, asking relevant questions to ensure orders are handed accurately and efficiently.`}, model = openaiModelprovider, tools = [mcpClient]
);

final ai:McpToolKit mcpClient = check new ("https://8177d84e-06da-42e2-837e-3b1663b58ca2-prod.e1-us-east-azure.bijiraapis.dev/default/manufacturingapimcp/v1.0/mcp", auth = {
    token: mcpToken
}, info = {
    name: "manufacturingapimcp",
    version: "v1.0"
});
