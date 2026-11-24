import { ThinkingLevel } from "@earendil-works/pi-ai";
import { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("shift+up", {
    description: "Increase thinking level",
    handler: (ctx) => {
      if (ctx.thinkingLevel === undefined) return;

      const nextThinkingLevel: Record<ThinkingLevel | "off", ThinkingLevel> = {
        off: "low",
        minimal: "low",
        low: "medium",
        medium: "high",
        high: "xhigh",
        xhigh: "max",
        max: "low",
      };

      pi.setThinkingLevel(nextThinkingLevel[ctx.thinkingLevel]);
    },
  });

  pi.registerShortcut("shift+down", {
    description: "Decrease thinking level",
    handler: (ctx) => {
      if (ctx.thinkingLevel === undefined) return;

      const previousThinkingLevel: Record<ThinkingLevel | "off", ThinkingLevel> = {
        max: "low",
        xhigh: "high",
        high: "medium",
        medium: "low",
        low: "max",
        minimal: "max",
        off: "max",
      };

      pi.setThinkingLevel(previousThinkingLevel[ctx.thinkingLevel]);
    },
  });
}
