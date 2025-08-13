import { readFileSync, writeFileSync, mkdirSync } from "fs";
import path from "path";

enum McpCategory {
  GeneralPurpose,
  Coding,
  Research,
  McpTesting,
}

const userHome = process.env.HOME;
const xdgConf = process.env.XDG_CONFIG_HOME;

// common format configs
// ---------- MCP Hub ---------- //
writeJsonFile(`${xdgConf}/mcphub/servers.json`, {
  mcpServers: {
    ...getMcpServers(McpCategory.GeneralPurpose),
    ...getMcpServers(McpCategory.Coding),
    ...getMcpServers(McpCategory.Research),
    ...getMcpServers(McpCategory.McpTesting),
  },
});

// ---------- Claude Desktop ---------- //
writeJsonFile(
  `${userHome}/Library/Application Support/Claude/claude_desktop_config.json`,
  {
    mcpServers: {
      ...getMcpServers(McpCategory.GeneralPurpose),
      ...getMcpServers(McpCategory.Research),
      ...getMcpServers(McpCategory.McpTesting),
    },
  },
);

// ~Special~ people who want their own ~special~ format
// ---------- Open Code ---------- //
// get existing config file from ~/.config/opencode/
const openCodeConfigPath = `${xdgConf}/opencode/opencode.json`;
let openCodeConfig = JSON.parse(readFileSync(openCodeConfigPath, "utf8"));
openCodeConfig.mcp = Object.entries({
  ...getMcpServers(McpCategory.GeneralPurpose),
  ...getMcpServers(McpCategory.Coding),
  ...getMcpServers(McpCategory.Research),
}).reduce((acc: Record<string, any>, [key, value]: [string, any]) => {
  acc[key] = {
    type: "local",
    enabled: value.disabled ? false : true,
    command: [value.command, ...value.args],
    environment: value.env,
  };
  return acc;
}, {});
writeJsonFile(openCodeConfigPath, openCodeConfig);

function writeJsonFile(filePath: string, serversConfig: any) {
  const dirPath = path.dirname(filePath);
  console.log("DirPath:" + dirPath);
  mkdirSync(dirPath, { recursive: true });
  writeFileSync(filePath, JSON.stringify(serversConfig, null, 2));
  console.log(`[${isoString()}]: Wrote ${filePath}`);
}

function isoString() {
  const date = new Date();
  date.setMilliseconds(0);
  return date.toISOString().slice(0, -5);
}

function getMcpServers(category: McpCategory) {
  switch (category) {
    case McpCategory.GeneralPurpose:
      return {
        memory: {
          args: [
            "-c",
            "exec $(which npx) -y @modelcontextprotocol/server-memory",
          ],
          command: "/bin/sh",
        },
        "sequential-thinking": {
          args: [
            "-c",
            "exec $(which npx) -y @modelcontextprotocol/server-sequential-thinking",
          ],
          command: "/bin/sh",
        },
        time: {
          args: ["mcp-server-time", "--local-timezone=America/Chicago"],
          command: "uvx",
          disabled: false,
        },
        "prompt-lib": {
          command: "npx",
          args: ["-y", "prompt-library-mcp@latest"],
          env: {
            LIBRARY_PATH:
              "/Users/smissingham/Documents/Obsidian/second-brain/@Public/GenAI/Prompts/",
            DEFAULT_PROMPTS: "true",
            SERVER_NAME: "Personal Prompt Library",
          },
        },
      };
    case McpCategory.Coding:
      return {
        git: {
          args: ["mcp-server-git"],
          command: "uvx",
        },
        ripgrep: {
          args: ["-c", "exec $(which npx) -y mcp-ripgrep@latest"],
          command: "/bin/sh",
          disabled: false,
        },
        userDocuments: {
          args: [
            "-c",
            "exec $(which npx) -y @modelcontextprotocol/server-filesystem ~/Documents/",
          ],
          command: "/bin/sh",
          disabled: false,
        },
      };
    case McpCategory.Research:
      return {
        searxng: {
          args: ["-c", "exec $(which npx) -y mcp-searxng@latest"],
          command: "/bin/sh",
          disabled: false,
          env: {
            SEARXNG_URL: "HTTPS://SEARXNG.COEUS.MISSINGHAM.NET",
          },
        },
      };
    case McpCategory.McpTesting:
      return {
        plib_dev: {
          disabled: true,
          args: [
            "--cwd",
            "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp",
            "dev",
          ],
          env: {
            SERVER_NAME: "plib_live",
            DEFAULT_PROMPTS: "true",
            SERVER_LOG:
              "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/logs/server.log",
            LIBRARY_PATH:
              "/Users/smissingham/Documents/Obsidian/second-brain/@Public/GenAI/Prompts/",
          },
          command: "bun",
        },
        pricefx: {
          disabled: true,
          args: [
            "--cwd",
            "/Users/smissingham/Documents/Pricefx/01-tools/pricefx-mcp",
            "dev",
          ],
          env: {
            SERVER_NAME: "demofx_smissingham",
            SERVER_LOG:
              "/Users/smissingham/Documents/Pricefx/01-tools/pricefx-mcp/logs/server.log",
          },
          command: "/run/current-system/sw/bin/bun",
        },
        // plib_dist: {
        //   disabled: true,
        //   args: [
        //     "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/dist/index.js",
        //   ],
        //   env: {
        //     SERVER_NAME: "plib_dist",
        //     DEFAULT_PROMPTS: "true",
        //     SERVER_LOG:
        //       "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/logs/server.log",
        //     LIBRARY_PATH:
        //       "/Users/smissingham/Documents/Obsidian/second-brain/@Public/GenAI/Prompts/",
        //   },
        //   command: "node",
        // },
      };
  }
}
