import { ThinkingLevel } from "@earendil-works/pi-ai";
import { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("shift+up", {
    description: "Increase thinking level",
    handler: (ctx) => {
      if (ctx.thinkingLevel === "off") return;

      const nextThinkingLevel: Record<ThinkingLevel, ThinkingLevel> = {
        minimal: "low",
        low: "medium",
        medium: "high",
        high: "xhigh",
        xhigh: "max",
        max: "low",
      };

      pi.setThinkingLevel(nextThinkingLevel[ctx.thinkingLevel!]);
    },
  });

  pi.registerShortcut("shift+down", {
    description: "Decrease thinking level",
    handler: (ctx) => {
      if (ctx.thinkingLevel === "off") return;

      const previousThinkingLevel: Record<ThinkingLevel, ThinkingLevel> = {
        max: "low",
        xhigh: "high",
        high: "medium",
        medium: "low",
        low: "max",
        minimal: "max",
      };

      pi.setThinkingLevel(previousThinkingLevel[ctx.thinkingLevel!]);
    },
  });
}
