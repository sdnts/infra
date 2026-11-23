import { basename } from "node:path";
import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { ThinkingLevel } from "@earendil-works/pi-ai";

function foreground(red: number, green: number, blue: number): string {
  return `\x1b[38;2;${red};${green};${blue}m`;
}
function background(red: number, green: number, blue: number): string {
  return `\x1b[48;2;${red};${green};${blue}m`;
}

const COLORS = {
  reset: "\x1b[0m",
  background: background(48, 48, 48),
  model: { base: foreground(140, 140, 140), glint: foreground(255, 255, 255) },
  separator: foreground(140, 140, 140),
  thinking: (level: ThinkingLevel | "off") => {
    if (level === "max")
      return { base: foreground(170, 138, 204), glint: foreground(220, 184, 255) };
    if (level === "xhigh")
      return { base: foreground(209, 154, 102), glint: foreground(255, 195, 122) };
    return { base: foreground(140, 140, 140), glint: foreground(255, 255, 255) };
  },
  cwd: foreground(105, 105, 105),
  cost: foreground(75, 75, 75),
};

class Editor extends CustomEditor {
  public model = "(Unknown)";
  public thinkingLevel: ThinkingLevel | "off" = "off";
  public cwd = "~";
  public cost = 0;

  private glints: Record<
    "model" | "thinkingLevel",
    {
      progress: number;
      timeout?: NodeJS.Timeout;
      interval?: NodeJS.Timeout;
    }
  > = {
    model: { progress: 0 },
    thinkingLevel: { progress: 0 },
  };

  enqueueGlint(target: "model" | "thinkingLevel") {
    const increment = 10;
    const deltaMs = 20;
    const durationMs = deltaMs * increment;

    this.cancelGlint(target);
    this.glints[target] = {
      progress: 0,
      interval: setInterval(() => {
        this.glints[target].progress += increment;
        this.tui.requestRender();
      }, deltaMs),
      timeout: setTimeout(() => {
        clearInterval(this.glints[target].interval);
        this.glints[target].progress = 0;
        this.tui.requestRender();
      }, durationMs),
    };
  }

  cancelGlint(target: "model" | "thinkingLevel") {
    clearInterval(this.glints[target].interval);
    clearTimeout(this.glints[target].timeout);
    this.glints[target].progress = 0;
  }

