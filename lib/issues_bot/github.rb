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

    class Info
      QUERY = Github::Client.parse <<-GRAPHQL
        query($url: URI!) {
          resource(url: $url) {
            ... on Repository {
              name
              description
              pushedAt
              watchers {
                totalCount
              }
              stargazers {
                totalCount
              }
              forks {
                totalCount
              }
              openIssues: issues(states: OPEN) {
                totalCount
              }
              closedIssues: issues(states: CLOSED) {
                totalCount
              }
              openPullRequests: pullRequests(states: OPEN) {
                totalCount
              }
              mergedPullRequests: pullRequests(states: MERGED) {
                totalCount
              }
            }
          }
        }
      GRAPHQL

      def self.find(url)
        Github::Client.query(QUERY, variables: { url: URI(url) }).data.resource
      end
    end

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
        errors = response.original_hash['errors']

        if errors
          errors.each { |error| Discordrb::LOGGER.error(error['message'])}
          nil
        else
          response.data.resource.issue_or_pull_request.url
        end
      end
    end
  end
end
