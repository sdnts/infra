import { createProvider, ThinkingLevel } from "@earendil-works/pi-ai";
import { openAICompletionsApi } from "@earendil-works/pi-ai/compat";
import { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type OmlxModel = {
  id: string;
  model_alias?: string;
  max_context_window: number;
  reasoning_levels: ThinkingLevel[];
  max_tokens: number;
};

export default function (pi: ExtensionAPI) {
  pi.registerProvider(
    createProvider({
      id: "omlx",
      name: "oMLX",
      api: { "openai-responses": openAICompletionsApi() },
      auth: {
        apiKey: {
          name: "default",
          resolve: async () => ({ auth: { apiKey: "fake-api-key" } }),
        },
      },
      models: [],
      fetchModels: async ({ signal }) => {
        const baseUrl = "https://omlx.panthera-flops.ts.net/v1";

        const res: { models: OmlxModel[] } = await fetch(`${baseUrl}/models/status`, {
          signal,
        }).then((r) => r.json());

        return res.models.map((m) => ({
          provider: "omlx",
          id: m.model_alias ?? m.id,
          name: m.model_alias ?? m.id,
          baseUrl,
          api: "openai-responses",
          input: ["text"],
          reasoning: true,
          thinkingLevelMap: {
            off: "off",
            minimal: "low",
            low: m.reasoning_levels.includes("low") ? "low" : null,
            medium: m.reasoning_levels.includes("medium") ? "medium" : null,
            high: m.reasoning_levels.includes("high") ? "high" : null,
            xhigh: m.reasoning_levels.includes("xhigh") ? "xhigh" : null,
            max: m.reasoning_levels.includes("max") ? "max" : null,
          },
          contextWindow: m.max_context_window,
          maxTokens: m.max_tokens,
          cost: {
            input: 0,
            output: 0,
            cacheRead: 0,
            cacheWrite: 0,
          },
        }));
      },
    }),
  );
}
