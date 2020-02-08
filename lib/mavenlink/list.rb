# frozen_string_literal: true

module Mavenlink
  class List
    include Enumerable

    attr_accessor :data

    attr_reader :page_number
    attr_reader :page_count

    def initialize(klass, response)
      @meta = response["meta"]
      @klass = klass
      @page_number = @meta["page_number"]
      @page_count = @meta["page_count"]
      results = Util.results(response)
      @data = results.map { |thing| klass.new(thing) }
    end

    def each(&blk)
      @data.each(&blk)
    end

    def auto_paging_each(&blk)
      return enum_for(:auto_paging_each) unless block_given?

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
      @klass.list(page: @page_number + 1)
    end
  end
end
