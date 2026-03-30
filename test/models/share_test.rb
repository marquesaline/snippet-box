require_relative "../test_helper"

class ShareTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    share = Share.new(slug: "aula-react-1", content: "const hello = 'world';")
    assert share.valid?
  end

  test "should auto-generate slug if not provided" do
    share = Share.new(content: "Test content", has_files: false)
    assert share.save
    assert_not_nil share.slug
    assert_match /\A[a-z0-9\-]+\z/, share.slug
  end

  test "should not save share without content" do
    share = Share.new(slug: "aula-react-1")
    assert_not share.save
  end

  test "should not save share with duplicate slug" do
    Share.create(slug: "aula-react-1", content: "First share")
    share = Share.new(slug: "aula-react-1", content: "Second share")
    assert_not share.save
  end

  test "should not save share with invalid slug format (uppercase)" do
    share = Share.new(slug: "Aula-React", content: "const hello = 'world';")
    assert_not share.save
  end

  test "should not save share with invalid slug format (spaces)" do
    share = Share.new(slug: "aula react", content: "const hello = 'world';")
    assert_not share.save
  end

  test "should not save share with invalid slug format (special characters)" do
    share = Share.new(slug: "aula@react!", content: "const hello = 'world';")
    assert_not share.save
  end

  test "should generate edit_token automatically" do
    share = Share.create(slug: "aula-react-1", content: "const hello = 'world';")
    assert_not_nil share.edit_token
  end

  test "should generate unique edit_tokens for different shares" do
    share1 = Share.create(slug: "aula-1", content: "First")
    share2 = Share.create(slug: "aula-2", content: "Second")
    assert_not_equal share1.edit_token, share2.edit_token
  end

  test "should not save share with more than 5 files" do
    share = Share.new(content: "Test", has_files: true)

    6.times do |i|
      share.files.attach(
        io: StringIO.new("content"),
        filename: "test#{i}.txt"
      )
    end

    assert_not share.valid?
    assert_includes share.errors[:files], "can't exceed 5 files"
  end

  test "should not save share with file larger than 5MB" do
    share = Share.new(content: "Test", has_files: true)

    large_content = "a" * 6.megabytes
    share.files.attach(
      io: StringIO.new(large_content),
      filename: "large.txt"
    )

    assert_not share.valid?
    assert_includes share.errors[:files], "large.txt is too large (max 5MB)"
  end

  test "should save share with valid files" do
    share = Share.new(content: "Test")

    3.times do |i|
      share.files.attach(
        io: StringIO.new("small content"),
        filename: "test#{i}.txt"
      )
    end

    share.save!

    assert share.persisted?
    assert_equal 3, share.files.count
    assert share.valid?
  end

  # Expiry options
  test "should expire in 30 days by default" do
    share = Share.create!(slug: "expiry-default", content: "Test")
    assert_not_nil share.expires_at
    assert_in_delta 30.days.from_now, share.expires_at, 5.seconds
  end

  test "should expire in 1 hour when expiry_option is 1h" do
    share = Share.new(slug: "expiry-1h", content: "Test")
    share.expiry_option = "1h"
    share.save!
    assert_in_delta 1.hour.from_now, share.expires_at, 5.seconds
  end

  test "should expire in 1 day when expiry_option is 1d" do
    share = Share.new(slug: "expiry-1d", content: "Test")
    share.expiry_option = "1d"
    share.save!
    assert_in_delta 1.day.from_now, share.expires_at, 5.seconds
  end

  test "should expire in 7 days when expiry_option is 7d" do
    share = Share.new(slug: "expiry-7d", content: "Test")
    share.expiry_option = "7d"
    share.save!
    assert_in_delta 7.days.from_now, share.expires_at, 5.seconds
  end

  test "should never expire when expiry_option is never" do
    share = Share.new(slug: "expiry-never", content: "Test")
    share.expiry_option = "never"
    share.save!
    assert_nil share.expires_at
  end

  test "expiry_label returns never expires when expires_at is nil" do
    share = Share.new(slug: "label-never", content: "Test")
    share.expiry_option = "never"
    share.save!
    assert_equal "Never expires", share.expiry_label
  end

  test "expiry_label returns formatted date when expires_at is set" do
    share = Share.create!(slug: "label-date", content: "Test")
    expected = "Expires #{share.expires_at.strftime("%b %d, %Y")}"
    assert_equal expected, share.expiry_label
  end

  # Language detection
  test "detected_languages returns empty array when no fenced code blocks" do
    share = Share.new(content: "Just plain text")
    assert_empty share.detected_languages
  end

  test "detected_languages returns languages from fenced code blocks" do
    share = Share.new(content: "# Title\n\n```ruby\nputs 'hello'\n```\n\n```javascript\nconsole.log('hi')\n```")
    assert_equal [ "ruby", "javascript" ], share.detected_languages
  end

  test "detected_languages deduplicates repeated languages" do
    share = Share.new(content: "```ruby\ncode\n```\n\n```ruby\nmore\n```")
    assert_equal [ "ruby" ], share.detected_languages
  end

  test "detected_languages returns empty when content is blank" do
    share = Share.new(content: nil)
    assert_empty share.detected_languages
  end

  # Views count
  test "views_count starts at 0" do
    share = Share.create!(slug: "views-test", content: "Test")
    assert_equal 0, share.views_count
  end
end
