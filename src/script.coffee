# Description
#   A Hubot script to download anime videos
#
# Dependencies:
#   "anime-dl": "^2.0.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot anime-dl search <anime> - Search a anime and get the correct name
#   hubot anime-dl get <anime> chapter <chapter> - Get the link chapter
#
# Author:
#   lgaticaq

animeDl = require "anime-dl"

module.exports = (robot) ->
  sendMessage = (text, res) ->
    robot.emit "slack.attachment",
      text: text
      channel: res.message.room

  robot.respond /anime-dl get ([\w\W\d\s]+) chapter (\d+)/, (res) ->
    anime = res.match[1]
    chapter = res.match[2]
    animeDl.getLinksByNameAndChapter(anime, chapter).then (data) ->
      if data.urls.length is 0
        res.send "Not found links :cry:"
        return
      hd = data.urls[data.urls.length - 1]
      sendMessage "<#{hd}|#{anime} - #{chapter}>", res
    .catch (err) ->
      if /Only\ chapters\ from\ 1\ to\ /.test(err.message)
        res.send err.message
        return
      res.reply "an error occurred"
      robot.emit "error", err

  robot.respond /anime-dl search ([\w\W\d\s]+)/, (res) ->
    anime = res.match[1]
    animeDl.searchAnime(anime).then (data) ->
      if data.length is 0
        res.send "Not found anime :cry:"
        return
      message = ""
      for d in data
        message += ">*#{d.name}\n"
      res.send message, res
    .catch (err) ->
      res.reply "an error occurred"
      robot.emit "error", err
