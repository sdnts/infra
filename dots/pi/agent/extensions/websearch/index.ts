import {
  DEFAULT_MAX_BYTES,
  truncateHead,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import Exa from "exa-js";

const exa = new Exa(process.env.EXA_API_KEY);

export default function (pi: ExtensionAPI) {
  let toolCost = 0;

  pi.registerTool({
    name: "websearch",
    label: "Web Search",
    description: "Search for answers on the web",
    promptSnippet: "Search for answers on the web",
    promptGuidelines: [
      "Use the `websearch` tool when the user asks a question that cannot be answered using the information available in the project",
      'When using the `websearch` tool, you must always include sources at the end of your answer as a bulleted list titled "Sources:"',
    ],
    parameters: Type.Object({
      query: Type.String(),
    }),
    execute: async (_toolCallId, { query }, signal, _onUpdate, ctx) => {
      if (signal?.aborted) {
        return { content: [{ type: "text", text: "Cancelled" }], details: {} };
      }

      const { results, costDollars } = await exa.search(query, {
        numResults: 5,
        contents: { highlights: true },
      });

      toolCost = costDollars?.total ?? 0;

      const { truncated, content } = truncateHead(
        results.map((r) => (r.highlights ?? []).join("\n")).join("\n"),
        { maxBytes: DEFAULT_MAX_BYTES },
      );
      if (truncated) ctx.ui.notify(`Truncated result of websearch`);

      return {
        content: [{ type: "text", text: content }],
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
