require "test_helper"
require 'webmock/minitest'

describe Lolcommits::Plugin::Hipchat do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  describe "with a runner" do
    def runner
      # a simple lolcommits runner with an empty configuration Hash
      @runner ||= Lolcommits::Runner.new(
        main_image: Tempfile.new('main_image.jpg'),
        config: OpenStruct.new(
          loldir: File.expand_path("#{__dir__}../../../images")
        )
      )
    end

    def plugin
      @plugin ||= Lolcommits::Plugin::Hipchat.new(runner: runner)
    end

    def endpoint
      "http://#{plugin_config[:api_team]}.hipchat.com/v2/room/#{plugin_config[:api_room]}/share/file?auth_token=#{plugin_config[:api_token]}"
    end

    def plugin_config
      {
        enabled: true,
        api_team: "lolcommits-team",
        api_token: "f0FJmP9wfP9JxNeCYrwmSR9f86jJfxgMna1r6mXy",
        api_room: "lolcommits-room"
      }
    end

    describe "#enabled?" do
      it "is disabled by default" do
        plugin.enabled?.must_equal false
      end

      it "is true when configured" do
        plugin.configuration = plugin_config
        plugin.enabled?.must_equal true
      end
    end

    describe "run_capture_ready" do
      before do
        commit_repo_with_message("first commit!")
        plugin.configuration = plugin_config
      end

      after { teardown_repo }

      it "posts lolcommit image and message to HipChat" do
        in_repo do
          stub_request(:post, endpoint).to_return(status: 204)
          output = fake_io_capture { plugin.run_capture_ready }
          output.must_equal "Posting to HipChat (lolcommits-room) ... done!\n"

          assert_requested :post, endpoint, times: 1 do |req|
            req.headers["Content-Type"].must_match(/multipart\/related; boundary=/)
            req.body.must_match(/{\"message\":\"commited some .+ to .+@.+ (.+) \"}/)
          end
        end
      end

      it "prompts user to check token when post to HipChat fails" do
        in_repo do
          stub_request(:post, endpoint).to_return(status: 401)
          output = fake_io_capture { plugin.run_capture_ready }
          output.split("\n").must_equal [
            "Posting to HipChat (lolcommits-room) ... failed!",
            "Are you sure your HipChat API token has the 'Send Message' scope?"
          ]
        end
      end
    end

    describe "configuration" do
      it "allows plugin options to be configured" do
        # enabled, token, team and room
        inputs = %w(
          true
          lolcommits-team
          my-token
          lolcommits-room
        )
        configured_plugin_options = {}

        fake_io_capture(inputs: inputs) do
          configured_plugin_options = plugin.configure_options!
        end

        configured_plugin_options.must_equal({
          enabled: true,
          api_team: "lolcommits-team",
          api_token: "my-token",
          api_room: "lolcommits-room"
        })
      end

      describe "#valid_configuration?" do
        it "returns false for an invalid configuration" do
          plugin.configuration = { api_team: "set-but-other-keys-missing" }
          plugin.valid_configuration?.must_equal false
        end

        it "returns true with a valid configuration" do
          plugin.configuration = plugin_config
          plugin.valid_configuration?.must_equal true
        end
      end
    end
  end
end
