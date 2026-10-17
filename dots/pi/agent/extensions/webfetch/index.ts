import { DEFAULT_MAX_BYTES, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import Exa from "exa-js";

const exa = new Exa(process.env.EXA_API_KEY);

export default function (pi: ExtensionAPI) {
  let toolCost = 0;

  pi.registerTool({
    name: "webfetch",
    label: "Web Fetch",
    description: "Fetch the contents of a single web page",
    promptSnippet: "Fetch the contents of a single web page",
    promptGuidelines: [
      "Use webfetch when the user explicitly asks to fetch the contents of a URL",
      "Always prefer webfetch to get contents of a web page over bash commands (curl, wget, etc)",
    ],
    parameters: Type.Object({
      url: Type.String(),
      highlights: Type.Boolean(),
      summarize: Type.Boolean(),
    }),
    execute: async (_toolCallId, { url, highlights, summarize }, signal) => {
      if (signal?.aborted) {
        return { content: [{ type: "text", text: "Cancelled" }], details: {} };
      }

      const contents = await exa.getContents([url], {
        text: { maxCharacters: DEFAULT_MAX_BYTES },
        highlights: { maxCharacters: DEFAULT_MAX_BYTES },
        summary: true,
      });

      toolCost = contents.costDollars?.total ?? 0;

      if (summarize)
        return {
          content: [{ type: "text", text: contents.results[0].summary }],
          details: {},
        };

      if (highlights)
        return {
          content: [{ type: "text", text: contents.results[0].highlights.join("\n") }],
          details: {},
        };

      return {
        content: [{ type: "text", text: contents.results[0]?.text ?? "" }],
        details: {},
      };
    },
  });

  pi.on("message_end", async (event) => {
    if (event.message.role !== "assistant") return;

    event.message.usage.cost.total += toolCost;
    toolCost = 0;

    return event;
  });
}
