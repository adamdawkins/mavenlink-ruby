# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::Story, type: :model do
  it "should be retrievable", :vcr do
    story = Mavenlink::Story.retrieve("713895605")

    expect(a_request(:get, "#{Mavenlink.api_base}/stories/713895605")).to(
      have_been_made
    )
    expect(story).to be_a Mavenlink::Story
  end

  it "should be listable", :vcr do
    stories = Mavenlink::Story.list
    expect(a_request(:get, "#{Mavenlink.api_base}/stories")).to have_been_made
    expect(stories).to be_a Mavenlink::List
    expect(stories.first).to be_a Mavenlink::Story
  end
end
