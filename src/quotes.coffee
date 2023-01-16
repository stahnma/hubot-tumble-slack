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
#
QS = require "querystring"
{WebClient} = require "@slack/client"
env = process.env
tumble_base = env.HUBOT_TUMBLE_BASEURL
module.exports = (robot) ->
  web = new WebClient robot.adapter.options.token

  # Tumble quotes:
  robot.hear /^\s*(\"|“)(.+?)(\"|”)\s+(--|—)\s*(.+?)$/, (msg) ->
    # Now break into quote and author
    room = msg['message']['room']
    said = msg['message']['text']
    # this is two hyphens
    if /--/.test(said)
      words = said.split '--'
    # this is em-dash
    if /—/.test(said)
      words = said.split '—'
    #console.log "This is words: #{words}"
    quote = words[0].trim()
    author = words[1]
    # Remove the quotation marks themselves from the string
    quote =  quote.substring(1, quote.length - 1);
    tumble_url = tumble_base + "/quote"
    data  = QS.stringify quote: quote, author: author
    msg.http(tumble_base)
    .path('/quote')
    .header("Content-Type", "application/x-www-form-urlencoded")
    .post(data ) (error, response, body) ->
      if response['statusCode'] != 200
        msg.send "Quote Failure"
      else
        link_to_message = "https://stahnma.slack.com/archives/" + msg.message.rawMessage.channel + "/p" + msg.message.rawMessage.ts.replace /\./, ''
        #console.log link_to_message
        ack =
          text: "<http://tumble.devops.af:4567|tumble> quote posted from <#" + msg.message.rawMessage.channel + "> by <@#{msg.message.user.id}> (<#{link_to_message}|slack archive link>)"
          unfurl_links: false
        robot.messageRoom  'tumble-info',  ack
        if robot.adapter.options && robot.adapter.options.token
        # Post emoji reaction when processing (not sure it means it worked)
          web.reactions.add
            name: 'quote',
            channel: "#{msg.message.rawMessage.channel}",
            timestamp: "#{msg.message.rawMessage.ts}"
