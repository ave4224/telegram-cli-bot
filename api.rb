#!/usr/bin/ruby

require 'Open3'
require 'json'
require 'date'

$shh = true
$log = {}
$master = "👑 Avery 🦄 Cowan 👑"
$masterusername = "averycowan"
$debug_channel = "Building_Dean_Kamen"
$myname = "Dean Kamen"
$myusername = "CyborgModerator"
$admins = {"FRC" => ["Josh 🐷💁🐷 Bacon", "Linnea 💜👑💜 Walsh"], "Building Dean Kamen" => ["Josh 🐷💁🐷 Bacon"]}
$botkey = "Nice try :P" #It uses the bot api for querries
$channels_to_resolve = ["FRCGlobal"]

def pm_text(id, user, message, metadata)

end

def pm_other(id, user, message, metadata)

end

def pm_typing(user)

end

def pm_online(user)

end

def pm_offline(user)

end

def group_text(id, group, user, message, metadata)

end

def group_other(id, group, user, message, metadata)

end

def group_typing(group, user)
end

def command(id, group, user, command, args, metadata)

end

###############################################################
###############################################################
########                                               ########
########               STOP WRITING HERE               ########
########               PREBUILT COMMANDS               ########
########               FOR UTIL USE ONLY               ########
########                                               ########
###############################################################
###############################################################

def kick_user(group, user)
  $cli.print "channel_kick #{group.gsub(" ","_")} #{user.gsub(" ","_")}\n"
end

def add_user(group, user)
  $cli.print "channel_invite #{group.gsub(" ","_")} #{user.gsub(" ","_")}\n"
end

def msg(to, message)
  $cli.print "msg #{to} #{message}\n"
end

def reply(id, message)
  $cli.print "reply #{id} #{message}\n"
end

def resolve_username(username)
  $cli.print "resolve_username #{$username}\n"
end

def isme(user)
  return user==$myname
end

def debug(message)
  if(!$shh)
    msg($debug_channel, message)
  end
end

def getSupergroupAdmins(id)
  id = -1001032632141
  url = "https://api.telegram.org/bot"+$botkey+"/getChatAdministrators?chat_id=#{id}"
  value = `wget #{url}`
  puts value
  puts JSON.parse(value)
end

def isadmin(group, user)
  return user == $master if $admins[group].nil?
  return $admins[group].include?(user) || user == $master
end

###############################################################
###############################################################
########                                               ########
########               STOP READING HERE               ########
########               IGNORE EVERYTHING               ########
########               BEYOND THIS POINT               ########
########                                               ########
###############################################################
###############################################################

def _pm_text(id, user, message, metadata)
  debug("#{user} PM'd text (message #{id}) #{metadata.inspect}")
  $log[id] = user
  if(message =~ /^\/[\w\d]+(@[\w\d]+)?( \W*)*/)
    _command(id, nil, user, message[1..-1].split(' '), nil)
  end
  pm_text(id, user, message, metadata)
end

def _pm_other(id, user, message, metadata)
  debug("#{user} PM'd content (message #{id}) #{metadata.inspect}")
  $log[id] = user
  pm_other(id, user, message, metadata)
end

def _pm_typing(user)
  #msg("Building_Dean_Kamen", "#{user} is typing in a PM")
  pm_typing(user)
end

def _pm_online(user)
  #msg("Building_Dean_Kamen", "#{user} is online")
  pm_online(user)
end

def _pm_offline(user)
  #msg("Building_Dean_Kamen", "#{user} is offline")
  pm_offline(user)
end

def _group_text(id, group, user, message, metadata)
  debug("#{user} sent text (message #{id}) in #{group} #{metadata.inspect}")
  $log[id] = user
  if(message =~ /^\/[\w\d]+(@[\w\d]+)?( \W*)*/)
    metadata[:bothandle] = message.slice!(/@[\w\d]+/)
    _command(id, group, user, message[1..-1].split(' '), metadata)
  end
  group_text(id, group, user, message, metadata)
end

