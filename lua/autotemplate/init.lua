local ts_utils = require("nvim-treesitter.ts_utils")

local function filter_treesitter_parent(node, pred)
    while node ~= nil do
        if pred(node) then
            return node
        end
        node = node:parent()
    end

    return nil
end

local M = {}

function M.yas(language)
    local cursor_node = ts_utils.get_node_at_cursor()
    local string_node = filter_treesitter_parent(cursor_node, function(v)
        return v:type() == "string"
    end)
    if string_node == nil then
        return
    end
    local query = vim.treesitter.query.get(language, string.upper(language) .. "AutoTemplate")
    if query == nil then
        vim.notify(
            "query " .. string.upper(language) .. "AutoTemplate was nil, did you call setup?",
            vim.log.levels.ERROR
        )
        return
    end

    local collected_info = {}
    local matched = false
    for id, node in query:iter_captures(string_node, 0) do
        matched = true
        local name = query.captures[id]
        if name == "string_text" then
            collected_info.text = vim.treesitter.get_node_text(node, 0)
        elseif name == "string_outer" then
            local start_row, start_col, end_row, end_col = node:range(false)
            collected_info.start_row = start_row
            collected_info.start_col = start_col
            collected_info.end_row = end_row
            collected_info.end_col = end_col
        end

        if node:parent():type() == "jsx_attribute" then
            collected_info.is_jsx_attribute = true
        end
    end
    if not matched then
        return
    end
    collected_info.text = collected_info.text or ""
    local newtext = "`" .. collected_info.text .. "`"
    local offset = 0

    if collected_info.is_jsx_attribute then
        newtext = "{" .. newtext .. "}"
        offset = offset + 1
    end

    vim.api.nvim_buf_set_text(
        0,
        collected_info.start_row,
        collected_info.start_col,
        collected_info.end_row,
        collected_info.end_col,
        { newtext }
    )

    return offset
end

function M.setup()
    for _, lang in ipairs({ "javascript", "typescript", "tsx" }) do
        vim.treesitter.query.set(
            lang,
            string.upper(lang) .. "AutoTemplate",
            [[ [
                (string (string_fragment) @string_text) @string_outer
                (string) @string_outer
            ] ]]
        )
    end
end

function M.autotemplate(language, trigger)
    if trigger == nil then
        trigger = "$"
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    local row = pos[1] - 1
    local col = pos[2]
    local offset = M.yas(language)
    vim.api.nvim_buf_set_text(0, row, col + offset, row, col + offset, { trigger })
    vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 + offset })
end

return M
