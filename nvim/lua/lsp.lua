local on_init = function(client, _)
    client.server_capabilities.semanticTokensProvider = nil
end

require("lspconfig").clangd.setup {
    on_init = on_init,
}
require("lspconfig").pyright.setup {
    on_init = on_init,
}
require("lspconfig").rust_analyzer.setup {
    on_init = on_init,
}
require("lspconfig").gopls.setup {
    on_init = on_init,
}
require("lspconfig").lua_ls.setup {
    on_init = on_init,
    settings = {
        Lua = {
            runtime = {
                version = "Lua 5.4",
            },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
}
