-- Completion engine for native LSP (coc bundled its own; native LSP does not).
return {
  "saghen/blink.cmp",
  version = "*", -- release tag ships a prebuilt fuzzy-matcher binary (no Rust toolchain needed)
  event = "InsertEnter",
  opts = {
    -- default preset: <C-y> accept, <C-space> open/docs, <C-e> cancel,
    -- <C-n>/<C-p> (and arrows) to select.
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = { documentation = { auto_show = true } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
