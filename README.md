# Github Issues Bot

A bot designed to provide links to issues & pull requests mentioned in your Discord server. Powered by [discordrb](https://github.com/meew0/discordrb).

## Installation

This is currently a private bot. You will need to create and run your own Discord app to add it to your server.

1. [Create a new Discord app](https://discordapp.com/developers/applications/me)
2. Create a Bot user
3. Insert your client ID into the following URL: `https://discordapp.com/oauth2/authorize?client_id=INSERT_CLIENT_ID_HERE&scope=bot&permissions=67584`
4. Follow the URL to add the bot to your server (requires the Manage Server permission)
5. `git clone https://github.com/mattantonelli/github-issues-bot`
6. `cd github-issues-bot`
7. `bundle install`
8. Set up the configuration file
    * `cp config/config.yml.example config/config.yml`
    * Updated the example values appropriately
9. `bundle exec ruby run.rb`

## Permissions

This bot requires the following permissions:

* Read Text Channels & See Voice Channels
* Send Messages
* Read Message History

## Deployment

This bot is set up for [Capistrano](https://github.com/capistrano/capistrano) deployment. The deployment strategy is dependent on `rbenv` and `screen`. You can configure it to deploy to your own server by updating `config/deploy.rb` and `config/deploy/production.rb` appropriately.

## Usage
### Commands
#### Info
![Example](https://i.imgur.com/HuTMntI.png)

### Issue/Pull Request Lookup
To look up an issue or pull request, just reference the issue # with the prefix `GH#`. For example:

```
Did you see GH#422?
```

The bot will then look up the URL configured for your server and use it to look up the issue/pull request.

## Example
![Example](https://i.imgur.com/RKXBC1k.png)
