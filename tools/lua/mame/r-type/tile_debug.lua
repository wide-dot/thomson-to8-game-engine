-- Script Lua MAME pour afficher les tiles solides avec scroll
-- Usage: mame rtype -window -autoboot_script tools/lua/mame/r-type/tile_debug.lua

-- Variables globales
local machine = nil
local screen = nil
local cpu = nil
local mem = nil
local enabled = true

-- Constantes
local TILE_SIZE = 8
local TILEMAP_WIDTH = 64
local TILEMAP_HEIGHT = 64
local BYTES_PER_TILE = 4

local VRAM1_BASE = 0xD0000  -- Foreground
local VRAM2_BASE = 0xD8000  -- Background

local SCROLL_FG_X = 0x42EC1
local SCROLL_FG_Y = 0x42EC5
local SCROLL_BG_X = 0x42EC9
local SCROLL_BG_Y = 0x42ECD

local FOREGROUND_SOLID_THRESHOLD = 0xDFC
local BACKGROUND_SOLID_THRESHOLD = 0x7D0

local COLOR_FOREGROUND = 0x800000FF  -- Bleu
local COLOR_BACKGROUND = 0x80FF0000  -- Rouge

-- Offsets pour corriger l'alignement (en pixels)
local OFFSET_X = -8 * TILE_SIZE  -- -8 tiles = -64 pixels
local OFFSET_Y = -16 * TILE_SIZE  -- -16 tiles = -128 pixels

-- Fonction pour lire le scroll
local function get_scroll(is_background)
    if not mem then return 0, 0 end
    
    if is_background then
        return mem:read_u16(SCROLL_BG_X) & 0x1FF, mem:read_u16(SCROLL_BG_Y) & 0x1FF
    else
        return mem:read_u16(SCROLL_FG_X) & 0x1FF, mem:read_u16(SCROLL_FG_Y) & 0x1FF
    end
end

-- Initialisation
local function init()
    machine = manager.machine
    if not machine then return false end
    
    screen = machine.screens[":screen"]
    if not screen then
        for tag, scr in pairs(machine.screens) do
            screen = scr
            break
        end
    end
    if not screen then return false end
    
    cpu = machine.devices[":maincpu"]
    if not cpu then return false end
    
    mem = cpu.spaces["program"]
    if not mem then return false end
    
    return true
end

