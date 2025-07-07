export default {
  defaultBrowser: "Orion",
  handlers: [
    {
      match: (_url, app) =>
        app.bundleId?.startsWith("com.microsoft.") ||
        app.bundleId === "com.todoist.mac.Todoist",
      browser: "Microsoft Edge"
    }
  ]
};