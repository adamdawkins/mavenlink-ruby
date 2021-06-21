# frozen_string_literal: true

module Mavenlink
  class List
    include Enumerable

    attr_accessor :data

    attr_reader :page_number
    attr_reader :page_count

    def initialize(klass, response, options = {}, params = {})
      @meta = response["meta"]
      @klass = klass
      @params = params
      @page_number = @meta["page_number"]
      @page_count = @meta["page_count"]
      @options = options
      results = setup_results(response)
      @data = results.map { |thing| klass.new(thing) }
    end

    def each(&blk)
      @data.each(&blk)
    end

    def auto_paging_each(&blk)
      return enum_for(:auto_paging_each) unless blk

      page = self
      loop do
        page.each(&blk)

        break if page.last_page?

        page = page.next_page
      end
    end

    def last_page?
      @page_number == @page_count
    end

    def next_page
      @klass.list(@params.merge(page: @page_number + 1), @options)
    end

    private def setup_results(response)
      results = Util.results(response)

      if (filters = Util.stringify_keys(@options[:filters]))
        results.select! do |res|
          filters.map { |key, value| res[key] == value }.all?
        end
      end

      results
    end
  end
end
