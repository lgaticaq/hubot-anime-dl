Helper = require("hubot-test-helper")
expect = require("chai").expect
proxyquire = require("proxyquire")
animeDlStub =
  getLinksByNameAndChapter: (anime, chapter) ->
    return new Promise (resolve, reject) ->
      if anime is "not_found"
        reject(new Error("Not found anime with keyword #{anime}"))
      else if chapter is "100000"
        reject(new Error("Only chapters from 1 to 20"))
      else
        resolve({urls: ["http://jkanime.net/stream/jkmedia/f0ba23ff34345f16c0f54abe1346a8f2/a28e5f284a491ba9f012bd30c66f58ee/1/a854fc803138d458f0e47287d7e1d3da/"]})
proxyquire("./../src/script.coffee", {"anime-dl": animeDlStub})

helper = new Helper("./../src/index.coffee")

describe "hubot-anime-dl", ->
  room = null
  @timeout(20000)

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context "invalid anime", ->
    beforeEach (done) ->
      room.user.say("user", "hubot anime-dl get not_found chapter 1")
      setTimeout(done, 100)

    it "should return a error for invalid chapter", ->
      expect(room.messages).to.eql([
        ["user", "hubot anime-dl get not_found chapter 1"]
        ["hubot", "Searching..."]
        ["hubot", "Not found anime with keyword not_found"]
      ])

  context "invalid chapter", ->
    beforeEach (done) ->
      room.user.say("user", "hubot anime-dl get one piece chapter 100000")
      setTimeout(done, 100)

    it "should return a error for chapter outside in range", ->
      expect(room.messages).to.eql([
        ["user", "hubot anime-dl get one piece chapter 100000"]
        ["hubot", "Searching..."]
        ["hubot", "Only chapters from 1 to 20"]
      ])

  context "valid anime and chapter", ->
    beforeEach (done) ->
      room.user.say("user", "hubot anime-dl get one piece chapter 100")
      setTimeout(done, 100)

    it "should return chapter link", ->
      expect(room.messages[0]).to.eql(
        ["user", "hubot anime-dl get one piece chapter 100"]
      )
      expect(room.messages[2][1]).to.match(/http:\/\/jkanime\.net\/stream\/jkmedia\/([0-9a-f]{32}\/[0-9a-f]{32}\/1\/[0-9a-f]{32})\//)
