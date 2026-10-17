import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("aside", {
    description: "Answer a question without polluting the context",
    handler: async (query, ctx) => {
      if (query === "") return ctx.ui.setWidget("aside", undefined, { placement: "belowEditor" });

      ctx.ui.setWidget("aside", ["[aside]", "Running\n"], { placement: "belowEditor" });
      const result = await pi.exec("pi", ["-p", query, "--no-session"]);
      ctx.ui.setWidget(
        "aside",
        ["[aside]", result.code === 0 ? result.stdout : `Failed: ${result.stderr}`],
        { placement: "belowEditor" },
      );
    },
  });

  // Clear any widgets when the assistant responds next
  pi.on("message_start", (_event, ctx) =>
    ctx.ui.setWidget("aside", undefined, { placement: "belowEditor" }),
  );
}
