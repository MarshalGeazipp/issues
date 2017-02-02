defmodule Issues.GithubIssues do
	
	require Logger

	@user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

	def fetch(user, project) do
		issues_url(user, project)
		|> HTTPoison.get(@user_agent)
		|> handle_response
	end

	# use a module attribute to fetch the value at compile time
	@github_url Application.get_env(:issues, :github_url)
	
	def issues_url(user, project) do
		Logger.info "fetch user #{user}'s project #{project}"
		"#{@github_url}/repos/#{user}/#{project}/issues"
	end

	def handle_response({ :ok, %{status_code: 200, body: body}}) do
		Logger.info "Successful response"
		Logger.debug fn -> inspect(body) end
		{:ok, Poison.Parser.parse!(body)}
	end

	def handle_response({ _, %{status_code: status, body: body}}) do
		Logger.error "Error #{status} returned"
		{ :error, Poison.Parser.parse!(body) } 
	end

	def handle_response({ _, %HTTPoison.Error{id: nil, reason: reason}}) do
		Logger.error "Error: We're probably offline. Reason: #{reason}"
		{ :error, ["message": reason, message: reason] }
	end
end