# Description
#   A Hubot script to download anime videos
#
# Dependencies:
#   "anime-dl": "^3.0.0"
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
  robot.respond /anime-dl get ([\w\W\d\s]+) chapter (\d+)/, (res) ->
    anime = res.match[1]
    chapter = res.match[2]
    res.send "Searching..."
    animeDl.getLinksByNameAndChapter(anime, chapter).then (data) ->
      if data.urls.length is 0
        res.send "Not found links :cry:"
        return
      message = ""
      for url in data.urls
        message += ">#{url}\n"
      res.send message
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
        message += ">*#{d.name}*\n"
      res.send message, res
    .catch (err) ->
      res.reply "an error occurred"
      robot.emit "error", err
