{Robot, Adapter, TextMessage} = require "hubot"
builder = require "botbuilder"; # Microsoft botframework

# Skype adaptator
class Skype extends Adapter
    constructor: (@robot) ->
        # @robot is hubot
        super @robot
        # @bot is botframework
        @bot = null
        @intents = null

        # Env vars to configure the botframework
        @appID = process.env.MICROSOFT_APP_ID
        @appPassword = process.env.MICROSOFT_APP_PASSWORD

        @robot.logger.info "hubot-skype-bot: Adapter loaded."

    _createUser: (userId, address) ->
        user = @robot.brain.userForId(userId)
        if typeof address != 'undefined'
            user.address = address
        @robot.logger.debug("hubot-skype-bot: new user : ", user)
        user

    _sendMsg: (address, text) =>
        @robot.logger.debug "Bot msg: #{text}"
        msg = new builder.Message()
        msg.textFormat("plain") # By default is markdown
        msg.address(address)
        msg.text(text)
        @bot.send msg, (err) =>
                if typeof err == 'undefined'
                    @robot.logger.error "Sending msg to Skype #{err}"
                else
                    @robot.logger.debug "Msg to Skype sended correctly"
                return

    # Function used by Hubot to answer
    send: (envelope, strings...) ->
        @robot.logger.debug "Send"
        @_sendMsg envelope.user.address, strings.join "\n"

    reply: (envelope, strings...) ->
        @robot.logger.debug "Reply"
        @_sendMsg envelope.user.address, strings.join "\n"

    # Pass the msg to Hubot, appending the bot name at the beggining
    _processMsg: (msg) ->
        user = @_createUser msg.user.id, msg.address
        # Remove <at id="28:...">name</at>. This is received by the bot when called from a group
        # Append robot name at the beggining
        text = @robot.name + " " + msg.text.replace /.*<\/at>\s+(.*)$/, "$1"
        message = new TextMessage user, text, msg.address.id
        # @receive pass the message to Hubot internals
        @receive(message) if message?

    # Adapter start
    run: ->
        unless @appID
            @emit "error", new Error "You must configure the MICROSOFT_APP_ID environment variable."
        unless @appPassword
            @emit "error", new Error "You must configure the MICROSOFT_APP_PASSWORD environment variable."

        @connector = new (builder.ChatConnector)(
            appId: @appID
            appPassword: @appPassword
        )

        # Creating bot of botframework
        @bot = new (builder.UniversalBot)(@connector)

        # HTTP POST to /skype/ are passed to botframework (by default port 8080)
        @robot.router.post "/skype/", @connector.listen()

        # Anything received by the bot is parsed by the defined intents
        # If nothing is matched, pass the msg to Hubot
        @intents = new (builder.IntentDialog)
        @bot.dialog '/', @intents

        # Intents regex starts with .* to also match callings from groups, that appends <at id=...>...</at>
        # The matches function needs a regexp for the first arguments, then an array of anonymous funcs
        # Those anonymous functions receive session param, which we could use to answer, store values, etc.
        # https://docs.botframework.com/en-us/node/builder/chat-reference/classes/_botbuilder_d_.session.html
        @intents.matches /example$/i, [
          (session) =>
            session.send "This bot is a mixture between BotFramwork de Microsoft y Hubot.
If you write 'example', this message is shown.\n\n
If you write 'chat', an example dialog is started.\n\n
Otherwise, the message is passed to hubot (write for example 'ping').\n\n\n\n
In group chats, bot only will receive messages send to it. Eg.: @botname example"
            return
        ]

        # This example intent has two anonymous funcs. First one start a dialog (botframework function) with the user.
        # Second one is executed after and receive the values written by the user
        @intents.matches /chat$/i, [
          (session) =>
            session.beginDialog '/chat'
            return
          (session, results) =>
            console.log "Dialog results: #{results}"
            return
        ]

        # Si ninguno de los otros intents ha matcheado, entra en este, que pasa el mensaje a Hubot
        # Esta seria la conexion entre los mensajes de Skype y Hubot
        @intents.onDefault [
          (session, args, next) =>
            @robot.logger.debug "Msg from the user: #{session.message.text}"
            @_processMsg session.message
            return
        ]

        # If user wants to exit from any dialog at any moment it can write "goodbye"
        @bot.endConversationAction('goodbye', 'Closing dialog', { matches: /^goodbye/i });

        # This dialog receives as first argument a name (to be called from intents) and an array of anonymous functions (as seen with intents)
        # Normally you send answers and receive responses in the next func
        @bot.dialog '/chat', [
          (session) ->
            builder.Prompts.text session, "Tell me someting"
            return
          (session, results) ->
            # This is to remove <at...> from the response of a user in case of group chats
            resp = results.response.replace /.*<\/at>\s+(.*)$/, "$1"
            session.send "You said: #{resp}"

            # We can use session.userData to store values
            # Eg.: session.userData.channel_name = resp

            # To finish the dialog
            session.endDialog()
            return
        ]

        @robot.logger.info "hubot-skype-bot: Adapter running."
        @emit "connected"

exports.use = (robot) ->
    new Skype robot
