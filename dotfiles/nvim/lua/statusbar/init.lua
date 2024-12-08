local M = {}

function M.statusline()

  local parts = {

    "%#sep#",
    " ",
    "%#stl#",
    AccentColor(),
    Mode(),
    "%#sep#",
    " ",
    "%#stl#",
    -- Filename(),
    Lspstatus(),
    -- " %f ",
    "%=",
    -- "%#PmenuSel#",
    -- " LSP ",
    "%#sep#",
    " ",
    "%#stl#",
    AccentColor(),
    -- Lspstatus(),
    "%F",
    "%#sep#",
    " ",
    "%#stl#",
    "%=",
    "%#stl#",
    " %l/%L : %c ",
    "%#sep#",
    " ",
    "%#stl#",
    AccentColor(),
    " %p%% ",
    "%#stl#",
    "%#sep#",
    " ",
  }

  return table.concat(parts, '')

end

function Mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'n' then
    mode = "NORMAL"
  elseif mode == 'i' then
    mode = "INSERT"
  elseif mode == 'c' then
    mode = "COMMAND"
  elseif mode == 'v' then
    mode = "VISUAL"
  elseif mode == 'V' then
    mode = "V-LINE"
  elseif mode == '' then
    mode = "V-BLOCK"
  elseif mode == 't' then
    mode = "TERMINAL"
  elseif mode == 'nt' then
    mode = "NORM-TERM"
  elseif mode == 'R' then
    mode = "REPLACE"
  end
  return " " .. mode .. " "
end

function Filename()
  local filename = vim.fn.expand("%:t")
  return " " .. filename .. " "
end

function Lspstatus()
  local lspstatus = vim.lsp.status()

  local lspclients = vim.lsp.get_clients()
  local clients_table = {}

  for _, clients in ipairs(lspclients) do
    table.insert(clients_table, clients.name)
  end

  local lsp_clients = table.concat(clients_table, ', ')

  if lsp_clients == "" then
    lsp_clients = "---"
  end

  return " " .. lsp_clients .. " "
end

function AccentColor()

  local final = "%#normal_mode#"
  return final

end

return M
