require_relative "../test_helper"

class ShareTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    share = Share.new(slug: "aula-react-1", content: "const hello = 'world';")
    assert share.valid?
  end

  test "should auto-generate slug if not provided" do
    share = Share.new(content: "Test content")
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

    # Attach 6 files
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

    # Create a 6MB file
    large_content = "a" * 6.megabytes
    share.files.attach(
      io: StringIO.new(large_content),
      filename: "large.txt"
    )

    assert_not share.valid?
    assert_includes share.errors[:files], "large.txt is too large (max 5MB)"
  end

  test "should save share with valid files" do
    share = Share.new(content: "Test", has_files: true)

    3.times do |i|
      share.files.attach(
        io: StringIO.new("small content"),
        filename: "test#{i}.txt"
      )
    end

    assert share.valid?
    assert share.save
  end
end
