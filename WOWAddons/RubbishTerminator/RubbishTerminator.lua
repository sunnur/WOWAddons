local addonName, addon = ...

function addon:print(...)
    _G.print("|cFF00FFFF[RubbishTerminator]:|r", ...)
end

function Drop()
    SlashCmdList["DeleteItem"] = DeleteItemAction
    SlashCmdList["DeleteItemTest"] = TestPrint
    SLASH_DeleteItem1 = "/delete"
    SLASH_DeleteItemTest1 = "/del_test"
    addon:print("MyDelete load finish")
end

function GetItemName(item)
    itemName = GetItemInfo(item)
    return itemName
end

function DeleteItemAction(item)
    if item == "" then return end
    name = GetItemName(item)
    for b = 0, 4 do
        p = GetContainerNumSlots(b)
        for i = 1, p do
            e = GetContainerItemLink(b, i)
            if e and string.find(e, name) then
                PickupContainerItem(b, i);
                DeleteCursorItem();
            end
        end
    end
end

TestPrint = function ()
    addon:print("TestPrint")
end

local frame = CreateFrame("Frame", nil, UIParent);
frame:RegisterEvent("VARIABLES_LOADED");
frame:SetScript("OnEvent", Drop);
