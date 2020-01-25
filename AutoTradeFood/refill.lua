---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-06 22:42
---

local addonName, L = ...

local refill_context = {
    ["refillers"] = {
        ["米豪的维修师"] = {
            ["refill_request_ts"] = 0,
            ["preserve"] = true,
            ["last_refill_ts"] = 0,
        }
    }
}

function L.F.refill_request(player)
    if L.F.get_free_slots() > 10 then
        refill_context.refillers[player] = {
            ["refill_request_ts"] = GetTime(),
            ["last_refill_ts"] = 0,
        }
        SendChatMessage("补货请求成功，我将在"..L.refill_timeout
                .."秒内接受您的补货，感谢支持！",
                "WHISPER", "Common", player
        )
    else
        SendChatMessage("目前货存充足，暂时无需补货，谢谢支持！", "WHISPER", "Common", player)
    end

end


local function remove_refiller(player)
    refill_context.refillers[player] = nil
end


local function check_refill_scale()
    if L.F.get_free_slots() < 6 then
        return "full"
    elseif L.F.get_free_slots() <= 15 then
        local bread = L.F.get_bread_count()
        local water = L.F.get_water_count()
        if bread > water * 1.6 then
            return "bread"
        elseif water > bread * 1.6 then
            return "water"
        else
            return "ok"
        end
    else
        return "ok"
    end
end


local function player_is_refiller(player)
    local refiller_ctx = refill_context.refillers[player]
    if refiller_ctx and
            (refiller_ctx["preserve"] or GetTime() - refiller_ctx.refill_request_ts < L.refill_timeout) then
        return true
    else
        refill_context.refillers[player] = nil
        return false
    end
end


function L.F.refill_help(to_player)
    SendChatMessage("【在货存不足时】，米豪将接受其他有共同志向玩家的补货救急，降低食客等待时间。", "WHISPER", "Common", to_player)
    SendChatMessage("1. 如需补货，请首先M我【"..L.cmds.refill_cmd.."】，如果成功，我会向您回复消息。", "WHISPER", "Common", to_player)
    SendChatMessage("2. 然后请在"..L.refill_timeout.."秒内与我进行交易，将食水放至您的交易栏内，并点击交易", "WHISPER", "Common", to_player)
    SendChatMessage("3. 我将对您的补货内容进行验证，接受合法的补货，并广播致谢信息。", "WHISPER", "Common", to_player)
    SendChatMessage("注1，每次提交补货申请，有效期内可以一直补货，如需取消补货，请对我进行一次空的交易。", "WHISPER", "Common", to_player)
    SendChatMessage("注2，请勿交易我除了大水大面包之外的任何物品或金币哦，谢谢支持！", "WHISPER", "Common", to_player)
end


local function should_hook(trade)
    if player_is_refiller(trade.npc_name) then
        return true, false
    else
        return false, false
    end
end


local function statistics_refill(trade)
  local name = trade.npc_name
  local key_trade_ind = "trade.refill.ind."..date("%x").."."..name
  local key_trade_all = "trade.refill.all."..date("%x")
  local key_trade_count = "trade.refill.count."..date("%x")
  L.F.merge_statistics_plus_table(key_trade_ind, trade.items.target.items)
  L.F.merge_statistics_plus_table(key_trade_all, trade.items.target.items)
  L.F.merge_statistics_plus_int(key_trade_count, 1)
end



local function send_thanks_message(trade)
    local player = trade.npc_name
    local msg = string.format(
        "感谢%s为我补货。M我【%s】可为我补货，M我【%s】查看贡献榜。",
        player,
        L.cmds.refill_cmd,
        L.cmds.statistics
    )
    L.F.append_trade_say_messages(msg)
    DoEmote("thank", player)
    statistics_refill(trade)
end


local function should_accept_refill(trade)
    local player = trade.npc_name
    local items = trade.items.target.items
    local cnt = trade.items.target.count
    if cnt == 0 then
        SendChatMessage("未收到任何补货，为您取消补货请求。", "WHISPER", "Common", player)
        remove_refiller(player)
        return false
    end
    if items["Gold"] and items["Gold"] > 0 then
        SendChatMessage("请勿交易我任何金币，谢谢支持", "WHISPER", "Common", player)
        return false
    end
    local water, bread = 0, 0
    for item_name, c in pairs(items) do
        if item_name == L.items.water_name then
            water = water + c
        elseif item_name == L.items.food_name then
            bread = bread + c
        else
            SendChatMessage(
                "补货模式仅仅接受大水和大面包，请勿交易其他物品或金币，感谢支持！",
                "WHISPER", "Common", player
            )
            return false
        end
        local refill_check_result = check_refill_scale()
        local item_too_many
        if refill_check_result == "bread" and bread > 0 then
            item_too_many = L.items.food_name
        elseif refill_check_result == "water" and water > 0 then
            item_too_many = L.items.water_name
        elseif refill_check_result == "full" then
            SendChatMessage("米豪背包几乎已满，请稍后尝试补货，谢谢！", "WHISPER", "Common", player)
            return false
        end

        if item_too_many then
            SendChatMessage("目前库存中【"..item_too_many.."】数量过多，暂时不需要补充，谢谢支持！", "WHISPER", "Common", player)
            return false
        end
        return true
    end
end


L.trade_hooks.trade_refill = {
  ["should_hook"] = should_hook,
  ["feed_items"] = nil,
  ["on_trade_complete"] = send_thanks_message,
  ["on_trade_cancel"] = nil,
  ["on_trade_error"] = nil,
  ["should_accept"] = should_accept_refill,
  ["check_target_item"] = nil,
}
