require_relative "../test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_share_path

    assert_response :success
    assert_select "form[action=?]", shares_path
    assert_select "textarea[name=?]", "share[content]"
  end

  test "new renders form for new share" do
    get new_share_path

    assert_select "input[name='share[slug]']" do |elements|
      assert_equal "", elements.first["value"].to_s
    end

    assert_select "textarea[name='share[content]']", text: ""
  end

  test "should create share with valid params" do
    assert_difference("Share.count", 1) do
      post shares_path, params: {
        share: {
          slug: "test-slug",
          content: "# Test content"
        }
      }
    end

    share = Share.last
    assert_redirected_to share_path(share.slug)
    assert_equal share.edit_token, cookies["owner_#{share.slug}"]
  end

  test "should auto-generate slug if not provided" do
    share = Share.new(content: "# Test content")
    share.has_files = false
    share.save!

    assert_not_nil share.slug
    assert_match /\A[a-z0-9\-]+\z/, share.slug
  end

  test "should create share with files" do
    file = fixture_file_upload("test_file.txt", "text/plain")

    assert_difference("Share.count", 1) do
      post shares_path, params: {
        share: {
          content: "# Test with file",
          files: [ file ]
        }
      }
    end

    share = Share.last
    assert share.files.attached?
    assert_equal 1, share.files.count
  end

  test "should not create share with invalid params" do
    assert_no_difference("Share.count") do
      post shares_path, params: {
        share: {
          slug: "INVALID SLUG",
          content: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form[action=?]", shares_path
  end

  test "should not create share without content or files" do
    assert_no_difference("Share.count") do
      post shares_path, params: {
        share: {
          slug: "test-slug",
          content: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".errors", /must have either content or files/i
  end

  test "should not create share with duplicate slug" do
    Share.create!(slug: "existing-slug", content: "Test")

    assert_no_difference("Share.count") do
      post shares_path, params: {
        share: {
          slug: "existing-slug",
          content: "Another test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show share" do
    share = Share.create!(
      slug: "show-test",
      content: "# Test content"
    )

    get share_path(share.slug)

    assert_response :success
    assert_select "div.markdown-content"
  end

  test "should show edit link when has valid cookie" do
    share = Share.create!(
      slug: "cookie-test",
      content: "Test"
    )

    cookies["owner_#{share.slug}"] = share.edit_token
    get share_path(share.slug)
    assert_select "a[href=?]", edit_share_path(share), text: "Edit"
  end

  test "should not show edit link without valid cookie" do
    share = Share.create!(
      slug: "no-cookie-test",
      content: "Test"
    )

    get share_path(share.slug)

    assert_select "a[href=?]", edit_share_path(share), count: 0
  end

  test "should display files when attached" do
    share = Share.create!(
      slug: "file-test",
      content: "Test"
    )
    share.files.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "test_file.txt")),
      filename: "test_file.txt"
    )

    get share_path(share.slug)

    assert_select "h2", text: "Files"
    assert_select ".file-name", text: "test_file.txt"
    assert_select "a", text: "Download"
  end
end
