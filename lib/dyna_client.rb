# frozen_string_literal: true

require 'faraday'
require 'json'

module DynaClient
  class Api
    def initialize(json_path)
      @json = JSON.parse(File.read(json_path))
      @conn = Faraday.new
      define_from_json
    end

    def define_from_json
      @json.each do |key, value|
        if value.is_a?(Array)
          value.each do |v|
            self.class.send(:define_method, "#{v["name"]}") do |params = nil, headers = nil|
              @conn.send(v["method"].downcase.to_sym, v["url"], params, headers)
            end
          end
        elsif value.is_a?(Hash)
          self.class.send(:define_method, "#{value["name"]}") do |params = nil, headers = nil|
            @conn.send(value["method"].downcase.to_sym, value["url"], params, headers)
          end
        end
      end
    end
  end
end
