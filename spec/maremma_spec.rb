require 'spec_helper'

describe Maremma do
  subject { Maremma }
  let(:url) { "http://example.org" }
  let(:data) { { "name" => "Fred" } }
  let(:post_data) { { "name" => "Jack" } }
  let(:accept_header) { "text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5" }

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

    it "get json with params", vcr: true do
      params = { q: "*:*",
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,xml,minted,updated",
                 fq: %w(has_metadata:true is_active:true),
                 facet: "true",
                 'facet.field' => %w(resourceType_facet publicationYear datacentre_facet),
                 'facet.limit' => 10,
                 'f.resourceType_facet.facet.limit' => 15,
                 wt: "json" }.compact
      url = "https://search.datacite.org/api?" + URI.encode_www_form(params)
      expect(url).to eq("https://search.datacite.org/api?q=*%3A*&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=resourceType_facet&facet.field=publicationYear&facet.field=datacentre_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&wt=json")
      response = subject.get(url)
      facet_fields = response.fetch("data", {}).fetch("facet_counts", {}).fetch("facet_fields", {})
      expect(facet_fields["datacentre_facet"]).to eq(["CDL.DPLANET - Data-Planet", 862673, "BL.CCDC - The Cambridge Crystallographic Data Centre", 617281, "ETHZ.SEALS - E-Periodica", 511747, "ESTDOI.BIO - TÜ Loodusmuuseum", 487448, "CDL.DIGSCI - Digital Science", 431015, "TIB.R-GATE - ResearchGate", 391313, "GESIS.DIE - Deutsches Institut für Erwachsenenbildung", 373193, "ETHZ.EPICS-BA - E-Pics Bildarchiv", 355076, "TIB.PANGAEA - PANGAEA - Publishing Network for Geoscientific and Environmental Data", 346849, "BL.IMPERIAL - Imperial College London", 190482])
      expect(facet_fields["resourceType_facet"]).to eq(["Dataset", 2598715, "Text", 1390919, "Other", 873873, "Image", 704151, "Collection", 351593, "Software", 15895, "Audiovisual", 7098, "Event", 6711, "PhysicalObject", 6680, "Film", 920, "Model", 556, "InteractiveResource", 372, "Sound", 243, "Workflow", 221, "Service", 21])
      expect(facet_fields["publicationYear"]).to eq(["2015", 2040850, "2014", 936486, "2016", 522234, "2011", 339370, "2013", 335358, "2012", 214191, "2005", 163347, "2007", 159146, "2006", 146147, "2010", 144512])
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

  context "connection failed" do
    it "get json" do
      stub = stub_request(:get, url).to_raise(Faraday::ConnectionFailed.new("Connection refused - connect(2)"))
      response = subject.get(url)
      expect(response).to eq("errors"=>[{"status"=>"403", "title"=>"Connection refused - connect(2)"}])
      expect(stub).to have_been_requested
    end

    it "get xml" do
      stub = stub_request(:get, url).to_raise(Faraday::ConnectionFailed.new("Connection refused - connect(2)"))
      response = subject.get(url, content_type: 'xml')
      expect(response).to eq("errors"=>[{"status"=>"403", "title"=>"Connection refused - connect(2)"}])
      expect(stub).to have_been_requested
    end

    it "get html" do
      stub = stub_request(:get, url).to_raise(Faraday::ConnectionFailed.new("Connection refused - connect(2)"))
      response = subject.get(url, content_type: 'html')
      expect(response).to eq("errors"=>[{"status"=>"403", "title"=>"Connection refused - connect(2)"}])
      expect(stub).to have_been_requested
    end

    it "post xml" do
      stub = stub_request(:post, url).with(:body => post_data.to_xml).to_raise(Faraday::ConnectionFailed.new("Connection refused - connect(2)"))
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

  context "content negotiation" do
    it "redirects to URL", vcr: true do
      url = "http://doi.org/10.5281/ZENODO.21430"
      response = subject.get(url)
      doc = Nokogiri::HTML(response.fetch("data", ""))
      title = doc.at_css("head title").text
      expect(title).to eq("DataCite-ORCID: 1.0 - Zenodo")
    end

    it "returns content as bibtex", vcr: true do
      url = "https://doi.org/10.5281/ZENODO.21430"
      response = subject.get(url, content_type: "application/x-bibtex")
      expect(response.fetch("data", nil)).to eq("@data{198243d2-ed8a-4126-867e-5fff1e80dcfc,\n  doi = {10.5281/ZENODO.21430},\n  url = {http://dx.doi.org/10.5281/ZENODO.21430},\n  author = {Martin Fenner; Karl Jonathan Ward; Gudmundur A. Thorisson; Robert Peters; },\n  publisher = {Zenodo},\n  title = {DataCite-ORCID: 1.0},\n  year = {2015}\n}")
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

  context 'accept headers' do
    it 'default' do
      headers = subject.set_request_headers(url)
      expect(headers).to eq("Accept"=>"text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5",
                            "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'json' do
      headers = subject.set_request_headers(url, content_type: 'json')
      expect(headers).to eq("Accept"=>"application/json",
                            "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'xml' do
      headers = subject.set_request_headers(url, content_type: 'xml')
      expect(headers).to eq("Accept"=>"application/xml",
                            "User-Agent"=>"Maremma - https://github.com/datacite/maremma")
    end

    it 'html' do
      headers = subject.set_request_headers(url, content_type: 'html')
      expect(headers).to eq("Accept" => "text/html; charset=UTF-8",
                            "User-Agent" => "Maremma - https://github.com/datacite/maremma")
    end

    it 'other' do
      headers = subject.set_request_headers(url, content_type: 'application/x-bibtex')
      expect(headers).to eq("Accept" => "application/x-bibtex",
                            "User-Agent" => "Maremma - https://github.com/datacite/maremma")
    end
  end

  context 'authentication' do
    it 'no auth' do
      options = {}
      expect(subject.set_request_headers(url, options)).to eq("User-Agent"=>"Maremma - https://github.com/datacite/maremma", "Accept"=>accept_header)
    end

    it 'bearer' do
      options = { bearer: 'mF_9.B5f-4.1JqM' }
      expect(subject.set_request_headers(url, options)).to eq("User-Agent"=>"Maremma - https://github.com/datacite/maremma", "Accept"=>accept_header, "Authorization"=>"Bearer mF_9.B5f-4.1JqM")
    end

    it 'token' do
      options = { token: '12345' }
      expect(subject.set_request_headers(url, options)).to eq("User-Agent"=>"Maremma - https://github.com/datacite/maremma", "Accept"=>accept_header, "Authorization"=>"Token token=12345")
    end

    it 'basic' do
      options = { username: 'foo', password: '12345' }
      basic = Base64.encode64("foo:12345")
      expect(subject.set_request_headers(url, options)).to eq("User-Agent"=>"Maremma - https://github.com/datacite/maremma", "Accept"=>accept_header, "Authorization"=>"Basic #{basic}")
    end
  end
end
