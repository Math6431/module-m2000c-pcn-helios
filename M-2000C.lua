BIOS.protocol.beginModule("M2000C-PCN-HELIOS", 0x7400)
BIOS.protocol.setExportModuleAircrafts({"M-2000C"})

local parse_indication = BIOS.util.parse_indication
local defineStringFromGetter = BIOS.util.defineStringFromGetter

local function decode7Seg(segmentData, digitCount)
    local segDecode = {
        ["****** "] = "0", [" **    "] = "1", ["** ** *"] = "2", ["****  *"] = "3",
        [" **  **"] = "4", ["* ** **"] = "5", ["* *****"] = "6", ["***    "] = "7",
        ["*******"] = "8", ["**** **"] = "9", ["       "] = " "
    }
    local segments = ""
    segmentData = segmentData:gsub("([a-z])","*")
    for j = 1, digitCount do
        local seg = ""
        for i = 0, digitCount*6, digitCount do
            seg = seg .. segmentData:sub(j+i, j+i)
        end
        segments = segments .. (segDecode[seg] or " ")
    end
    return segments
end

-- Affichage gauche (PCN_DISP_L)
defineStringFromGetter("PCN_DISP_L", function()
    local li = parse_indication(9)
    if li and li.PCN_UL_SEG0 then
        local segData = (li.PCN_UL_SEG2 or "")..
                        (li.PCN_UL_SEG3 or "")..
                        (li.PCN_UL_SEG4 or "")..
                        (li.PCN_UL_SEG5 or "")..
                        (li.PCN_UL_SEG0 or "")..
                        (li.PCN_UL_SEG1 or "")..
                        (li.PCN_UL_SEG6 or "")
        return decode7Seg(segData, 6)
    end
    return "      "
end, 6)

-- Affichage droite (PCN_DISP_R)
defineStringFromGetter("PCN_DISP_R", function()
    local li = parse_indication(9)
    if li and li.PCN_UR_SEG0 then
        local segData = (li.PCN_UR_SEG2 or "")..
                        (li.PCN_UR_SEG3 or "")..
                        (li.PCN_UR_SEG4 or "")..
                        (li.PCN_UR_SEG5 or "")..
                        (li.PCN_UR_SEG0 or "")..
                        (li.PCN_UR_SEG1 or "")..
                        (li.PCN_UR_SEG6 or "")
        return decode7Seg(segData, 6)
    end
    return "      "
end, 6)

-- Direction gauche
defineStringFromGetter("PCN_DIS_L_DIR", function()
    local li = parse_indication(9)
    if not li then return " " end
    if li["PCN_UL_N"] then return "N"
    elseif li["PCN_UL_S"] then return "S"
    elseif li["PCN_UL_P"] then return "+"
    elseif li["PCN_UL_M"] then return "-" end
    return " "
end, 1)

-- Direction droite
defineStringFromGetter("PCN_DIS_R_DIR", function()
    local li = parse_indication(9)
    if not li then return " " end
    if li["PCN_UR_E"] then return "E"
    elseif li["PCN_UR_W"] then return "W"
    elseif li["PCN_UR_P"] then return "+"
    elseif li["PCN_UR_M"] then return "-" end
    return " "
end, 1)

BIOS.protocol.endModule()