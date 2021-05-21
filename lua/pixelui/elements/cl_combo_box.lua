
--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local PANEL = {}

Derma_Install_Convar_Functions(PANEL)

AccessorFunc(PANEL, "bSizeToText", "SizeToText", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDoSort", "SortItems", FORCE_BOOL)

function PANEL:Init()
    self:SetSizeToText(true)

    self:Clear()

    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetSortItems(true)
end

function PANEL:PerformLayout(w, h)
    if not self:GetSizeToText() then return end
    self:SizeToText()
    self:SetWide(self:GetWide() + PIXEL.Scale(14))
end

function PANEL:Clear()
    self:SetText("")
    self.Choices = {}
    self.Data = {}
    self.ChoiceIcons = {}
    self.selected = nil

    if not self.Menu then return end
    self.Menu:Remove()
    self.Menu = nil
end

function PANEL:GetOptionText(id)
    return self.Choices[id]
end

function PANEL:GetOptionData(id)
    return self.Data[id]
end

function PANEL:GetOptionTextByData(data)
    for id, dat in pairs(self.Data) do
        if dat == data then
            return self:GetOptionText(id)
        end
    end

    for id, dat in pairs(self.Data) do
        if dat == tonumber(data) then
            return self:GetOptionText(id)
        end
    end

    return data
end

function PANEL:ChooseOption(value, index)
    if self.Menu then
        self.Menu:Remove()
        self.Menu = nil
    end

    self:SetText(value)

    self.selected = index
    self:OnSelect(index, value, self.Data[index])

    if not self:GetSizeToText() then return end
    self:SizeToText()
    self:SetWide(self:GetWide() + PIXEL.Scale(10))
end

function PANEL:ChooseOptionID(index)
    local value = self:GetOptionText(index)
    self:ChooseOption(value, index)
end

function PANEL:GetSelectedID()
    return self.selected
end

function PANEL:GetSelected()
    if not self.selected then return end
    return self:GetOptionText(self.selected), self:GetOptionData(self.selected)
end

function PANEL:OnSelect(index, value, data) end

function PANEL:AddChoice(value, data, select, icon)
    local i = table.insert(self.Choices, value)

    if data then
        self.Data[i] = data
    end

    if icon then
        self.ChoiceIcons[i] = icon
    end

    if select then
        self:ChooseOption(value, i)
    end

    return i
end

function PANEL:IsMenuOpen()
    return IsValid(self.Menu) and self.Menu:IsVisible()
end

function PANEL:OpenMenu(pControlOpener)
    if pControlOpener and pControlOpener == self.TextEntry then return end

    if #self.Choices == 0 then return end

    if IsValid(self.Menu) then
        self.Menu:Remove()
        self.Menu = nil
    end

    CloseDermaMenus()
    self.Menu = vgui.Create("PIXEL.Menu", self)

    if self:GetSortItems() then
        local sorted = {}
        for k, v in pairs(self.Choices) do
            local val = tostring(v)
            if string.len(val) > 1 and not tonumber(val) and val:StartWith("#") then val = language.GetPhrase(val:sub(2)) end
            table.insert(sorted, {id = k, data = v, label = val})
        end

        for k, v in SortedPairsByMemberValue(sorted, "label") do
            local option = self.Menu:AddOption(v.data, function() self:ChooseOption(v.data, v.id) end)
            if self.ChoiceIcons[v.id] then
                option:SetIcon(self.ChoiceIcons[v.id])
            end
        end
    else
        for k, v in pairs(self.Choices) do
            local option = self.Menu:AddOption(v, function() self:ChooseOption(v, k) end)
            if self.ChoiceIcons[k] then
                option:SetIcon(self.ChoiceIcons[k])
            end
        end
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    self.Menu:SetMinimumWidth(self:GetWide())
    self.Menu:Open(x, y + PIXEL.Scale(6), false, self)

    self:SetToggle(true)

    self.Menu.OnRemove = function(s)
        if not IsValid(self) then return end
        self:SetToggle(false)
    end
end

function PANEL:CloseMenu()
    if not IsValid(self.Menu) then return end
    self.Menu:Remove()
end

function PANEL:CheckConVarChanges()
    if not self.m_strConVar then return end

    local strValue = GetConVar(self.m_strConVar):GetString()
    if self.m_strConVarValue == strValue then return end

    self.m_strConVarValue = strValue
    self:SetValue(self:GetOptionTextByData(self.m_strConVarValue))
end

function PANEL:Think()
    self:CheckConVarChanges()
end

function PANEL:SetValue(strValue)
    self:SetText(strValue)
end

function PANEL:DoClick()
    if self:IsMenuOpen() then return self:CloseMenu() end
    self:OpenMenu()
end

function PANEL:PaintOver(w, h)
    local dropBtnSize = PIXEL.Scale(8)
    PIXEL.DrawImgur(w - dropBtnSize - PIXEL.Scale(8), h / 2 - dropBtnSize / 2, dropBtnSize, dropBtnSize, "30Bvuwi", PIXEL.Colors.PrimaryText)
end

vgui.Register("PIXEL.ComboBox", PANEL, "PIXEL.TextButton")