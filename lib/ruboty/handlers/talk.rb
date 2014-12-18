require "docomoru"

module Ruboty
  module Handlers
    class Talk < Base
      NAMESPACE = "alias"

      env :DOCOMO_API_KEY, "Pass DoCoMo API KEY"

      on(
        /(?<body>.+)/,
        description: "Talk with you if given message didn't match any other handlers",
        missing: true,
        name: "talk",
      )

      def talk(message)
        response = client.create_dialogue(message[:body], context: @context)
        @context = response.body["context"]
        message.reply(response.body["utt"])
      rescue Exception => e
        message.reply("Error: #{e.class}: #{e.message}")
        Ruboty.logger.error("Error: #{e.class}: #{e.message}")
        e.backtrace.each do |line|
          Ruboty.logger.error(line)
        end
      end

      private

      def client
        @client ||= Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
      end
    end
  end
end
