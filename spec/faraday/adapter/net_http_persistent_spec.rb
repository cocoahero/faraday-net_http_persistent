# frozen_string_literal: true

RSpec.describe Faraday::Adapter::NetHttpPersistent do
  features :request_body_on_query_methods, :reason_phrase_parse, :compression, :trace_method, :streaming

  it_behaves_like "an adapter"

  it "allows to provide adapter specific configs" do
    url = URI("https://example.com")

    adapter = described_class.new do |http|
      http.idle_timeout = 123
    end

    http = adapter.send(:connection, url: url, request: {})
    adapter.send(:configure_request, http, {})

    expect(http.idle_timeout).to eq(123)
  end

  it "sets max_retries to 0" do
    url = URI("http://example.com")

    adapter = described_class.new

    http = adapter.send(:connection, url: url, request: {})
    adapter.send(:configure_request, http, {})

    # `max_retries=` is only present in Ruby 2.5
    expect(http.max_retries).to eq(0) if http.respond_to?(:max_retries=)
  end

  it "allows to set pool_size on initialize" do
    url = URI("https://example.com")

    adapter = described_class.new(nil, pool_size: 5)

    http = adapter.send(:connection, url: url, request: {})

    expect(http.pool.size).to eq(5)
  end

  it "allows to set verify_hostname in SSL settings to false" do
    url = URI("https://example.com")

    adapter = described_class.new(nil)

    http = adapter.send(:connection, url: url, request: {})
    adapter.send(:configure_ssl, http, verify_hostname: false)

    expect(http.verify_hostname).to eq(false)
  end

  context "min_version" do
    it "allows to set min_version in SSL settings" do
      url = URI("https://example.com")

      adapter = described_class.new(nil)

      http = adapter.send(:connection, url: url, request: {})
      adapter.send(:configure_ssl, http, min_version: :TLS1_2)

      expect(http.min_version).to eq(:TLS1_2)
    end
  end
end
