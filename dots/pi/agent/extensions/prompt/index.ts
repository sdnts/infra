import { basename } from "node:path";
import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const PROMPT_STYLE = "\x1b[48;2;48;48;48m\x1b[38;2;229;229;229m";
const THINKING_COLORS = {
  default: { base: [140, 140, 140], shine: [255, 255, 255] },
  xhigh: { base: [209, 154, 102], shine: [255, 195, 122] },
  max: { base: [170, 138, 204], shine: [220, 184, 255] },
} as const;
const SHINE_DURATION_MS = 200;
const SHINE_FRAME_MS = 20;

function foreground([red, green, blue]: readonly number[]): string {
  return `\x1b[38;2;${red};${green};${blue}m`;
}

const STATUS_STYLE = foreground(THINKING_COLORS.default.base);
const DIRECTORY_STYLE = "\x1b[38;2;105;105;105m";
const COST_STYLE = "\x1b[38;2;75;75;75m";
const RESET = "\x1b[0m";

class PromptEditor extends CustomEditor {
  private modelName = "";
  private thinkingLevel: string | undefined;
  private directory = "";
  private modelShineStartedAt: number | undefined;
  private thinkingShineStartedAt: number | undefined;
  private shineTimer: ReturnType<typeof setInterval> | undefined;
  getCost: () => number = () => 0;
  getPresetName: () => string | undefined = () => undefined;

  // Pi copies the configurable editor padding onto custom editors after creation.
  // This prompt always reserves one cell on each side of its terminal region.
  override setPaddingX(_padding: number): void {
    super.setPaddingX(1);
  }

  setStatus(modelName: string, thinkingLevel: string, directory: string): void {
    const now = Date.now();
    if (this.modelName && this.modelName !== modelName) {
      this.modelShineStartedAt = now;
    }
    if (this.thinkingLevel !== undefined && this.thinkingLevel !== thinkingLevel) {
      this.thinkingShineStartedAt =
        thinkingLevel === "xhigh" || thinkingLevel === "max" ? now : undefined;
    }
    if (this.modelShineStartedAt !== undefined || this.thinkingShineStartedAt !== undefined) {
      this.shineTimer ??= setInterval(() => {
        const now = Date.now();
        if (
          this.modelShineStartedAt !== undefined &&
          now - this.modelShineStartedAt >= SHINE_DURATION_MS
        ) {
          this.modelShineStartedAt = undefined;
        }
        if (
          this.thinkingShineStartedAt !== undefined &&
          now - this.thinkingShineStartedAt >= SHINE_DURATION_MS
        ) {
          this.thinkingShineStartedAt = undefined;
        }
        if (this.modelShineStartedAt === undefined && this.thinkingShineStartedAt === undefined) {
          this.stopShine();
        }
        this.tui.requestRender();
      }, SHINE_FRAME_MS);
    }
    this.modelName = modelName;
    this.thinkingLevel = thinkingLevel;
    this.directory = directory;
    this.tui.requestRender();
  }

  stopShine(): void {
    if (this.shineTimer !== undefined) clearInterval(this.shineTimer);
    this.shineTimer = undefined;
    this.modelShineStartedAt = undefined;
    this.thinkingShineStartedAt = undefined;
  }

  private renderShine(
    text: string,
    colors: { base: readonly number[]; shine: readonly number[] },
    startedAt: number | undefined,
  ): string {
    if (startedAt === undefined) {
      return foreground(colors.base) + text;
    }

    // Move a soft highlight across the letters without changing their width.
    const progress = Math.min(1, (Date.now() - startedAt) / SHINE_DURATION_MS);
    const letters = [...text];
    const position = -1 + progress * (letters.length + 1);
    return letters
      .map((letter, index) => {
        const strength = Math.max(0, 1 - Math.abs(index - position) / 1.5);
        const color = colors.base.map((base, channel) =>
          Math.round(base + (colors.shine[channel] - base) * strength),
        );
        return foreground(color) + letter;
      })
      .join("");
  }

  private renderThinkingLevel(): string {
    const level = this.thinkingLevel ?? "";
    const colors =
      level === "max"
        ? THINKING_COLORS.max
        : level === "xhigh"
          ? THINKING_COLORS.xhigh
          : THINKING_COLORS.default;
    return this.renderShine(level, colors, this.thinkingShineStartedAt);
  }

