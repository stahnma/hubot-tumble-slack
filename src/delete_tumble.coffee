# Description:
#   Demonstrates how to use the hubot-slack v4.1.0 ReactionMessage

handleReaction = (res) ->
  message = res.message
  item = message.item
  switch item.type
    when 'message'
      desc = "the message from channel #{item.channel} at time #{item.ts}"
    when 'file'
      desc = "the file with ID #{item.file}"
    when 'file_comment'
      desc = "the comment with ID #{item.file_comment} for file #{item.file}"
    else
      desc = "an item of type #{item.type} that I don't recognize"
  type = message.type
  user = "#{message.user.real_name} (@#{message.user.name})"
  reaction = message.reaction
  preposition = if type is 'added' then 'to' else 'from'
  res.reply "#{user} #{type} a *#{reaction}* reaction #{preposition} #{desc}."

handleDelete = (res) ->
  message = res.message
  item = message.item

  if item.type == 'message'
     desc = "the message from channel #{item.channel} at time #{item.ts}"
  type = message.type
  user = "#{message.user.real_name} (@#{message.user.name})"
  reaction = message.reaction
  res.reply JSON.stringify(message, null, 4)

module.exports = (robot) ->
  handleDelete = (res) ->
    # do the delete?
    console.log('deletin')
    
  handleAnotherReaction = (res) ->
    message = res.message
    item = message.item
    if item.type == 'message'  and message.type == 'added' and message.reaction == 'x'
      robot.adapter.client.web.conversations.history(item.channel, { limit: 1, inclusive: true, oldest: item.ts})
      .then (result, reject) ->
        console.log result.messages[0].text
      .catch (error ) ->
        console.log error

  robot.react handleAnotherReaction
#      .then = (result) ->
#        console.log result
#	message = result.messages[0]
#	console.log(message.text)
      
      #  (err) -> 
#	res.send('could not find message in channel');
      

#let handleAnotherReaction = function(res) {
#    const item = res.message.item;
#    if (item.type === 'message') {
#      robot.adapter.client.web.channels.history(item.channel, {
#        count: 1,
#        inclusive: true,
#        latest: item.ts
#      })
#        .then((result) => {
#          const message = result.messages[0];
#          if (message.ts !== item.ts) { throw new Error(); }
#          console.log(message.text); // TADA!
#        })
#        .catch(() => res.send('could not find message in channel'));
#  }
#}

#module.exports = (robot) ->

#  robot.react handleReaction
#  robot.react handleDelete
#  robot.logger.info 'Listening for reaction_added, reaction_removed events'
