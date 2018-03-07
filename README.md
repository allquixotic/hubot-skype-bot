# hubot-skype-bot

A Hubot adapter for Skype using the [Microsoft Bot Framework][https://dev.botframework.com/].

This adapter relies on the [Bot Builder for NodeJS](https://www.npmjs.com/package/botbuilder).

Refer to Skype Bots [documentation][https://developer.microsoft.com/en-us/skype/bots/docs] for more information.

See [`src/skype.coffee`](src/skype.coffee) for full documentation.


## Getting Started

You need 2 pieces of _credentials_ before getting started with `hubot-skype-bot`: a Microsoft application ID, and a password associated with the application ID.

### 1. Create Skype Bot

To obtain a new bot, start by [registering a new one][createbot].

For the _"Messaging Endpoint"_, set it to the URL (HTTPS) that your bot will be hosted, and accessible from, followed by a `/skype/` path. For example, if you are using [`ngrok`][ngrok] to expose your locally hosted bot, you will be entering something like: `https://unique-id.ngrok.io/skype/`

During the creation process, you will be asked for a _Microsoft Application ID_.

After bot is created, in _Skype Channel_, click on _Edit_ and enable _Group messaging_.

To start speaking with it click in the _Add to Skype_ button (in Linux, open [Skype Web](https://web.skype.com) before clicking the add button).

### 2. Create Microsoft Application

There should be a link to the [Create Microsoft App ID and password][appportal]. Once you create an application, you will be given an application ID, and a secret associated with the application ID.

### 3. Set Environment Variables

You should now have the 2 aforementioned pieces of _credentials_. Expose them to your bot environment:

```bash
export MICROSOFT_APP_ID="APP ID HERE"
export MICROSOFT_APP_PASSWORD="APP PASSWORD HERE"
```

One Hubot is running, click in _Test connection to your bot_ in [your bot page][botframeworkbots].
This will send a POST to your endpoint that will be answered with a HTTP 100.


## Installation via NPM

```bash
npm install --save hubot-skype-bot
```

Now, run Hubot with the `skype-bot` adapter:

```bash
./bin/hubot -a skype-bot
```


## Configuration

Variable | Default | Description
--- | --- | ---
`MICROSOFT_APP_ID` | N/A | Your bot's unique ID (https://dev.botframework.com/bots)
`MICROSOFT_APP_PASSWORD` | N/A | A Microsoft application ID to authenticate your bot (https://apps.dev.microsoft.com/)


[botframework]: https://dev.botframework.com/
[botframeworkbots]: https://dev.botframework.com/bots
[botframeworknodejs]: https://docs.botframework.com/en-us/node/builder/chat-reference/modules/_botbuilder_d_.html
[documentation]: https://docs.botframework.com/en-us/skype/getting-started
[createbot]: https://dev.botframework.com/bots/new
[appportal]: https://apps.dev.microsoft.com/
[ngrok]: https://ngrok.com/
