import type { Plugin } from "@opencode-ai/plugin"

const providers = {
  "pricefx-local": { url: "PFX_GW_URL", key: "PFX_GW_KEY_LOCAL" },
  "pricefx-bedrock": { url: "PFX_GW_URL", key: "PFX_GW_KEY_BEDROCK" },
} as const

export default (async () => ({
  async config(config) {
    for (const [providerID, env] of Object.entries(providers)) {
      const provider = config.provider?.[providerID]
      const baseURL = process.env[env.url]
      const apiKey = process.env[env.key]
      if (!provider || !baseURL || !apiKey) continue
      try {
        const response = await fetch(`${baseURL.replace(/\/$/, "")}/models`, {
          headers: { Authorization: `Bearer ${apiKey}` },
          signal: AbortSignal.timeout(10000),
        })
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        const payload: unknown = await response.json()
        if (!payload || typeof payload !== "object" || !("data" in payload) || !Array.isArray(payload.data)) {
          throw new Error("Invalid model list")
        }

        const models = Object.fromEntries(payload.data.flatMap((model: unknown) => {
          if (!model || typeof model !== "object" || !("id" in model) || typeof model.id !== "string" || !model.id) {
            throw new Error("Invalid model ID")
          }
          if ("mode" in model && model.mode !== "chat") return []
          // ponytail: conservative limits when metadata is absent; override per model for larger contexts.
          const context = "max_input_tokens" in model && typeof model.max_input_tokens === "number" && Number.isFinite(model.max_input_tokens) && model.max_input_tokens >= 4
            ? model.max_input_tokens : 32768
          const output = "max_output_tokens" in model && typeof model.max_output_tokens === "number" && Number.isFinite(model.max_output_tokens) && model.max_output_tokens > 0
            ? model.max_output_tokens : 4096
          return [[model.id, {
            name: model.id,
            limit: { context, output: Math.min(4096, output, Math.floor(context / 4)) },
            ...provider.models?.[model.id],
          }]]
        }))
        if (!Object.keys(models).length) throw new Error("No chat models returned")
        provider.models = models
      } catch (error) {
        console.warn(`${providerID} model discovery failed; retaining configured models:`, error instanceof Error ? error.message : "Unknown error")
      }
    }
  },
})) satisfies Plugin
