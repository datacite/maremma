require 'spec_helper'

describe Maremma do
  subject { Maremma }
  let(:url) { "http://example.org" }
  let(:data) { { "name" => "Fred" } }
  let(:post_data) { { "name" => "Jack" } }

  context "get" do
    it "get json" do
      stub = stub_request(:get, url).to_return(:body => data.to_json, :status => 200, :headers => { "Content-Type" => "application/json" })
      response = subject.get(url)
      expect(response).to eq("data" => data)
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "application/xml" })
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("data" => data)
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_return(:body => data.to_s, :status => 200, :headers => { "Content-Type" => "text/html" })
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("data" => data.to_s)
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => data.to_xml, :status => 200, :headers => { "Content-Type" => "text/html" })
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(Hash.from_xml(response.to_s)["hash"]).to eq(data) }
      expect(stub).to have_been_requested
    end

    it "get json with params" do
      params = { q: "*:*",
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,xml,minted,updated",
                 fq: %w(has_metadata:true is_active:true),
                 facet: "true",
                 'facet.field' => %w(resourceType_facet publicationYear datacentre_facet),
                 'facet.limit' => 10,
                 'f.resourceType_facet.facet.limit' => 15,
                 wt: "json" }.compact
      url = "http://example.org?" + URI.encode_www_form(params)
      stub = stub_request(:get, url).to_return(:body => data.to_json, :status => 200, :headers => { "Content-Type" => "application/json" })
      response = subject.get(url)
      expect(response).to eq("data" => data)
      expect(stub).to have_been_requested
      expect(url).to eq("http://example.org?q=*%3A*&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=resourceType_facet&facet.field=publicationYear&facet.field=datacentre_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&wt=json")
    end
  end

  context "empty response" do
    it "get json" do
      stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/json" })
      response = subject.get(url)
      expect(response).to eq("data" => nil)
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("data" => nil)
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "text/html" })
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("data" => nil)
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => nil, :status => 200, :headers => { "Content-Type" => "application/xml" })
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to eq("data" => nil) }
      expect(stub).to have_been_requested
    end
  end

  context "not found" do
    let(:error) { { "errors" => [{ "status" => 404, "title" => "Not found" }]} }

    it "get json" do
      stub = stub_request(:get, url).to_return(:body => error.to_json, :status => [404], :headers => { "Content-Type" => "application/json" })
      expect(subject.get(url)).to eq(error)
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
      expect(subject.get(url, content_type: 'xml')).to eq(error)
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_return(:body => error.to_s, :status => [404], :headers => { "Content-Type" => "text/html" })
      expect(subject.get(url, content_type: 'html')).to eq(error)
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:body => error.to_xml, :status => [404], :headers => { "Content-Type" => "application/xml" })
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(Hash.from_xml(response.to_s)["hash"]).to eq(error) }
      expect(stub).to have_been_requested
    end
  end

  context "request timeout" do
    it "get json" do
      stub = stub_request(:get, url).to_return(:status => [408])
      response = subject.get(url)
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_return(:status => [408])
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_return(:status => [408])
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_return(:status => [408])
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
      expect(stub).to have_been_requested
    end
  end

  context "request timeout internal" do
    it "get json" do
      stub = stub_request(:get, url).to_timeout
      response = subject.get(url)
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_timeout
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_timeout
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_timeout
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
      expect(stub).to have_been_requested
    end
  end

  context "rate limit exceeded" do
    it "get json" do
      stub = stub_request(:get, url).to_return(status: 200, headers: { 'X-Rate-Limit-Remaining' => 3 })
      response = subject.get(url)
      expect(response).to eq("errors"=>[{"status"=>429, "title"=>"Too many requests"}])
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_return(status: 200, headers: { 'X-Rate-Limit-Remaining' => 3 })
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("errors"=>[{"status"=>429, "title"=>"Too many requests"}])
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_return(status: 200, headers: { 'X-Rate-Limit-Remaining' => 3 })
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("errors"=>[{"status"=>429, "title"=>"Too many requests"}])
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml)
        .to_return(status: 200, headers: { 'X-Rate-Limit-Remaining' => 3 })
      subject.post(url, content_type: 'xml', data: post_data.to_xml) { |response| expect(response).to be_nil }
      expect(stub).to have_been_requested
    end
  end

  context "redirect requests" do
    let(:redirect_url) { "http://www.example.org/redirect" }

    it "redirect" do
      stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
      stub_request(:get, redirect_url).to_return(status: 200, body: "Test")
      response = subject.get(url)
      expect(response).to eq("data"=>"Test")
    end

    it "redirect four times" do
      stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
      stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url + "/x" })
      stub_request(:get, redirect_url+ "/x").to_return(status: 301, headers: { location: redirect_url + "/y" })
      stub_request(:get, redirect_url+ "/y").to_return(status: 301, headers: { location: redirect_url + "/z" })
      stub_request(:get, redirect_url + "/z").to_return(status: 200, body: "Test")
      response = subject.get(url)
      expect(response).to eq("data"=>"Test")
    end

    it "redirect limit 1" do
      stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
      stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url + "/x" })
      stub_request(:get, redirect_url+ "/x").to_return(status: 301, headers: { location: redirect_url + "/y" })
      response = subject.get(url, limit: 1)
      expect(response).to eq("errors"=>[{"status"=>400, "title"=>"too many redirects; last one to: http://www.example.org/redirect/x"}])
    end
  end

  context 'parse_error_response' do
    it 'json' do
      string = '{ "error": "An error occured." }'
      expect(subject.parse_error_response(string)).to eq("An error occured.")
    end

    it 'json not error' do
      string = '{ "customError": "An error occured." }'
      expect(subject.parse_error_response(string)).to eq("customError"=>"An error occured.")
    end

    it 'xml' do
      string = '<error>An error occured.</error>'
      expect(subject.parse_error_response(string)).to eq("An error occured.")
    end
  end

  context 'parse_success_response' do
    it 'from_json' do
      string = '{ "word": "abc" }'
      expect(subject.parse_success_response(string)).to eq("data"=>{"word"=>"abc"})
    end

    it 'from_xml' do
      string = "<word>abc</word>"
      expect(subject.parse_success_response(string)).to eq("data"=>{"word"=>"abc"})
    end

    it 'from_string' do
      string = "abc"
      expect(subject.parse_success_response(string)).to eq("data"=>"abc")
    end

    it 'from_string with utf-8' do
      string = "fön  "
      expect(subject.parse_success_response(string)).to eq("data"=>"fön")
    end
  end

  context 'connection' do
    it 'default' do
      conn = subject.faraday_conn
      expect(conn.headers).to eq("Accept"=>"application/json",
                                 "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'json' do
      conn = subject.faraday_conn('json')
      expect(conn.headers).to eq("Accept"=>"application/json",
                                 "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'xml' do
      conn = subject.faraday_conn('xml')
      expect(conn.headers).to eq("Accept"=>"application/xml",
                                 "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'html' do
      conn = subject.faraday_conn('html')
      expect(conn.headers).to eq("Accept" => "text/html; charset=UTF-8",
                                 "User-Agent" => "Maremma - https://github.com/datacite/maremma")
    end

    it 'other' do
      conn = subject.faraday_conn('application/x-bibtex')
      expect(conn.headers).to eq("Accept" => "application/x-bibtex",
                                 "User-Agent" => "Maremma - https://github.com/datacite/maremma")
    end
  end

  context 'authentication' do
    it 'no auth' do
      options = {}
      expect(subject.set_request_headers(url, options)).to eq("Host"=>"example.org")
    end

    it 'bearer' do
      options = { bearer: 'mF_9.B5f-4.1JqM' }
      expect(subject.set_request_headers(url, options)).to eq("Host"=>"example.org", "Authorization"=>"Bearer mF_9.B5f-4.1JqM")
    end

    it 'token' do
      options = { token: '12345' }
      expect(subject.set_request_headers(url, options)).to eq("Host"=>"example.org", "Authorization"=>"Token token=12345")
    end

    it 'basic' do
      options = { username: 'foo', password: '12345' }
      basic = Base64.encode64("foo:12345")
      expect(subject.set_request_headers(url, options)).to eq("Host"=>"example.org", "Authorization"=>"Basic #{basic}")
    end
  end
end
