module.exports = {
  defaultBrowser: "Safari",
  handlers: [
    {
      match: ({ opener }) =>
        opener.bundleId.startsWith("com.microsoft.") ||
        opener.bundleId === "com.todoist.mac.Todoist",
      browser: "Microsoft Edge"
    }
  ]
};
