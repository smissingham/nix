import { writeFileSync, mkdirSync } from "fs";
import path from "path";

enum McpCategory {
  GeneralPurpose,
  Coding,
  Research,
}

const xdgConf = process.env.XDG_CONFIG_HOME;
const autoDots = `${process.env.NIX_CONFIG_HOME}/dots/auto`;

writeServersConfig(`${xdgConf}/mcphub/servers.json`, {
  mcpServers: {
    ...getMcpServers(McpCategory.GeneralPurpose),
    ...getMcpServers(McpCategory.Coding),
    ...getMcpServers(McpCategory.Research),
  },
});

function writeServersConfig(filePath: string, serversConfig: any) {
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
