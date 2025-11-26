return {
  "scalameta/nvim-metals",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "scala", "sbt" },
  config = function()
    local metals_config = require("metals").bare_config()

    -- Example: enable status line integration
    metals_config.init_options.statusBarProvider = "on"

    -- Autocmd to start Metals when opening Scala/SBT files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
    })
  end,
}
