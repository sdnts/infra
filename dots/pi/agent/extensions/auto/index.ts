import { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerVirtualModel({
    provider: "sdnts",
    id: "auto",
    name: "auto",
    thinkingLevels: ["low", "medium", "max"],
    route(request, ctx) {
      if (request.thinkingLevel === "low") {
        const model = ctx.modelRegistry.find("openrouter", "deepseek/deepseek-v4.1-flash")!;
        return {
          model,
          thinkingLevel: "low",
        };
      }

      if (request.thinkingLevel === "medium") {
        const model = ctx.modelRegistry.find("openai", "gpt-6.1-sol")!;
        return {
          model,
          thinkingLevel: "medium",
        };
      }

      if (request.thinkingLevel === "max") {
        const model = ctx.modelRegistry.find("openai", "gpt-6-astra")!;
        return {
          model,
          thinkingLevel: "xhigh",
        };
      }

      throw new Error(`Unknown thinking level: ${request.thinkingLevel}`);
    },
  });
}
