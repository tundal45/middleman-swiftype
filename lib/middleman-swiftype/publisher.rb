module Middleman
  module Swiftype
    module Generator
      SWIFTYPE_DOCUMENT_TYPE = "page"

      def self.push_to_swiftype(records, shared_instance, options)
        # https://github.com/swiftype/swiftype-rb
        ::Swiftype.configure do |config|
          config.api_key = options.api_key
        end

        swiftype_client = ::Swiftype::Client.new

        records.each do |record|
          # https://swiftype.com/documentation/crawler#schema
          # https://swiftype.com/documentation/meta_tags
          url_field = record[:fields].find { |fields| fields[:name] == "url" }
          shared_instance.logger.info("Pushing contents of #{url_field[:value]} to swiftype")

          begin
            swiftype_client.create_or_update_document(options.engine_slug, SWIFTYPE_DOCUMENT_TYPE, {
                :external_id => record[:external_id],
                :fields => record[:fields]
            })
          rescue ::Swiftype::NonExistentRecord
            swiftype_client.create_document_type(options.engine_slug, SWIFTYPE_DOCUMENT_TYPE)
            swiftype_client.create_or_update_document(options.engine_slug, SWIFTYPE_DOCUMENT_TYPE, {
                :external_id => record[:external_id],
                :fields => record[:fields]
            })
          end
        end
      end
    end
  end
end
