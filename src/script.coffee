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
#   hubot anime-dl get <anime> chapter <chapter> - Get the link chapter
#   hubot anime-dl fix <code> - Set fix url path
#
# Author:
#   lgaticaq

animeDl = require "anime-dl"

module.exports = (robot) ->
  robot.respond /anime-dl get ([\w\W\d\s]+) chapter (\d+)/, (res) ->
    anime = res.match[1]
    chapter = res.match[2]
    res.send("Searching...")
    p = /(http:\/\/jkanime\.net\/stream\/jkmedia\/[a-f0-9]{32}\/[a-f0-9]{32}\/1)\/[a-f0-9]{32}\//
    animeDl.getLinksByNameAndChapter(anime, chapter).then (data) ->
      if data.urls.length is 0
        res.send("Not found links :cry:")
        return
      fix = robot.brain.get("anime-dl:fix")
      message = if fix then data.urls[0].replace(p, ">$1/#{fix}/") else ">#{data.urls[0]}"
      res.send(message)
    .catch (err) ->
      res.send(err.message)
      robot.emit("error", err)

  robot.respond /anime-dl fix ([a-f0-9]{32})/, (res) ->
    robot.brain.set("anime-dl:fix", res.match[1])
    res.send("Fix saved")
