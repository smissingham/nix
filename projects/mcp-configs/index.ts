import { readFileSync, writeFileSync, mkdirSync } from "fs";
import path from "path";

enum McpCategory {
  GeneralPurpose,
  Coding,
  Research,
}

const xdgConf = process.env.XDG_CONFIG_HOME;

// common format configs
// ---------- MCP Hub ---------- //
writeJsonFile(`${xdgConf}/mcphub/servers.json`, {
  mcpServers: {
    ...getMcpServers(McpCategory.GeneralPurpose),
    ...getMcpServers(McpCategory.Coding),
    ...getMcpServers(McpCategory.Research),
  },
});

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
  mkdirSync(dirPath, { recursive: true });
  writeFileSync(filePath, JSON.stringify(serversConfig, null, 2));
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
        test_prompt_library: {
          disabled: true,
          args: [
            "--watch",
            "run",
            "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/",
          ],
          env: {
            SERVER_NAME: "test_p_lib",
            SERVER_LOG:
              "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/server.log",
            LIBRARY_PATH:
              "/Users/smissingham/Documents/Obsidian/second-brain/@Public/GenAI/Prompts/",
          },
          command: "bun",
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
  }
}
