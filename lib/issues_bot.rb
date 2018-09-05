require 'rubygems'
require 'bundler/setup'
require 'ostruct'
require 'yaml'

Bundler.require(:default)

module IssuesBot
  CONFIG = OpenStruct.new(YAML.load_file('config/config.yml'))
  load 'lib/issues_bot/github.rb'

  bot = Discordrb::Commands::CommandBot.new(token: CONFIG.token, client_id: CONFIG.client_id,
                                            prefix: 'GH#', help_command: false, log_mode: :quiet)

  bot.message(contains: 'GH#') do |event|
    next unless url = CONFIG.repositories[event.server.id]

    issues = event.message.content.scan(/GH#(\d+)/).flatten.map(&:to_i)
    issue_urls = issues.map { |issue| Github::Issues.find(url, issue) }.compact

    event.message.reply(issue_urls.join("\n")) if issue_urls.any?
  end

  bot.command(:info) do |event|
    next unless url = CONFIG.repositories[event.server.id]

    info = Github::Info.find(url)
    event.channel.send_embed do |embed|
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: info.name, url: url)
      embed.description = info.description
      embed.add_field(name: "Community", value: "**Watchers:** #{info.watchers.total_count} — " \
                      "**Stars:** #{info.stargazers.total_count} — " \
                      "**Forks:** #{info.forks.total_count}")
      embed.add_field(name: "Issues", value: "**Open:** #{info.open_issues.total_count} — " \
                      "**Closed:** #{info.closed_issues.total_count}")
      embed.add_field(name: "Pull Requests", value: "**Open:** #{info.open_pull_requests.total_count} — " \
                      "**Merged:** #{info.merged_pull_requests.total_count}")
      embed.timestamp = Time.parse(info.pushed_at)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Latest commit")
    end
  end

  logfile = File.open('log.txt', 'a')
  $stderr = logfile
  Discordrb::LOGGER.streams << logfile

  bot.run
end
