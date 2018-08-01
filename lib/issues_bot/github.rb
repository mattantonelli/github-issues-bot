require "graphql/client"
require "graphql/client/http"

module IssuesBot
  module Github
    URL = 'https://api.github.com/graphql'.freeze

    HttpAdapter = GraphQL::Client::HTTP.new(URL) do
      def headers(context)
        {
          "Authorization" => "Bearer #{CONFIG.github_token}",
          "User-Agent" => 'Ruby'
        }
      end
    end

    Schema = GraphQL::Client.load_schema(HttpAdapter)
    Client = GraphQL::Client.new(schema: Schema, execute: HttpAdapter)

    class Issues
      QUERY = Github::Client.parse <<-GRAPHQL
        query($url:URI!, $issue:Int!) {
          resource(url: $url) {
            ... on Repository {
              issueOrPullRequest(number: $issue) {
                ... on Issue {
                  url
                }
                ... on PullRequest {
                   url
                }
              }
            }
          }
        }
      GRAPHQL

      def self.find(url, issue)
        response = Github::Client.query(QUERY, variables: { url: URI(url), issue: issue })
        if errors = response.errors.any?
          errors.each { |error| Discordrb::LOGGER.error(error)}
        else
          response.data.resource.issue_or_pull_request.url
        end
      end
    end
  end
end