def _group_other(id, group, user, message, metadata)
  debug("#{user} sent content (message #{id}) in #{group} #{metadata.inspect}")
  $log[id] = user
  group_other(id, group, user, message, metadata)
end

def _group_typing(group, user)
  #debug("#{user} is typing in #{group}")
  group_typing(group, user)
end

def _command(id, group, user, args, metadata)
  command = args.shift.downcase
  if command == "ping"
    reply(id, "pong")
  elsif command == "shh"
    if(user == $master)
      if($shh)
        reply(id, "HELLO THERE")
        $shh = false
      else
        reply(id, "kk ill be quiet")
        $shh = true
      end
    else
      reply(id, "403")
    end
  else
    command(id, group, user, command, args, metadata)
  end
end

def dealwith(line)
  pm_typing = 0
  msgfrom_n = 4
  imgfrom_n = 0
  msg_read = 0
  pm_msg = 0
  userstatuschange_n = 3
  argc = line.length
  if argc == 3
    if line[0] == "User "
      if line[2] =~ /offline \(was/
        _pm_offline line[1]
      elsif line[2] =~ /online \(was/
        _pm_online line[1]
      elsif line[2] =~ / is typing/
        _pm_typing line[1]
      end
    elsif line[0] =~ /\d+ \[\d\d?:\d\d?\] /
      if line[2] =~ / >>> \[reply to [\d\?]+\] / || line[2] =~ / »»» \[reply to [\d\?]+\] /
        reply = line[2].slice!(/\[reply to [\d\?]+\] (\[mention\] )?/)[/[\d\?]+/]
        _pm_text(line[0][/\d+/], line[1], line[2][5..-1], {:reply => reply})
      elsif line[2] =~ / >>> \[/ || line[2] =~ / »»» \[/
        _pm_other(line[0][/\d+/], line[1], line[2][5..-1], {})
      elsif line[2] =~ / >>> / || line[2] =~ / »»» /
        _pm_text(line[0][/\d+/], line[1], line[2][5..-1], {})
      end
    end
  elsif argc == 4
    if line[0] =~ /\d+ \[\d\d?:\d\d?\] / && ! isme(line[2])
      if line[3] =~ / >>> \[reply to [\d\?]+\] / || line[3] =~ / »»» \[reply to [\d\?]+\] /
        reply = line[3].slice!(/\[reply to [\d\?]+\] (\[mention\] )?/)[/[\d\?]+/]
        _group_text(line[0][/\d+/], line[1], line[2], line[3][5..-1], {:reply => reply})
      elsif line[3] =~ / >>> \[/ || line[3] =~ / »»» \[/
        _group_other(line[0][/\d+/], line[1], line[2], line[3][5..-1], {})
      elsif line[3] =~ / >>> / || line[3] =~ / »»» /
        _group_text(line[0][/\d+/], line[1], line[2], line[3][5..-1], {})
      end
    elsif line[0] == "User "
      if line[2] =~ / is typing in chat/
        _group_typing(line[3], line[1])
      end
    end
  end
end

i, o, t = Open3.popen2(File.dirname(__FILE__)+"/tg/bin/telegram-cli -k tg-server.pub")
$cli = i
i.print "set msg_num 1\n"
resolve_username($myusername)
resolve_username($masterusername)
for channel in $channels_to_resolve
  resolve_username(channel)
end
begin
  $users = JSON.parse(File.read(File.dirname(__FILE__)+"/store.json"))
  while true
    line = o.gets
    line = line.gsub(/^.*(\r)/,"").gsub(/^K/,"").gsub(/;\d\d?m?/,"").gsub(/\e\[K/,"") #]
    parts = line.chomp.split(/\e\[\d\d?m?/) #]
    parts.delete("")
    parts.delete(" ")
    puts parts.inspect + " " + parts.length.to_s
    dealwith(parts)
  end
rescue Exception => e
  puts e.to_s
  print "\nEnding\n"
  File.write(File.dirname(__FILE__)+"/store.json", JSON.generate($users))
end
