import { readFileSync, writeFileSync, mkdirSync } from "fs";
import path from "path";
import { server } from "typescript";

enum McpCategory {
  Assistants,
  GeneralPurpose,
  Coding,
  Research,
  McpDev,
  McpTest,
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
    ...getMcpServers(McpCategory.McpDev),
  },
});

// ---------- Claude Desktop ---------- //
writeJsonFile(
  `${userHome}/Library/Application Support/Claude/claude_desktop_config.json`,
  {
    mcpServers: {
      // ...getMcpServers(McpCategory.GeneralPurpose),
      // ...getMcpServers(McpCategory.Research),
      // ...getMcpServers(McpCategory.Assistants),
      ...getMcpServers(McpCategory.McpDev),
      // ...getMcpServers(McpCategory.McpTest),
    },
  },
);

// ~Special~ people who want their own ~special~ format
// ---------- Open Code ---------- //
// get existing config file from ~/.config/opencode/
const openCodeConfigPath = `${xdgConf}/opencode/opencode.json`;
let openCodeConfig = JSON.parse(readFileSync(openCodeConfigPath, "utf8"));
openCodeConfig.mcp = Object.entries({
  // ...getMcpServers(McpCategory.Assistants),
  // ...getMcpServers(McpCategory.GeneralPurpose),
  // ...getMcpServers(McpCategory.Coding),
  // ...getMcpServers(McpCategory.Research),
  //...getMcpServers(McpCategory.McpDev),
}).reduce((acc: Record<string, any>, [key, value]: [string, any]) => {
  const serverType = value.type ?? "local";
  acc[key] = {
    type: serverType,
    enabled: value.disabled ? false : true,
    environment: value.env,
  };
  if (serverType === "local") {
    acc[key].command = [value.command, ...(value.args || [])];
  } else if (serverType === "remote") {
    acc[key].url = value.url;
  }
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
    case McpCategory.Assistants:
      return {
        // playwright: {
        //   args: [
        //     "-c",
        //     "exec $(which bunx) -y @modelcontextprotocol/server-playwright --install",
        //   ],
        //   command: "/bin/sh",
        // },
        // travelDocuments: {
        //   args: [
        //     "-c",
        //     "exec $(which npx) -y @modelcontextprotocol/server-filesystem ~/Documents/Obsidian/second-brain/Travel/",
        //   ],
        //   command: "/bin/sh",
        //   disabled: false,
        // },
        // travelRipgrep: {
        //   args: ["-c", "exec $(which npx) -y mcp-ripgrep@latest"],
        //   command: "/bin/sh",
        //   disabled: false,
        //   env: {
        //     RIPGREP_PATH: "~/Documents/Obsidian/second-brain/Travel/",
        //   },
        // },
      };
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
        // userDocuments: {
        //   args: [
        //     "-c",
        //     "exec $(which npx) -y @modelcontextprotocol/server-filesystem ~/Documents/",
        //   ],
        //   command: "/bin/sh",
        //   disabled: true,
        // },
      };
    case McpCategory.Research:
      return {
        searxng: {
          args: ["-c", "exec $(which npx) -y mcp-searxng@latest"],
          command: "/bin/sh",
          disabled: false,
          env: {
            SEARXNG_URL: "https://searxng.coeus.missingham.net",
          },
        },
      };
    case McpCategory.McpDev:
      return {
        // plib_dev: {
        //   disabled: true,
        //   args: [
        //     "--cwd",
        //     "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp",
        //     "dev",
        //   ],
        //   env: {
        //     SERVER_NAME: "plib_live",
        //     DEFAULT_PROMPTS: "true",
        //     SERVER_LOG:
        //       "/Users/smissingham/Documents/Nix/projects/prompt-library-mcp/logs/server.log",
        //     LIBRARY_PATH:
        //       "/Users/smissingham/Documents/Obsidian/second-brain/@Public/GenAI/Prompts/",
        //   },
        //   command: "bun",
        // },
        pricefx_dev_local: {
          disabled: false,
          type: "local",
          args: [
            "--cwd",
            "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp",
            "dev:local",
          ],
          env: {
            SERVER_LOG:
              "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp/logs/server.log",
          },
          command: "/run/current-system/sw/bin/bun",
        },
        // pricefx_dev_remote: {
        //   disabled: true,
        //   type: "remote",
        //   url: "http://localhost:3001/mcp",
        // },
      };
    case McpCategory.McpTest:
      return {
        pricefx_dist_npm: {
          disabled: false,
          args: [
            "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp/dist/npm/local.js",
          ],
          env: {
            PRICEFX_DOMAIN: "demo.pricefx.com",
            PRICEFX_PARTITION: "demofx_smissingham",
            PRICEFX_USERNAME: "sean+mcp",
            PRICEFX_PASSWORD: "FZv3ZWydN9rXANALNyJK3O9Z",
          },
          command: "/run/current-system/sw/bin/node",
        },
        pricefx_dist_claude: {
          disabled: false,
          args: [
            "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp/dist/claude_desktop/local.js",
          ],
          env: {
            PRICEFX_DOMAIN: "demo.pricefx.com",
            PRICEFX_PARTITION: "demofx_smissingham",
            PRICEFX_USERNAME: "sean+mcp",
            PRICEFX_PASSWORD: "FZv3ZWydN9rXANALNyJK3O9Z",
          },
          command: "/run/current-system/sw/bin/node",
        },
      };
  }
}
