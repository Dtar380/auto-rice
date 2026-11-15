-- ============================================================================
--  WORKSPACES
-- ============================================================================

local M = {}

M.max = 4
M.wrap = true

-- Gets the id of the current workspace
local function current_id()
    local ws = hl.get_active_workspace()
    local id = ws and ws.id
    if type(id) ~= "number" or id < 1 then
        return 1
    end
    return id
end

-- Turns any number into a valid workspace id (wraps or clamps)
local function resolve(n)
    if M.wrap then
        return ((n - 1) % M.max) + 1
    end
    return math.max(1, math.min(M.max, n))
end

-- Absolute: jump to workspace n (ignored if out of range)
function M.focus(n)
    if n < 1 or n > M.max then return end
    hl.dispatch(hl.dsp.focus({ workspace = tostring(n) }))
end

function M.move(n, follow)
    if n < 1 or n > M.max then return end
    if follow == nil then follow = true end
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(n), follow = follow}))
end

-- Relative: delta = +1 / -1, never goes past the limit
function M.focus_relative(delta)
    local cur = current_id()
    local target = resolve(cur + delta)
    if target == cur then return end
    M.focus(target)
end

function M.move_relative(delta, follow)
    local cur = current_id()
    local target = resolve(cur + delta)
    if target == cur then return end
    M.move(target, follow)
end

-- Sets up the max workspaces into persistent workspaces
function M.setup()
    for i = 1, M.max do
        hl.workspace_rule({
            workspace = tostring(i),
            persistent = true,
            default = (i == 1)
        })
    end
end

M.setup()

return M
