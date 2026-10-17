import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { readFile } from "node:fs/promises";
import { basename, extname, resolve } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "draw_image",
    label: "Draw Image",
    description: `Display a PNG image file from disk directly in the terminal. The image is also attached to the conversation as vision input.`,
    promptSnippet: "Display an image file from disk inline in the terminal",
    promptGuidelines: [
      "Use draw_image when the user asks to show, display, preview, or draw an image file in the terminal.",
    ],
    parameters: Type.Object({
      path: Type.String({
        description: "Path to the PNG image file on disk. Relative paths resolve against the cwd.",
      }),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      if (signal?.aborted) return { content: [{ type: "text", text: "Cancelled" }], details: {} };

      // Models sometimes prefix paths with @; built-ins strip it, so we do too.
      const path = resolve(ctx.cwd, params.path.replace(/^@/, ""));

      if (extname(path).toLowerCase() !== ".png")
        throw new Error(`Not a PNG image: ${basename(path)}. Only PNG is supported.`);

      const base64Data = await readFile(path, "base64");

      return {
        content: [{ type: "image", data: base64Data, mimeType: "image/png" }],
        details: { path },
      };
    },
    renderCall(args, theme) {
      const name = typeof args?.path === "string" ? basename(args.path.replace(/^@/, "")) : "";
      return new Text(
        theme.fg("toolTitle", theme.bold("draw_image ")) + theme.fg("muted", name),
        0,
        0,
      );
    },
  });
}
