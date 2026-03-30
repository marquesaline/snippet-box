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

  test "new renders expiry select" do
    get new_share_path
    assert_select "select[name='share[expiry_option]']"
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

  test "should create share with expiry option 1h" do
    post shares_path, params: {
      share: { slug: "expiry-1h", content: "Test", expiry_option: "1h" }
    }
    share = Share.last
    assert_in_delta 1.hour.from_now, share.expires_at, 5.seconds
  end

  test "should create share with expiry option never" do
    post shares_path, params: {
      share: { slug: "expiry-never", content: "Test", expiry_option: "never" }
    }
    assert_nil Share.last.expires_at
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

    assert_response :redirect
    follow_redirect!
    assert_response :success

    share = Share.last
    assert_not_nil share, "Share should be created"
    assert share.files.attached?, "Files should be attached"
    assert_equal 1, share.files.count, "Should have exactly 1 file"
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

  test "should increment views_count on show for non-owner" do
    share = Share.create!(slug: "views-test", content: "Test")
    assert_difference -> { share.reload.views_count }, 1 do
      get share_path(share.slug)
    end
  end

  test "should not increment views_count when owner views" do
    share = Share.create!(slug: "owner-views-test", content: "Test")
    cookies["owner_#{share.slug}"] = share.edit_token

    assert_no_difference -> { share.reload.views_count } do
      get share_path(share.slug)
    end
  end

  test "should show raw content" do
    share = Share.create!(slug: "raw-test", content: "# Hello\n\nSome content")

    get raw_share_path(share.slug)

    assert_response :success
    assert_equal "text/plain; charset=utf-8", response.content_type
    assert_equal share.content, response.body
  end

  test "raw returns no_content when share has no content" do
    share = Share.new(slug: "raw-files-only")
    share.has_files = true
    share.files.attach(io: StringIO.new("data"), filename: "f.txt")
    share.save!

    get raw_share_path(share.slug)

    assert_response :no_content
  end

  test "should fork a share" do
    share = Share.create!(slug: "fork-source", content: "# Original")

    assert_difference("Share.count", 1) do
      post fork_share_path(share.slug)
    end

    forked = Share.last
    assert_equal share.content, forked.content
    assert_not_equal share.slug, forked.slug
    assert_redirected_to edit_share_path(forked.slug)
  end

  test "fork sets owner cookie for forked share" do
    share = Share.create!(slug: "fork-cookie", content: "Test")
    post fork_share_path(share.slug)
    forked = Share.last
    assert_equal forked.edit_token, cookies["owner_#{forked.slug}"]
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

  test "show displays language badges for fenced code blocks" do
    share = Share.create!(slug: "lang-badge", content: "```ruby\nputs 'hi'\n```")

    get share_path(share.slug)

    assert_select ".language-badge", text: "Ruby"
  end

  test "show uses first heading as page title" do
    share = Share.create!(slug: "seo-title", content: "# My Snippet\n\nSome content")

    get share_path(share.slug)

    assert_select "title", text: /My Snippet/
  end

  test "show displays view count" do
    share = Share.create!(slug: "view-count-display", content: "Test")

    get share_path(share.slug)

    assert_select ".share-views"
  end

  test "show displays expiry label" do
    share = Share.create!(slug: "expiry-display", content: "Test")

    get share_path(share.slug)

    assert_select ".share-expiry"
  end
end
