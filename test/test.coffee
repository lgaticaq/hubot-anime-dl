Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")
path = require("path")

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
      nock.disableNetConnect();
      nock("http://jkanime.net")
        .get("/buscar/asdf")
        .replyWithFile(200, path.join(__dirname, "not_found.html"))
      room.user.say("user", "hubot anime-dl search asdf")
      setTimeout(done, 100)

    it "should return a error for invalid chapter", ->
      expect(room.messages).to.eql([
        ["user", "hubot anime-dl search asdf"]
        ["hubot", "Not found anime :cry:"]
      ])

  context "invalid chapter", ->
    beforeEach (done) ->
      nock.disableNetConnect();
      nock("http://jkanime.net")
        .get("/buscar/one%20piece")
        .replyWithFile(200, path.join(__dirname, "found.html"))
      nock("http://jkanime.net")
        .get("/one-piece")
        .replyWithFile(200, path.join(__dirname, "chapters.html"))
      room.user.say("user", "hubot anime-dl get one piece chapter 100000")
      setTimeout(done, 100)

    it "should return a error for chapter outside in range", ->
      expect(room.messages).to.eql([
        ["user", "hubot anime-dl get one piece chapter 100000"]
        ["hubot", "Searching..."]
        ["hubot", "Only chapters from 1 to 732"]
      ])

  context "valid anime and chapter", ->
    beforeEach (done) ->
      nock.disableNetConnect();
      nock("http://jkanime.net")
        .get("/buscar/one%20piece")
        .replyWithFile(200, path.join(__dirname, "found.html"))
      nock("http://jkanime.net")
        .get("/one-piece")
        .replyWithFile(200, path.join(__dirname, "chapters.html"))
      nock("http://jkanime.net")
        .get("/one-piece/100")
        .replyWithFile(200, path.join(__dirname, "chapter.html"))
      room.user.say("user", "hubot anime-dl get one piece chapter 100")
      setTimeout(done, 100)

    it "should return chapter link", ->
      expect(room.messages[0]).to.eql(
        ["user", "hubot anime-dl get one piece chapter 100"]
      )
      expect(room.messages[2][1]).to.match(/http:\/\/jkanime\.net\/stream\/jkmedia\/([0-9a-f]{32}\/[0-9a-f]{32}\/1\/[0-9a-f]{32})\//)
