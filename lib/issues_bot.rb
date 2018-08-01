require 'rubygems'
require 'bundler/setup'
require 'ostruct'
require 'yaml'

Bundler.require(:default)

module IssuesBot
  CONFIG = OpenStruct.new(YAML.load_file('config/config.yml'))
  load 'lib/issues_bot/github.rb'

  bot = Discordrb::Bot.new(token: CONFIG.token, client_id: CONFIG.client_id)

  bot.message(contains: 'GH#') do |event|
    next unless url = CONFIG.repositories[event.server.id]
    issues = event.message.content.scan(/GH#(\d+)/).flatten.map(&:to_i)

    issue_urls = issues.map { |issue| Github::Issues.find(url, issue) }

    event.message.reply(issue_urls.join("\n"))
  end

  logfile = File.open('log.txt', 'a')
  $stderr = logfile
  Discordrb::LOGGER.streams << logfile

  bot.run
end
