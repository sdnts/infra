import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { mkdir } from "node:fs/promises";
import { dirname, join } from "node:path";

const execFileAsync = promisify(execFile);

const FOCUS_TAB_APPLESCRIPT = `
on run argv
  set matchText to item 1 of argv as text
  tell application "Safari"
    activate
    if matchText is "" then return "ok"
    set found to false
    repeat with w in windows
      repeat with t in tabs of w
        if (name of t contains matchText) or (URL of t contains matchText) then
          set current tab of w to t
          set index of w to 1
          set found to true
          exit repeat
        end if
      end repeat
      if found then exit repeat
    end repeat
    if not found then return "notfound"
  end tell
  return "ok"
end run`;

const LIST_TABS_APPLESCRIPT = `
tell application "Safari"
  set out to ""
  repeat with w in windows
    repeat with t in tabs of w
      set out to out & name of t & " | " & URL of t & linefeed
    end repeat
  end repeat
  return out
end tell`;

// Swift one-liner: print the CGWindowID of the frontmost Safari window
// (front-to-back order, owner "Safari", layer 0).
const GET_WINDOW_ID_SWIFT = `
import CoreGraphics
import Foundation
if let list = CGWindowListCopyWindowInfo(CGWindowListOption(rawValue: 17), kCGNullWindowID) as? [[String: Any]] {
  for w in list {
    if let owner = w[kCGWindowOwnerName as String] as? String, owner == "Safari",
       let layer = w[kCGWindowLayer as String] as? Int, layer == 0,
       let num = w[kCGWindowNumber as String] as? Int {
      print(num)
      break
    }
  }
}`;

const GET_FRONTMOST_APP_APPLESCRIPT = `
tell application "System Events" to get name of first application process whose frontmost is true`;

const RESTORE_APP_APPLESCRIPT = `
on run argv
  tell application (item 1 of argv as text) to activate
end run`;

async function run(cmd: string, args: string[]): Promise<string> {
  const { stdout } = await execFileAsync(cmd, args, { timeout: 15_000 });
  return stdout.trim();
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "webshot",
    label: "Webshot",
    description: `Take a screenshot of a tab in Safari (macOS only). Bring the tab to the front and capture just that browser window as a PNG. Returns the path where the image was saved.`,
    promptSnippet: "Screenshot a Safari tab by title/URL match",
    promptGuidelines: [
      "Use webshot when the user wants to capture what is currently shown in a Safari tab.",
    ],
    parameters: Type.Object({
      match: Type.Optional(
        Type.String({
          description:
            "Case-sensitive substring to find the tab, matched against the " +
            "tab title and URL (e.g. 'github.com' or 'YouTube'). " +
            "Omit to capture the current frontmost tab.",
        }),
      ),
      outputPath: Type.Optional(
        Type.String({
          description: "Where to save the PNG. Defaults to <cwd>/.pi/webshot/<timestamp>.png",
        }),
      ),
    }),
    execute: async (_toolCallId, params, signal, _onUpdate, ctx) => {
      if (signal?.aborted) return { content: [{ type: "text", text: "Cancelled" }], details: {} };

      if (process.platform !== "darwin") throw new Error("webshot only works on macOS.");

      const match = params.match ?? "";
      const outputPath = params.outputPath ?? join(ctx.cwd, ".pi", "webshot", `${Date.now()}.png`);

      // Ensure the output directory exists.
      await mkdir(dirname(outputPath), { recursive: true });

      // 0. Remember the frontmost app so we can restore focus afterwards.
      const previousApp = await run("osascript", ["-e", GET_FRONTMOST_APP_APPLESCRIPT]).catch(
        () => null,
      );
      const restoreFocus = async () => {
        if (!previousApp || previousApp === "Safari") return;
        await run("osascript", ["-e", RESTORE_APP_APPLESCRIPT, previousApp]).catch(() => {});
      };

      // 1. Focus the tab (and activate Safari).
      const result = await run("osascript", ["-e", FOCUS_TAB_APPLESCRIPT, match]);
      if (result === "notfound") {
        const tabs = await run("osascript", ["-e", LIST_TABS_APPLESCRIPT]).catch(() => null);
        await restoreFocus();

        throw new Error(
          `No Safari tab matches "${match}" (checked tab titles and URLs).` +
            (tabs ? `\n\nOpen tabs:\n${tabs}` : ""),
        );
      }

      // 2. Capture the window. Retry the whole sequence, since focus can shift (e.g. Safari on another Space) between
      // activation and capture.
      try {
        await new Promise<void>(async (resolve, reject) => {
          let error = null;

          for (let attempt = 0; attempt < 3; attempt++) {
            await new Promise((r) => setTimeout(r, 500));

            try {
              const windowId = await run("swift", ["-e", GET_WINDOW_ID_SWIFT]);
              if (windowId) {
                await run("screencapture", ["-x", "-o", "-l", windowId, outputPath]);
                return resolve();
              } else {
                error = "no visible Safari window found";
                // Re-activate; Safari may be on another Space or got switched away.
                await run("osascript", ["-e", 'tell application "Safari" to activate']);
              }
            } catch (err) {
              error = err;
            }
          }

          return reject(error);
        });
      } catch (e) {
        await restoreFocus();

        throw new Error(
          `Error capturing Safari window. If this is a permissions issue, grant Screen Recording access to your terminal app (System Settings > Privacy & Security > Screen Recording) and restart the terminal.`,
        );
      }

      // 3. Return focus to where the user was, then return the path.
      await restoreFocus();
      const matchedText = match ? `matching "${match}"` : "(frontmost tab)";
      return {
        content: [
          {
            type: "text",
            text: `Screenshot of Safari tab ${matchedText} saved to ${outputPath}`,
          },
        ],
        details: { path: outputPath, match },
      };
    },
  });
}
