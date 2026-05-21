return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        taplo = {
          settings = {
            taplo = {
              schema = {
                associations = {
                  [".*sesh\\.toml$"] = "https://github.com/joshmedeski/sesh/raw/main/sesh.schema.json",
                },
              },
            },
          },
        },
      },
    },
  },
}
