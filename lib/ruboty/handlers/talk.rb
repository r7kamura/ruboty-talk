require "docomoru"

module Ruboty
  module Handlers
    class Talk < Base
      NAMESPACE = "alias"
      CHARACTER_IDS = [20, 30]

      env :DOCOMO_API_KEY, "Pass DoCoMo API KEY"
      env :RUBOTY_TALK_CHARACTER, "Character ID: #{CHARACTER_IDS.join(" or ")} (default: nil)", optional: true

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

      def client
        @client ||= Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
      end

      def params
        param_methods = private_methods.select { |meth| meth.to_s =~ /_param$/ }
        param_methods.inject({}) { |params, meth| params.merge(send(meth)) }
      end

      def character_param
        CHARACTER_IDS.include?(character_id) ? {t: character_id} : {}
      end

      def context_param
        {context: @context}
      end

      def character_id
        ENV["RUBOTY_TALK_CHARACTER"] && ENV["RUBOTY_TALK_CHARACTER"].to_i
      end
    end
  end
end
