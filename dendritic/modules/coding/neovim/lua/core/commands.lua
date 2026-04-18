vim.api.nvim_create_user_command("ReloadConfig", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^core") or name:match("^plugins") or name:match("^lsp") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify(string.format("Reloaded %s", vim.env.MYVIMRC))
end, {})
