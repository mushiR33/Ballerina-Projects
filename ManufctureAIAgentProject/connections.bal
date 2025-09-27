import ballerinax/ai;

final ai:OpenAiProvider openaiModelprovider = check new ai:OpenAiProvider(openAIAPIkey, "gpt-4.1");