  override render(width: number) {
    // This is the layout we're after:
    //------------------------------------------------------------
    //  <prompt> |                         model · thinkingLevel
    //                                     cwd             $0.00
    //------------------------------------------------------------
    //
    // - The editor section as a whole has a dark gray background for contrast against the dark terminal. The dashed
    //   line is just illustrating where the "borders" of this background should be.
    // - The prompt shows up on the left, and leaves some space on the right for session metadata
    // - The session metadata takes up two lines, so if the prompt isn't long enough, we jsut render an extra empty line
    // - The cost is left-aligned within the session metadata, the cost is right aligned within the session metadata
    // - There's a 1 cell padding on the left of the prompt and on the right of the session metadata.

    // Render the session metadata first
    const model = (() => {
      const colors = COLORS.model;

      // Account for the glint effect
      if (this.glints.model.progress === 0) return colors.base + this.model;

      const glintIndex = Math.floor((this.glints.model.progress / 100) * this.model.length);
      return (
        // oxfmt-ignore
        (colors.base + this.model.slice(0, glintIndex - 1)) +
        (colors.glint + this.model.slice(glintIndex - 1, glintIndex + 2)) +
        (colors.base + this.model.slice(glintIndex + 2))
      );
    })();
    const separator = COLORS.separator + " · ";
    const thinkingLevel = (() => {
      const colors = COLORS.thinking(this.thinkingLevel);

      // Account for the glint effect
      if (this.glints.thinkingLevel.progress === 0) return colors.base + this.thinkingLevel;

      const glintIndex = Math.floor(
        (this.glints.thinkingLevel.progress / 100) * this.thinkingLevel.length,
      );
      return (
        // oxfmt-ignore
        (colors.base + this.thinkingLevel.slice(0, glintIndex)) +
        (colors.glint + this.thinkingLevel.slice(glintIndex, glintIndex + 1)) +
        (colors.base + this.thinkingLevel.slice(glintIndex + 1))
      );
    })();
    const cwd = COLORS.cwd + this.cwd;
    const cost = COLORS.cost + `$${this.cost.toFixed(2)}`;

    let sessionMetadata = [
      // oxfmt-ignore
      "   " + model + separator + thinkingLevel +' ',
      // We'd like `justify-content: space-between;` for the cwd and cost, but we cannot calculate the number of spaces
      // to print between them yet, since it depends on the total width of the session metadata section!
      // To work around this, leave 3 spaces between them for now, calculate the width, then use that width to set the
      // correct number of spaces. This works even if the model name + thinking level ends up being really short. We're
      // effectively guaranteeing that there will be at least 3 spaces between them.
      "   " + cwd + "   " + cost + " ",
    ];

    const sessionMetadataWidth = Math.max(
      visibleWidth(sessionMetadata[0]),
      visibleWidth(sessionMetadata[1]),
    );

    sessionMetadata[1] =
      "   " +
      cwd +
      " ".repeat(
        sessionMetadataWidth -
          this.cwd
            .length /* Subtract the length of the `cwd` string (the _value_, exclusing the control characters! */ -
          5 /* Subtract the length of the `cost` string (always 5 characters) */ -
          4 /* Account for the extra spaces */,
      ) +
      cost +
      " ";

    // Render the default editor, but strip out the top and bottom borders so we can render our own.
    super.setPaddingX(1);
    const lines = super
      .render(width - sessionMetadataWidth)
      // Filter out lines that are the border.
      // Using 3 ─s ensures we don't accidentally strip out prompt lines that actually have that unicode character
      .filter((l) => !l.includes("───"));

    return [
      // Custom top border, which is just an empty line with a background color
      COLORS.background + " ".repeat(width),

      // The prompt, `@` autocomplete, and everything else.
      // We'll render the first and second lines separately from the rest so we can append the session metadata to them.
      //
      // Pi suffixes the cursor with the terminal reset control character. We want the background color of the
      // entire prompt section to be the same, so surround each line with control characters to set the background
      // color to counteract this.
      COLORS.background +
        (lines[0] ?? " ".repeat(width - sessionMetadataWidth)) +
        COLORS.background +
        truncateToWidth(sessionMetadata[0], sessionMetadataWidth, "", true),

      COLORS.background +
        (lines[1] ?? " ".repeat(width - sessionMetadataWidth)) +
        COLORS.background +
        truncateToWidth(sessionMetadata[1], sessionMetadataWidth, "", true),

      // The remaining rendered lines.
      ...lines
        .slice(2)
        .map((l) => truncateToWidth(COLORS.background + l + COLORS.background, width, "", true)),

      // Custom bottom border, which is just an empty line with a background color
      COLORS.background + " ".repeat(width),

      // An extra empty line at the bottom so the editor does not stick to the bottom of the terminal for conversations
      // that span the full height
      "",
    ];
  }
}

function getSessionCost(ctx: ExtensionContext) {
  return ctx.sessionManager.getEntries().reduce((cost, e) => {
    switch (e.type) {
      case "message":
        if (e.message.role !== "assistant" && e.message.role !== "toolResult") break;
        return cost + (e.message.usage?.cost.total ?? 0);
      case "branch_summary":
      case "compaction":
        return cost + (e.usage?.cost.total ?? 0);
      default:
        break;
    }

    return cost;
  }, 0);
}

export default function (pi: ExtensionAPI) {
  let editor: Editor | undefined;

  pi.on("session_start", (_, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter(() => ({ render: () => [], invalidate() {} }));
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      editor = new Editor(tui, theme, keybindings);
      editor.model = ctx.model?.name ?? "(Unknown)";
      editor.thinkingLevel = ctx.thinkingLevel ?? "off";
      editor.cwd = basename(ctx.cwd);
      editor.cost = getSessionCost(ctx);
      return editor;
    });
  });

  pi.on("model_select", (e) => {
    if (!editor) return;

    editor.model = e.model.name;
    editor.enqueueGlint("model");
  });

  pi.on("thinking_level_select", (e) => {
    if (!editor) return;

    editor.thinkingLevel = e.level;
    editor.enqueueGlint("thinkingLevel");
  });

  pi.on("turn_end", (_, ctx) => {
    if (!editor) return;
    editor.cost = getSessionCost(ctx);
  });

  pi.on("session_shutdown", () => {
    if (!editor) return;

    editor.cancelGlint("model");
    editor.cancelGlint("thinkingLevel");
    editor = undefined;
  });
}
