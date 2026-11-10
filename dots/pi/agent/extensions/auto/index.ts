import { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerVirtualModel({
    provider: "sdnts",
    id: "auto",
    name: "auto",
    thinkingLevels: ["low", "medium", "high", "max"],
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

      if (request.thinkingLevel === "high") {
        const model = ctx.modelRegistry.find("openai", "gpt-6.1-sol")!;
        return {
          model,
          thinkingLevel: "xhigh",
        };
      }

      if (request.thinkingLevel === "max") {
        const model = ctx.modelRegistry.find("openai", "gpt-6-astra")!;
        return {
          model,
          thinkingLevel: "max",
        };
      }

      throw new Error(`Unknown thinking level: ${request.thinkingLevel}`);
    },
  });
}
