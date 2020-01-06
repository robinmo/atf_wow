---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-05 13:43
---
local addonName, L = ...

local gate_request_timeout = 90
local min_mana = L.min_mana
local interact_key = L.hotkeys.interact_key

L.gate = {}
L.gate.gating_context = {["spell"]="", ["requester"]="", ["cooldown_ts"]=0, ["city"]="", ["invited"]=false}
L.gate.gating_contexts = {}


function L.F.say_gate_help(to_player)
  SendChatMessage("4步便捷开门！请花1分钟仔细阅读，简单高效无需求人开门即可达成！", "WHISPER", "Common", to_player)
  SendChatMessage("1. 在材料NPC处购买传【送门符文】1枚，也可以AH购买，我原价放了许多。", "WHISPER", "Common", to_player)
--  SendChatMessage("**！！！请注意！！！，原价是20银！！！认准我的名字【米豪】或【米豪的维修师】**", "WHISPER", "Common", to_player)
  SendChatMessage("2. 【先】M我主城的名字，“暴风城”、“铁炉堡”或“达纳苏斯”", "WHISPER", "Common", to_player)
  SendChatMessage("3. 【然后】将石头主动交易给我：【传送门符文】【1枚】", "WHISPER", "Common", to_player)
  SendChatMessage("4. 【交易成功后】，我将【自动】向您发起组队邀请，并在短时间内释放传送门法术，请确保您已退组哈", "WHISPER", "Common", to_player)
  SendChatMessage("请您使用传送门后自行离队，祝您旅途愉快！", "WHISPER", "Common", to_player)
end


local function parse_and_set_city(msg)
  local spell, city
  if msg:find("暴风城") then
    spell = "传送门：暴风城"
    city = "暴风城"
  elseif msg:find("达纳苏斯") then
    spell = "传送门：达纳苏斯"
    city = "达纳苏斯"
  elseif msg:find("铁炉堡") then
    spell = "传送门：铁炉堡"
    city = "铁炉堡"
  else
    print("这里不应该到达")
    return nil, nil
  end
  return spell, city
end


local function invalidate_requests(winner, city)
  for player, _ in pairs(L.gate.gating_contexts) do
    SendChatMessage(winner..
            "抢先一步交易了我【传送门符文】，您的请求已取消。我将为其施放通往"..city.."的传送门，如若顺路，请M我【水水水】进组",
            "WHISPER", "Common", player
    )
  end
  L.gate.gating_contexts = {}
end


local function transit_to_gate_state(player)
  L.gate.gating_contexts[player] = nil
  invalidate_requests(player, L.gate.gating_context["city"])
  L.state = 3
  L.gate.gating_context["cooldown_ts"] = GetTime() + 60
  L.gate.gating_context["invited"] = false
  InviteUnit(player)
end


function L.F.gate_request(player, msg)
  if GetTime() < L.gate.gating_context["cooldown_ts"] then
    local cooldown_last = math.modf( L.gate.gating_context["cooldown_ts"] - GetTime())
    SendChatMessage("传送门法术正在冷却，请"..cooldown_last.."秒后重新请求", "WHISPER", "Common", player)
    return
  end
  local spell, city = parse_and_set_city(msg)
  print(spell, city)
  if not spell then
    return
  end
  if GetNumGroupMembers() >= 5 then
    LeaveParty()
  end
  if GateWhiteList[player] then
    if GetItemCount(L.items.stone_name) > 0 then
      L.gate.gating_context["spell"] = spell
      L.gate.gating_context["city"] = city
      L.gate.gating_context["requester"] = player
      transit_to_gate_state(player)
      SendChatMessage("贵宾驾到，马上起航！", "WHISPER", "Common", player)
      return
    else
      SendChatMessage("贵宾您好，我已无油，请交易我施法材料【传送门符文】【1枚】来为我补充油料", "WHISPER", "Common", player)
    end
  end

  L.gate.gating_contexts[player] = {
    ["request_ts"]=GetTime(),
    ["city"]=city,
    ["spell"]=spell,
  }
  SendChatMessage(
    city.."传送门指定成功，请于"..gate_request_timeout..
        "秒内交易我【1】枚【传送门符文】。请于施法材料商或AH原价从我手中购买该材料。请注意，原价为20Y，如果没有这个价格的，请寻找材料NPC！",
    "WHISPER", "Common", player
  )
end


function L.F.drive_gate()
  for player, gc in pairs(L.gate.gating_contexts) do
    if GetTime() - gc["request_ts"] > gate_request_timeout then
      SendChatMessage("传送门未能成功开启，未收到符文石", "WHISPER", "Common", player)
      L.gate.gating_contexts[player] = nil
    end
  end
  if GetTime() < L.gate.gating_context["cooldown_ts"] and L.gate.gating_context['invited'] == false then
    if UnitInParty(L.gate.gating_context["requester"]) then
      L.gate.gating_context["invited"] = true
    else
      SendChatMessage(
              "上次邀请未成功！请您确认离队，我会在传送门消失前重复尝试邀请您！",
              "WHISPER", "Common", L.gate.gating_context["requester"]
      )
      InviteUnit(L.gate.gating_context["requester"])
    end
  end
end


function L.F.bind_gate()
  if UnitPower("player") < min_mana then
    SetBindingItem(interact_key, "魔法晶水")
  else
    SetBindingSpell(interact_key, L.gate.gating_context["spell"])
  end
end


function L.F.trade_stone(npc_name)
  local ils = GetTradePlayerItemLink(1)
  local items, tbl_cnt = L.F.post_check_opposite_trade()
  if ils == nil then
    L.F.feed(L.items.food_name, 1)
  elseif tbl_cnt == 0 then
      -- do nothing
  elseif items[L.items.stone_name] == 1 and tbl_cnt == 1 then
    if L.F.do_accept_trade() then
      local city = L.gate.gating_contexts[npc_name]["city"]
      local spell = L.gate.gating_contexts[npc_name]["spell"]
      SendChatMessage(
              "符文石交易成功，请接受组队邀请。稍等几秒将为您开门...若未邀请成功，请M我水水水进组", "WHISPER", "Common", npc_name)
      SendChatMessage(npc_name.."，"..city.."传送程序已载入，请坐稳扶好！想搭便车的朋友，M我【水水水】进组")
      L.gate.gating_context["spell"] = spell
      L.gate.gating_context["city"] = city
      L.gate.gating_context["requester"] = npc_name
      transit_to_gate_state(npc_name)
    end
  else
    if items["Gold"] and items["Gold"] > 0 then
      SendChatMessage(npc_name.."，开门服务只收【传送门符文】，不收金币，详情烦请M我【传送门】，仅需1分钟，轻松开门！", "say", "Common")
    elseif items[L.items.stone_name] and items[L.items.stone_name] > 1 then
      SendChatMessage(npc_name.."，请交易我【1枚】传送门符文，多余的请您保留以备后用，谢谢！", "say", "Common")
    else
      SendChatMessage(npc_name.."，请勿交易我额外的物品，谢谢！", "say", "Common")
    end
    CloseTrade()
  end
end