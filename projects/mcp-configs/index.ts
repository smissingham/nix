import { readFileSync, writeFileSync, mkdirSync } from "fs";
import path from "path";
import { server } from "typescript";
import { execSync } from "child_process";

enum McpCategory {
  Assistants,
  GeneralPurpose,
  Coding,
  Research,
  Pricefx,
}

const userHome = process.env.HOME;
const xdgConf = process.env.XDG_CONFIG_HOME;

// common format configs
// ---------- MCP Hub ---------- //
// writeJsonFile(`${xdgConf}/mcphub/servers.json`, {
//   mcpServers: {
//     ...getMcpServers(McpCategory.GeneralPurpose),
//     ...getMcpServers(McpCategory.Coding),
//     ...getMcpServers(McpCategory.Research),
//     ...getMcpServers(McpCategory.McpDev),
//   },
// });

// ---------- Claude Desktop ---------- //
// writeJsonFile(
//   `${userHome}/Library/Application Support/Claude/claude_desktop_config.json`,
//   {
//     mcpServers: {
//       // ...getMcpServers(McpCategory.GeneralPurpose),
//       // ...getMcpServers(McpCategory.Research),
//       // ...getMcpServers(McpCategory.Assistants),
//       ...getMcpServers(McpCategory.McpDev),
//       // ...getMcpServers(McpCategory.McpTest),
//     },
//   },
// );

// ~Special~ people who want their own ~special~ format
// ---------- Open Code ---------- //
// get existing config file from ~/.config/opencode/
const openCodeConfigPath = `${xdgConf}/opencode/opencode.json`;
let openCodeConfig = JSON.parse(readFileSync(openCodeConfigPath, "utf8"));
openCodeConfig.mcp = Object.entries({
  // ...getMcpServers(McpCategory.Assistants),
  // ...getMcpServers(McpCategory.GeneralPurpose),
  ...getMcpServers(McpCategory.Coding),
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
    acc[key].command = [getBin(value.command), ...(value.args || [])];
  } else if (serverType === "remote") {
    acc[key].url = value.url;
  }
  return acc;
}, {});
writeJsonFile(openCodeConfigPath, openCodeConfig);

function writeJsonFile(filePath: string, serversConfig: any) {
  const dirPath = path.dirname(filePath);
  mkdirSync(dirPath, { recursive: true });
  writeFileSync(filePath, JSON.stringify(serversConfig, null, 2));
  console.log(`[${isoString()}]: Wrote ${filePath}`);
}

function isoString() {
  const date = new Date();
  date.setMilliseconds(0);
  return date.toISOString().slice(0, -5);
}

function getBin(binName: string): string {
  return execSync(`which ${binName}`).toString().trim();
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
            "exec $(which bunx) -y @modelcontextprotocol/server-memory",
          ],
          command: "sh",
        },
        "sequential-thinking": {
          args: [
            "-c",
            "exec $(which bunx) -y @modelcontextprotocol/server-sequential-thinking",
          ],
          command: "sh",
        },
        time: {
          args: ["mcp-server-time", "--local-timezone=America/Chicago"],
          command: "uvx",
          disabled: false,
        },
        "prompt-lib": {
          command: "bunx",
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
        context7: {
          command: "bunx",
          args: ["-y", "@upstash/context7-mcp"],
          env: {
            CONTEXT7_API_KEY: "{env:CONTEXT7_API_KEY}",
          },
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
          args: ["-c", "exec $(which bunx) -y mcp-searxng@latest"],
          command: "sh",
          disabled: false,
          env: {
            SEARXNG_URL: "https://searxng.coeus.missingham.net",
          },
        },
      };

    case McpCategory.Pricefx:
      return {
        pricefx_streamable_http: {
          disabled: false,
          type: "remote",
          url: "https://mcp.pricefx.com/mcp",
        },
        pricefx_dev_local: {
          disabled: false,
          type: "local",
          args: [
            "--cwd",
            "/Users/smissingham/Documents/Employer/10-product/pricefx-mcp",
            "dev:local",
          ],
          env: {
            SERVER_LOG:
              "/Users/smissingham/Documents/Employer/10-product/pricefx-mcp/logs/server.log",
            PRICEFX_DOMAIN: "{env:PRICEFX_DEMO_DOMAIN}",
            PRICEFX_PARTITION: "{env:PRICEFX_DEMO_PARTITION}",
            PRICEFX_USERNAME: "{env:PRICEFX_DEMO_USERNAME}",
            PRICEFX_PASSWORD: "{env:PRICEFX_DEMO_PASSWORD}",
          },
          command: "bun",
        },
        // pricefx_dev_remote: {
        //   disabled: true,
        //   type: "remote",
        //   url: "http://localhost:3001/mcp",
        // },
        pricefx_dist_npm: {
          disabled: false,
          args: [
            "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp/dist/npm/local.js",
          ],
          env: {
            PRICEFX_DOMAIN: "{env:PRICEFX_DEMO_DOMAIN}",
            PRICEFX_PARTITION: "{env:PRICEFX_DEMO_PARTITION}",
            PRICEFX_USERNAME: "{env:PRICEFX_DEMO_USERNAME}",
            PRICEFX_PASSWORD: "{env:PRICEFX_DEMO_PASSWORD}",
          },
          command: "bun",
        },
        pricefx_dist_claude: {
          disabled: false,
          args: [
            "/Users/smissingham/Documents/Employer/01-tools/llm-tools/pricefx-mcp/dist/claude_desktop/local.js",
          ],
          env: {
            PRICEFX_DOMAIN: "{env:PRICEFX_DEMO_DOMAIN}",
            PRICEFX_PARTITION: "{env:PRICEFX_DEMO_PARTITION}",
            PRICEFX_USERNAME: "{env:PRICEFX_DEMO_USERNAME}",
            PRICEFX_PASSWORD: "{env:PRICEFX_DEMO_PASSWORD}",
          },
          command: "bun",
        },
      };
  }
}