-- Fonction de dessin
local function draw_overlay()
    if not enabled or not screen or not mem then return end
    
    -- Dimensions de l'écran
    local width = screen.width or 256
    local height = screen.height or 256
    if screen.visible_area then
        width = screen.visible_area.width
        height = screen.visible_area.height
    end
    
    -- Lire les valeurs de scroll
    local scroll_x_fg, scroll_y_fg = get_scroll(false)
    local scroll_x_bg, scroll_y_bg = get_scroll(true)
    
    -- Calculer les offsets de scroll
    local start_tile_x_fg = math.floor(scroll_x_fg / TILE_SIZE)
    local start_tile_y_fg = math.floor(scroll_y_fg / TILE_SIZE)
    local start_tile_x_bg = math.floor(scroll_x_bg / TILE_SIZE)
    local start_tile_y_bg = math.floor(scroll_y_bg / TILE_SIZE)
    
    local offset_x_fg = scroll_x_fg % TILE_SIZE
    local offset_y_fg = scroll_y_fg % TILE_SIZE
    local offset_x_bg = scroll_x_bg % TILE_SIZE
    local offset_y_bg = scroll_y_bg % TILE_SIZE
    
    -- Calculer la plage de tiles en tenant compte de l'offset négatif
    -- L'offset négatif nécessite de dessiner plus de tiles pour couvrir l'écran
    local min_x = math.min(0, OFFSET_X)
    local min_y = math.min(0, OFFSET_Y)
    local max_x = math.max(width, width + OFFSET_X)
    local max_y = math.max(height, height + OFFSET_Y)
    
    local start_tx = math.floor(min_x / TILE_SIZE)
    local start_ty = math.floor(min_y / TILE_SIZE)
    local tiles_x = math.ceil((max_x + offset_x_fg) / TILE_SIZE) - start_tx
    local tiles_y = math.ceil((max_y + offset_y_fg) / TILE_SIZE) - start_ty
    
    -- Dessiner le background
    for ty = start_ty, start_ty + tiles_y do
        for tx = start_tx, start_tx + tiles_x do
            local tile_x = (start_tile_x_bg + tx - start_tx) % TILEMAP_WIDTH
            local tile_y = (start_tile_y_bg + ty - start_ty) % TILEMAP_HEIGHT
            local tile_index = tile_y * TILEMAP_WIDTH + tile_x
            local addr = VRAM2_BASE + (tile_index * BYTES_PER_TILE)
            
            local code = mem:read_u8(addr)
            local attribute = mem:read_u8(addr + 1)
            local tile_id = (code + ((attribute & 0x3F) * 256)) & 0x3FFF
            
            if tile_id ~= 0 and tile_id < BACKGROUND_SOLID_THRESHOLD then
                local screen_x = (tx - start_tx) * TILE_SIZE - offset_x_bg + OFFSET_X
                local screen_y = (ty - start_ty) * TILE_SIZE - offset_y_bg + OFFSET_Y
                
                -- Dessiner un rectangle exactement 8x8 pixels
                -- draw_box utilise des coordonnées exclusives, donc x2 = x1 + 8 pour avoir 8 pixels
                local x1 = screen_x
                local y1 = screen_y
                local x2 = screen_x + TILE_SIZE
                local y2 = screen_y + TILE_SIZE
                
                -- Ne dessiner que si au moins partiellement visible
                if x2 >= 0 and x1 < width and y2 >= 0 and y1 < height then
                    if screen.draw_box then
                        screen:draw_box(x1, y1, x2, y2, 0x00000000, COLOR_BACKGROUND)
                    end
                end
            end
        end
    end
    
    -- Dessiner le foreground
    for ty = start_ty, start_ty + tiles_y do
        for tx = start_tx, start_tx + tiles_x do
            local tile_x = (start_tile_x_fg + tx - start_tx) % TILEMAP_WIDTH
            local tile_y = (start_tile_y_fg + ty - start_ty) % TILEMAP_HEIGHT
            local tile_index = tile_y * TILEMAP_WIDTH + tile_x
            local addr = VRAM1_BASE + (tile_index * BYTES_PER_TILE)
            
            local code = mem:read_u8(addr)
            local attribute = mem:read_u8(addr + 1)
            local tile_id = (code + ((attribute & 0x3F) * 256)) & 0x3FFF
            
            if tile_id ~= 0 and tile_id < FOREGROUND_SOLID_THRESHOLD then
                local screen_x = (tx - start_tx) * TILE_SIZE - offset_x_fg + OFFSET_X
                local screen_y = (ty - start_ty) * TILE_SIZE - offset_y_fg + OFFSET_Y
                
                -- Dessiner un rectangle exactement 8x8 pixels
                -- draw_box utilise des coordonnées exclusives, donc x2 = x1 + 8 pour avoir 8 pixels
                local x1 = screen_x
                local y1 = screen_y
                local x2 = screen_x + TILE_SIZE
                local y2 = screen_y + TILE_SIZE
                
                -- Ne dessiner que si au moins partiellement visible
                if x2 >= 0 and x1 < width and y2 >= 0 and y1 < height then
                    if screen.draw_box then
                        screen:draw_box(x1, y1, x2, y2, 0x00000000, COLOR_FOREGROUND)
                    end
                end
            end
        end
    end
end

-- Initialisation
local init_done = false
local callbacks_registered = false

local function register_callbacks()
    if callbacks_registered then return end
    callbacks_registered = true
    emu.register_frame_done(function()
        pcall(draw_overlay)
    end, "frame")
end

if init() then
    init_done = true
    register_callbacks()
else
    emu.register_frame_done(function()
        if not init_done then
            if init() then
                init_done = true
                register_callbacks()
            end
        end
    end, "frame")
end
