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
  "【米豪公益】TIPs: 如遇高峰时期，请各位勤拿少取，需要多少水，多少面包，可以私聊我进行定制！例如“我要1水2面包”。路过的各位，请给点BUFF给我加速，例如激活、精神、王者、智慧",
  "【米豪公益】TIPs: 米豪开门只收【传送门符文】不收金币！！！详情M我【传送门】",
  "【米豪公益】TIPs: 如果米豪开始奥暴，并非米豪在划水，而是米豪食水充足无比！欢迎各种交易！完全免费！",
  "【米豪公益】TIPs: 如果您和米豪不在一个位面，请M我唯一有效咒语【"..L.cmds.invite_cmd.."】进组！",
  "【米豪公益】TIPs: 米豪平时无人值守，需要食物的请直接交易！需要传送请M我【传送门】，并认真按照开门程序操作，简单便捷！",
  "【米豪公益】米豪每天会升级维护，维护期间不能提供服务，敬请谅解！有关米豪的使用帮助，请M我【"..L.cmds.help_cmd.."】！",
}

function L.F.say_help(to_player)
  SendChatMessage(
    "我会自动根据您的职业分配食物与水的比例。", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "请勿交易金币和物品，否则可能无法正常交易。如有有建议或希望捐赠，请使用魔兽邮箱，谢谢支持！", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "小号暂不提供食物！开门服务试运行！如果不小心黑了您的石头，请给我发邮件", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    "=========我目前支持如下命令：", "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("1.【%s】打印本命令列表", L.cmds.help_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("2.【%s】获取我的坐标", L.cmds.retrieve_position), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("3.【%s】向您发起组队邀请，以便发送位置、跨位面", L.cmds.invite_cmd), "WHISPER", "Common", to_player
  )
  SendChatMessage(
    string.format("4.【%s】查看不同职业水和面包比例", L.cmds.scale_cmd), "WHISPER", "Common", to_player
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
  SendChatMessage(date("%X").."存货：【大水】"..water.."组，【面包】"..bread.."组。。。米豪刚刚做过结构变更，工作可能会失常，请谅解！","say","Common")
  SendChatMessage(date("%X")..ad_msg[math.random(1, #ad_msg)], "say", "Common")
end
