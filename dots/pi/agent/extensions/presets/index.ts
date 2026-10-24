import type { CustomEntry, ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// A preset is a curated bundle of a model & a thinking level
const presets = [
  { name: "instant", provider: "openai", model: "gpt-6-sol", thinkingLevel: "low" },
  { name: "engineer", provider: "openai", model: "gpt-6.1-sol", thinkingLevel: "medium" },
  { name: "architect", provider: "openai", model: "gpt-6-astra", thinkingLevel: "xhigh" },
] as const;
type Preset = (typeof presets)[number];

export default function (pi: ExtensionAPI) {
  async function apply(preset: Preset, ctx: ExtensionContext) {
    const model = ctx.modelRegistry.find(preset.provider, preset.model);
    if (!model) return ctx.ui.notify(`Preset ${preset.name}: model not found.`, "error");

    // "Apply" the preset
    await pi.setModel(model);
    pi.setThinkingLevel(preset.thinkingLevel);

    // Also append a custom entry to the current session. This will be used to restore this preset if this session is
    // killed an resumed later.
    pi.appendEntry("presets:set", preset);

    // Set a custom status key so the `prompt` extension can use it to render the preset name instead of model +
    // thinking level (mostly for aesthetics).
    ctx.ui.setStatus("presets:name", preset.name);
  }

  pi.registerShortcut("ctrl+p", {
    description: "Next preset",
    handler: async (ctx) => {
      const thinkingLevel = ctx.thinkingLevel;
      const current = presets.findIndex(
        (p) =>
          p.provider === ctx.model?.provider &&
          p.model === ctx.model?.id &&
          p.thinkingLevel === thinkingLevel,
      );

      // Activate the next preset, cycling back to the first if we're at the end.
      if (current === -1) apply(presets[0], ctx);
      apply(presets[(current + 1) % presets.length], ctx);
    },
  });

  pi.registerShortcut("ctrl+shift+p", {
    description: "Previous preset",
    handler: async (ctx) => {
      const thinkingLevel = ctx.thinkingLevel;
      const current = presets.findIndex(
        (p) =>
          p.provider === ctx.model?.provider &&
          p.model === ctx.model?.id &&
          p.thinkingLevel === thinkingLevel,
      );

      // Activate the previous preset, cycling back to the last if we're at the first.
      if (current === -1) apply(presets[presets.length - 1], ctx);
      apply(presets[(current - 1 + presets.length) % presets.length], ctx);
    },
  });

  pi.on("session_start", async (e, ctx) => {
    // When new sessions start, default to activating the first preset.
    if (e.reason === "startup") return apply(presets[0], ctx);
    if (e.reason === "new") return apply(presets[0], ctx);

    // If this session is being restored, activate the last preset that was active before it was killed
    const preset = ctx.sessionManager
      .getEntries()
      .filter((e) => e.type === "custom" && e.customType === "presets:set")
      .at(-1);

    if (preset) apply((preset as CustomEntry).data as Preset, ctx);
  });

  // When models change outside of the presets, reset the custom status key we set in `apply` so the `prompt` extension
  // can fall back to showing the model + thinking level.
  pi.on("model_select", async (e, ctx) => {
    const model = ctx.model;
    const thinkingLevel = ctx.thinkingLevel;

    const preset = presets.find(
      (p) =>
        p.provider === model?.provider &&
        p.model === model?.id &&
        p.thinkingLevel === thinkingLevel,
    );
    if (preset) return;

    ctx.ui.setStatus("presets:name", undefined);
  });

  // When thinking levels change outside of the presets, reset the custom status key we set in `apply` so the `prompt`
  // extension can fall back to showing the model + thinking level.
  pi.on("thinking_level_select", async (e, ctx) => {
    const model = ctx.model;
    const thinkingLevel = ctx.thinkingLevel;

    const preset = presets.find(
      (p) =>
        p.provider === model?.provider &&
        p.model === model?.id &&
        p.thinkingLevel === thinkingLevel,
    );
    if (preset) return;

    ctx.ui.setStatus("presets:name", undefined);
  });
}
