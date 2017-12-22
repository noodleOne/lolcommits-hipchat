require 'mime/types'
require 'lolcommits/plugin/base'

module Lolcommits
  module Plugin
    class Hipchat < Base

      ##
      # Returns the name of this plugin.
      #
      # @return [String] the plugin name
      #
      def self.name
        'hipchat'
      end

      ##
      # Returns position(s) of when this plugin should run during the capture
      # process. A new message is posted to HipChat when the capture is ready.
      #
      # @return [Array] the position(s) (:capture_ready)
      #
      def self.runner_order
        [:capture_ready]
      end

      ##
      # Returns true if the plugin has been configured. An API token, team name
      # and HipChat room id (or name) are required.
      #
      # @return [Boolean] true/false indicating if plugin is configured
      #
      def configured?
        super &&
          !!(configuration['api_token'] &&
             configuration['api_team'] &&
             configuration['api_room'])
      end

      ##
      # Returns true/false indicating if the plugin has been correctly
      # configured. To post a message to HipChat all plugin options must be
      # set.
      #
      # @return [Boolean] true/false indicating if plugin is correctly
      # configured
      #
      def valid_configuration?
        %w(api_token api_team api_room).all? do |option|
          !configuration[option].to_s.strip.empty?
        end
      end

      ##
      # Prompts the user to configure plugin options.
      # Options are enabled (true/false), HipChat API token, team name and room
      # id (or name)
      #
      # @return [Hash] a hash of the configured plugin options
      #
      def configure_options!
        options = super
        options.merge!(configure_auth_options) if options['enabled']
        options
      end

      ##
      # Post-capture hook, runs after lolcommits captures a snapshot. Shares the
      # lolcommit to the configured HipChat room via their API (v2) using
      # Net::HTTP (POST) with a message and image attachment. See the HipChat
      # API documentation for more information:
      #
      # https://www.hipchat.com/docs/apiv2/method/share_file_with_room
      #
      # @return [Boolean] indicating if HipChat post was successful
      #
      def run_capture_ready
        print "Posting to HipChat (#{configuration['api_room']}) ..."
        debug "Posting to HipChat: HTTP POST to #{api_url}"

        boundary = "0123456789ABLEWASIEREISAWELBA9876543210"
        http     = Net::HTTP.new(api_url.host)
        header   = { 'Content-Type' => "multipart/related; boundary=#{boundary}" }
        data     = [message_part, picture_part].map do |part|
          "--#{boundary}\r\n#{part}"
        end.join << "--#{boundary}--"

        response = http.post("#{api_url.path}?#{api_url.query}", data, header)

        if response.code == "204"
          print " done!\n"
          return true
        else
          debug "Posting to HipChat failed with response code #{response.code}"
          print " failed!\n"
        end

        if response.code ==  "401"
          puts "Are you sure your HipChat API token has the 'Send Message' scope?"
        end

        false
      end


      private

      def configure_auth_options
        puts "\n"
        puts '-' * 50
        puts ' Lolcommits HipChat Plugin Configuration'
        puts '-' * 50

        puts "\n1. What is your Team Name (e.g. teamname.hipchat.com)"
        print "> "
        teamname = parse_user_input(gets.strip)
        puts "\n2. We need a HipChat token (visit https://#{teamname}.hipchat.com/account/api)"
        puts "(ensure the scope 'Send Message' is selected)"
        print "> "
        token = parse_user_input(gets.strip)
        puts "\n3. Which Room should be we post to? (an id or name)"
        print "> "
        room = parse_user_input(gets.strip)

        {
          'api_team'  => teamname,
          'api_token' => token,
          'api_room'  => room
        }
      end

      def message_part
        [
          'Content-Type: application/json; charset=UTF-8',
          'Content-Disposition: attachment; name="metadata"',
          '',
          message_json,
          ''
        ].join "\r\n"
      end

      def message_json
        { message: message }.to_json.force_encoding('utf-8')
      end

      def picture_part
        picture   = File.new(runner.main_image)
        mime_type = MIME::Types.type_for(picture.path)[0] || MIME::Types['application/octet-stream'][0]
        [
          format('Content-Type: %s', mime_type.simplified),
          format('Content-Disposition: attachment; name="file"; filename="%s"', picture.path),
          '',
          "#{picture.read} ",
          ''
        ].join "\r\n"
      end

      def api_url
        URI("http://#{configuration['api_team']}.hipchat.com/v2/room/#{configuration['api_room']}/share/file?auth_token=#{configuration['api_token']}")
      end

      def message
        "commited some #{random_adjective} #{random_object} to #{runner.vcs_info.repo}@#{runner.sha} (#{runner.vcs_info.branch}) "
      end

      def random_object
        %w(screws bolts exceptions errors cookies).sample
      end

      def random_adjective
        adjectives = %w(adaptable adventurous affable affectionate agreeable ambitious amiable amicable amusing brave \
                        bright broad-minded calm careful charming communicative compassionate conscientious considerate \
                        convivial courageous courteous creative decisive determined diligent diplomatic discreet dynamic \
                        easygoing emotional energetic enthusiastic exuberant fair-minded faithful fearless forceful \
                        frank friendly funny generous gentle good gregarious hard-working helpful honest humorous \
                        imaginative impartial independent intellectual intelligent intuitive inventive kind loving loyal \
                        modest neat nice optimistic passionate patient persistent pioneering philosophical placid plucky \
                        polite powerful practical pro-active quick-witted quiet rational reliable reserved resourceful \
                        romantic self-confident self-disciplined sensible sensitive shy sincere sociable straightforward \
                        sympathetic thoughtful tidy tough unassuming understanding versatile warmhearted willing witty)
        adjectives.sample
      end
    end
  end
end
