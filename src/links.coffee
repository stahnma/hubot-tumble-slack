# Description
#    Tumble Client
#
# Dependencies:
#    Having Tumble installed somewhere
#
# Configuration:
#    HUBOT_TUMBLE_BASEURL - The uri for the tumble server
#    HUBOT_TUMBLE_ROOMS - List of rooms for which tumble behavior should be
#      enabled. (Comma separated names).
#
# Commands:
#    None
#
#  Examples:
#    HUBOT_TUMBLE_BASEURL=http://tumble.delivery.puppetlabs.net
#    HUBOT_TUMBLE_ROOMS=delivery,eso-team,release-new
#
#   Todo:
#     Get an OAUTH token for GITHUB so $BOT can link to private github
#     repos/pulls
#
# Author:
#  stahnma
#
QS = require "querystring"

{WebClient} = require "@slack/client"

env = process.env
module.exports = (robot) ->

  # used for reactions
  web = new WebClient robot.adapter.options.token

  room_whitelist = []
  unless env.HUBOT_TUMBLE_BASEURL?
      robot.logger.error 'The HUBOT_TUMBLE_BASEURL environment variable not set'
#  unless env.HUBOT_TUMBLE_ROOMS?
#      robot.logger.error 'The HUBOT_TUMBLE_ROOMS environment variable not set'
#       room_whitelist = env.HUBOT_TUMBLE_ROOMS.split(',')

  # Always add shell to the room whitelist...mostly for testing purposes.
  room_whitelist.push 'Shell'
  tumble_base = env.HUBOT_TUMBLE_BASEURL
  robot.logger.info "Tumble base is " + tumble_base
  console.log ("Tumble base is " + tumble_base )


#TODO saftety this for slack adapter vs shell
#TODO handle when tumble the web service is totally down
#TODO ignore things in the tumble-info panel
#TODO add deletes with emoji reaction
#TODO get the channel to post the link
#TODO see if you can embed the message in the tumble-info post
#TODO handle a bad link like https://www.amazon.com/gp/product/0385345224?tag=judgeabook-20
#TODO Abstract hard-coded items.
#TODO Break quotes into a diff file

  # Process a tumble link
  robot.hear /http:\/\/|https:\/\//i, (msg) ->
      room = msg['message']['room']
      #user = msg['message']['user']['mention_name']
      mention = robot.brain.data.users[msg.message.user.id].slack.profile.display_name
      user = mention

      unless user or room == 'Shell'
        return null
      if !user and room == "Shell"
          user = 'hubot tester'
      #if room  in room_whitelist
      if true
          said = msg['message']['text']
          words = said.split /\s+/
          for w in words
            if w.match( /http:\/\/|https:\/\//)
              url = w
          tumble_url = tumble_base + "/link/"
          data  = QS.stringify url: url, user: user
          # exclude putting zoom links on the aggregator
          if url.match ( /zoom\.us/ )
              return
# TODO slack safety
          if robot.adapter.options && robot.adapter.options.token
            chs = web.conversations.info
              channel: "#{msg.message.rawMessage.channel}"
            chs.then (channelobject) ->
              channel_name = channelobject.channel.name_normalized
              data  = QS.stringify url: url, user: user, channel: channel_name
              try
                msg.http(tumble_base)
                .path('/link')
                .header("Content-Type", "application/x-www-form-urlencoded")
                .post(data ) (error, response, body) ->
     #             console.log(msg.message.rawMessage)
     #             https://stahnma.slack.com/archives/C02F85RLLFK/p1672368398759299
                  link_to_message = "https://stahnma.slack.com/archives/" + msg.message.rawMessage.channel + "/p" + msg.message.rawMessage.ts.replace /\./, ''
                  #console.log link_to_message
                  ack =
                     text: "<http://tumble.devops.af:4567|tumble> link <#{body}|#{body.split('/').pop()}> posted in <#" + msg.message.rawMessage.channel + "> by <@#{msg.message.user.id}> (<#{link_to_message}|slack archive>)"
                     unfurl_links: false
                  robot.messageRoom  'tumble-info',  ack
                  if robot.adapter.options && robot.adapter.options.token
                    # Post emoji reaction when processing (not sure it means it worked)
                    web.reactions.add
                      name: 'fish',
                      channel: "#{msg.message.rawMessage.channel}",
                      timestamp: "#{msg.message.rawMessage.ts}"

                  if response['statusCode'] >= 400
                    console.log("Something went wrong posting to tumble. (Error 1) #{url}")
                    console.log("Error is #{error}")

              catch error
                msg.send("Something went wrong")
                console.log("Something went wrong posting to tumble. (Error 2) #{url}")
                console.log("Error is #{error}")
