---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-05 13:27
---

local addonName, L = ...

local ad_msg = {
  "【米豪公益】需要55级水、45级面包，请直接交易“米豪”货仓！免费提供！",
  "【米豪公益】需要打开去主城的捷径，请与我私聊“传送门”！，牢记程序，免一切手续费！",
  "【米豪公益】如果亲觉得米豪公益好用，请奔走相告，米豪力争24小时为各位提供免费食水传送服务！",
  "【米豪公益】TIPs: 米豪开门只收【传送门符文】不收金币！！！详情M我【传送门】",
  "【米豪公益】TIPs: 如果米豪开始奥暴，并非米豪在划水，而是米豪食水充足无比！欢迎各种交易！完全免费！",
  "【米豪公益】TIPs: 如果您和米豪不在一个位面，请M我唯一有效咒语【"..L.cmds.invite_cmd.."】进组！",
  "【米豪公益】TIPs: 米豪平时无人值守，需要食物的请直接交易！需要传送请M我【传送门】，并认真按照开门程序操作，简单便捷！",
  "【米豪公益】米豪每天会升级维护，维护期间不能提供服务，敬请谅解！有关米豪的使用帮助，请M我【"..L.cmds.help_cmd.."】！",
}

local ad_msg_busy = {
  "【米豪公益：用餐高峰】需要55级水、45级面包，请直接交易“米豪”货仓！免费提供！",
  "【米豪公益：用餐高峰】需要打开去主城的捷径，请与我私聊“传送门”！，牢记程序，免一切手续费！",
  "【米豪公益：用餐高峰】TIPs：用餐高峰期间，米豪每次交易供应减半，阻止相同角色连续交易，阻止60级FS交易，敬请谅解！",
  "【米豪公益：用餐高峰】TIPs：米豪在喝水期间，货存不会增长，如果库存不足，请不要在米豪喝水期间重复交易哦！",
  "【米豪公益：用餐高峰】TIPs：用餐高峰期间，请各位亲保持有序，不要争抢，谢谢大家支持与配合！",
  "【米豪公益：用餐高峰】TIPs：米豪在面包与水均高于4组的情况下才允许交易，请亲关注库存！",
  "【米豪公益：用餐高峰】TIPs：【激活】法术会【大幅提升】米豪制作效率，如果米豪正在制作中，请德爷们赏个激活吧！！",
  "【米豪公益：用餐高峰】TIPs：用餐高峰期，米豪支持志同道合朋友们的补货！请M米豪【补货】查看详情，谢谢！",
}

function L.F.say_help(to_player)
  SendChatMessage(
    "我会自动根据您的职业分配食物与水的比例。", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "请勿交易金币和物品，否则可能无法正常交易。如有有建议或希望捐赠，请使用魔兽邮箱，谢谢支持！", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "=========我目前支持如下命令：", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("1.【%s】打印本命令列表", L.cmds.help_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("2. 【%s】查看高峰时期规则", L.cmds.busy_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("3.【%s】向您发起组队邀请，以便发送位置、跨位面", L.cmds.invite_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("4.【%s】查看高峰期补货方式", L.cmds.refill_help_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "5.【自定义分配】为您定制水和面包比例，例如您可说“4水2面包”",
    "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("6.【%s】查看开门步骤", L.cmds.gate_help_cmd), "WHISPER", "Common", to_player
  )
end

function L.F.send_ad()
  local water = L.F.get_water_count()
  local bread = L.F.get_bread_count()
  SendChatMessage(date("%X").."存货：【大水】"..water.."组，【面包】"..bread.."组。","say","Common")
  local admsgs;
  if L.F.get_busy_state() then
    admsgs = ad_msg_busy
  else
    admsgs = ad_msg
  end
  SendChatMessage(date("%X")..admsgs[math.random(1, #admsgs)], "say", "Common")
end
