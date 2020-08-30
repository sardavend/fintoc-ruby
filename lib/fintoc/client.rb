require 'http'
require 'fintoc/utils'
require 'fintoc/errors'
require 'fintoc/resources/link'
require 'fintoc/constants'
require 'fintoc/version'
require 'json'

module Fintoc
  class Client
    include Utils
    def initialize(api_key)
      @api_key = api_key
      @user_agent = "fintoc-ruby/#{Fintoc::VERSION}"
      @headers = { "Authorization": @api_key, "User-Agent": @user_agent }
      @link_headers = nil
      @pattern = '<(?<url>.*)>;\s*rel="(?<rel>.*)"'
      @default_params = {}
      client
    end

    def get
      request('get')
    end

    def post
      request('post')
    end

    def delete
      request('delete')
    end

    def request(method)
      proc do |resource, **kwargs|
        parameters = method == 'get' ?  { params: { **@default_params, **kwargs } } : { json: { **@default_params, **kwargs } }

        response = make_request method, resource, parameters
        content = JSON.parse(response.body, symbolize_names: true)
        if response.status.client_error? || response.status.server_error?
          msg = content[:error][:message]
          doc_url = content[:error][:doc_url]
          code = content[:error][:code]
          raise error_class(code).new(msg, doc_url)
        end
        @link_headers = response.headers.get('link')
        content
      end
    end

    def make_request(method, resource, parameters)
      # this is to handle url returned in the link headers
      # I'm sure there is a better and more clever way to solve this
      if resource.include? '/v1/'
        client.send(method, resource)
      else
        client.send(method, "#{Fintoc::Constants::SCHEME}#{Fintoc::Constants::BASE_URL}#{resource}", parameters)
      end
    end

    def error_class(snake_code)
      pascal_klass_name = Utils.snake_to_pascal snake_code
      # this conditional klass_name is to handle InternalServerError custom error class
      # without this the error class name would be like InternalServerErrorError (^-^)
      klass = pascal_klass_name.end_with?('Error') ? pascal_klass_name : pascal_klass_name + 'Error'
      Module.const_get("Fintoc::Errors::#{klass}")
    end

    # This attribute getter Parse the link headers using some regex 24K magic in the air... 
    # Ex.
    # <https://api.fintoc.com/v1/links?page=1>; rel="first", <https://api.fintoc.com/v1/links?page=1>; rel="last"
    # this helps to handle pagination see: https://fintoc.com/docs#paginacion 
    # return a hash like { first:"https://api.fintoc.com/v1/links?page=1" }
    #
    # @param link_headers [String]
    # @return [Hash]
    def link_headers
      return if @link_headers.nil?

      @link_headers[0].split(',').reduce({}) { |dict, link| parse_headers(dict, link) }
    end

    def fetch_next
      next_ = link_headers['next']
      Enumerator.new do |yielder|
        while next_
          yielder << get.call(next_)
          next_ = link_headers['next']
        end
      end
    end

    def link(link_token)
      data = {**get_link(link_token), "link_token": link_token}
      build_link(data)
    end

    def links
      get_links.each{ |data| build_link(data) }
    end

    def create_link(username, password, holder_type, institution_id)
      credentials = {
        username: username,
        password: password,
        holder_type: holder_type,
        institution_id: institution_id
      }
      data = post_link(credentials)
      build_link(data)
    end

    def delete_link(link_id)
      delete("links/#{link_id}")
    end

    def account(link_token, account_id)
      link(link_token).find(id: account_id)
    end

    def to_s
      visible_chars = 4
      hidden_part = '*' * (@api_key.size - visible_chars)
      visible_key = @api_key.slice(0, visible_chars)
      "Client(🔑=#{hidden_part + visible_key}"
    end

    private

    def client
      @client ||= HTTP.headers(@headers)
    end

    def parse_headers(dict, link)
      link = link.strip
      matches = link.match(@pattern)
      dict[matches[:rel]] = matches[:url]
      dict
    end

    def get_link(link_token)
      get.call("links/#{link_token}")
    end

    def get_links
      get.call('links')
    end

    def post_link(credentials)
      post.call('links', credentials)
    end

    def build_link(data)
      param = Utils.pick(data, 'link_token')
      @default_params.update(param)
      Link.new(**data, client: self)
    end
  end
end
