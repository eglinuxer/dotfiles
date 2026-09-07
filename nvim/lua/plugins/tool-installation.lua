-- Keep installed tools usable; installation/update is an explicit user action.
return {
  { "mason-org/mason.nvim", opts = { registry_cache = { refresh = false } } },
  { "WhoIsSethDaniel/mason-tool-installer.nvim", opts = { run_on_start = false, auto_update = false } },
}
