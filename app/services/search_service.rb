class SearchService
  include HTTParty

  def self.search(query)
    response = HTTParty.get(
      "https://www.searchapi.io/api/v1/search",
      headers: {
        "Authorization" => "Bearer #{ENV['SEARCHAPI_KEY']}"
      },
      query: {
        engine: "google",
        q: query
      }
    )

    results = response.parsed_response["organic_results"] || []

    results.first(5).map.with_index(1) do |r, i|
      <<~TEXT
      #{i}. #{r['title']}
        #{r['snippet']}
      TEXT
    end.join("\n")
  end
end