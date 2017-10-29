require "test_helper"
require 'webmock/minitest'

describe Lolcommits::Plugin::HipChat do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  def plugin_name
    "hipchat"
  end

  it "should have a name" do
    ::Lolcommits::Plugin::HipChat.name.must_equal plugin_name
  end

  it "should run on capture ready" do
    ::Lolcommits::Plugin::HipChat.runner_order.must_equal [:capture_ready]
  end

  describe "with a runner" do
    def runner
      # a simple lolcommits runner with an empty configuration Hash
      @runner ||= Lolcommits::Runner.new(
        main_image: Tempfile.new('main_image.jpg'),
        config: OpenStruct.new(
          read_configuration: {},
          loldir: File.expand_path("#{__dir__}../../../images")
        )
      )
    end

    def plugin
      @plugin ||= Lolcommits::Plugin::HipChat.new(runner: runner)
    end

    def endpoint
      config = plugin.config.read_configuration['hipchat']
      "http://#{config['api_team']}.hipchat.com/v2/room/#{config['api_room']}/share/file?auth_token=#{config['api_token']}"
    end

    def valid_enabled_config
      @config ||= OpenStruct.new(
        read_configuration: {
          "hipchat" => {
            "enabled"   => true,
            "api_team"  => "lolcommits-team",
            "api_token" => "f0FJmP9wfP9JxNeCYrwmSR9f86jJfxgMna1r6mXy",
            "api_room"  => "lolcommits-room"
          }
        }
      )
    end

    describe "#enabled?" do
      it "is false by default" do
        plugin.enabled?.must_equal false
      end

      it "is true when configured" do
        plugin.config = valid_enabled_config
        plugin.enabled?.must_equal true
      end
    end

    describe "run_capture_ready" do
      before do
        commit_repo_with_message("first commit!")
        plugin.config = valid_enabled_config
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
      it "returns false when not configured" do
        plugin.configured?.must_equal false
      end

      it "returns true when configured" do
        plugin.config = valid_enabled_config
        plugin.configured?.must_equal true
      end

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
          "enabled"   => true,
          "api_team"  => "lolcommits-team",
          "api_token" => "my-token",
          "api_room"  => "lolcommits-room"
        })
      end

      describe "#valid_configuration?" do
        it "returns false for an invalid configuration" do
          plugin.config = OpenStruct.new(read_configuration: {
            "hipchat" => { "api_team" => "set-but-other-keys-missing" }
          })
          plugin.valid_configuration?.must_equal false
        end

        it "returns true with a valid configuration" do
          plugin.config = valid_enabled_config
          plugin.valid_configuration?.must_equal true
        end
      end
    end
  end
end
