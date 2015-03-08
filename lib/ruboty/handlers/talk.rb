require "docomoru"

module Ruboty
  module Handlers
    class Talk < Base
      NAMESPACE = "alias"

      env :DOCOMO_API_KEY, "Pass DoCoMo API KEY"
      env :DOCOMO_CHARACTER_ID, "Character ID to be passed as t parameter", optional: true

      on(
        /(?<body>.+)/,
        description: "Talk with you if given message didn't match any other handlers",
        missing: true,
        name: "talk",
      )

      def talk(message)
        response = client.create_dialogue(message[:body], params)
        @context = response.body["context"]
        message.reply(response.body["utt"])
      rescue Exception => e
        Ruboty.logger.error(%<Error: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}>)
      end

      private

      def character_id
        if ENV["DOCOMO_CHARACTER_ID"]
          ENV["DOCOMO_CHARACTER_ID"].to_i
        end
      end

      def client
        @client ||= Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
      end

      def params
        {
          context: @context,
          t: character_id,
        }.reject do |key, value|
          value.nil?
        end
      end
    end
  end
end