  override render(width: number): string[] {
    const labelWidth = Math.max(0, Math.floor(width / 2) - 3);
    const labels = [
      {
        text:
          this.getPresetName() ??
          `${this.renderShine(this.modelName, THINKING_COLORS.default, this.modelShineStartedAt)}${STATUS_STYLE} · ${this.renderThinkingLevel()}`,
        style: STATUS_STYLE,
      },
      {
        text: `${this.directory}  ${COST_STYLE}$${this.getCost().toFixed(3)}`,
        style: DIRECTORY_STYLE,
      },
    ].map(({ text, style }) => ({ text: truncateToWidth(text, labelWidth, ""), style }));
    const sidebarContentWidth = Math.max(...labels.map(({ text }) => visibleWidth(text)));
    const sidebarWidth = sidebarContentWidth > 0 ? sidebarContentWidth + 3 : 0;

    // Mark the border rows temporarily to locate the prompt independently of
    // autocomplete rows. These markers are removed before anything is displayed.
    const borderMarker = "\0";
    const borderColor = this.borderColor;
    this.borderColor = (text) => borderMarker + text.replaceAll("─", " ");

    try {
      const lines = super.render(width - sidebarWidth);
      const bottomBorder = lines.findIndex(
        (line, index) => index > 0 && line.includes(borderMarker),
      );
      // Reuse the sidebar's extra padding below autocomplete when it is open.
      // This gives the last suggestion breathing room without adding height.
      const hasCompletions = lines.length > bottomBorder + 1;
      const padding = " ".repeat(width - sidebarWidth);
      lines.splice(hasCompletions ? lines.length : bottomBorder, 0, padding);
      const middleRow = Math.floor(bottomBorder / 2);

      for (let row = 0; row < lines.length; row++) {
        const line = lines[row].replaceAll(borderMarker, "");
        const { text: label = "", style = "" } = labels[row - middleRow] ?? {};
        const sidebar = label
          ? " ".repeat(sidebarWidth - visibleWidth(label) - 1) + style + label + RESET + " "
          : " ".repeat(sidebarWidth);
        lines[row] =
          line + " ".repeat(Math.max(0, width - sidebarWidth - visibleWidth(line))) + sidebar;
      }

      return [
        ...lines.map(
          // The built-in cursor resets ANSI styles; restore the prompt colors after it.
          (line) => PROMPT_STYLE + line.replaceAll(RESET, RESET + PROMPT_STYLE) + RESET,
        ),
        "",
      ];
    } finally {
      this.borderColor = borderColor;
    }
  }
}

function getSessionCost(ctx: ExtensionContext): number {
  // Match Pi's footer, including nested model calls and compaction summaries.
  let cost = 0;
  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "message") {
      const message = entry.message;
      if (message.role === "assistant" || message.role === "toolResult") {
        cost += message.usage?.cost.total ?? 0;
      }
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      cost += entry.usage?.cost.total ?? 0;
    }
  }
  return cost;
}

export default function (pi: ExtensionAPI) {
  let editor: PromptEditor | undefined;
  let getPresetName: () => string | undefined = () => undefined;

  const updateStatus = (ctx: ExtensionContext) => {
    editor?.setStatus(
      ctx.model?.name ?? "No model",
      pi.getThinkingLevel(),
      basename(ctx.cwd) || ctx.cwd,
    );
  };

  pi.on("session_start", (_, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      editor = new PromptEditor(tui, theme, keybindings);
      editor.setPaddingX(1);
      editor.getCost = () => getSessionCost(ctx);
      editor.getPresetName = () => getPresetName();
      updateStatus(ctx);
      return editor;
    });

    ctx.ui.setFooter((_tui, _theme, footerData) => {
      // Read live statuses: setStatus() already requests a render, including when
      // presets change after the model/thinking-level events have fired.
      getPresetName = () => footerData.getExtensionStatuses().get("presets:name");
      return { render: () => [], invalidate() {} };
    });
  });

  pi.on("model_select", (_event, ctx) => updateStatus(ctx));
  pi.on("thinking_level_select", (_event, ctx) => updateStatus(ctx));
  pi.on("session_shutdown", () => {
    editor?.stopShine();
    editor = undefined;
  });
}
