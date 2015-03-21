module Middleman
  module Swiftype
    module Generator
      def self.generate_swiftype_records(shared_instance, options)
        records = []
        m_pages = shared_instance.sitemap.resources.find_all{|p| options.pages_selector.call(p) }

        m_pages.each do |p|
          external_id = Digest::MD5.hexdigest(p.url)

          # optional selector for retrieving the page title
          if options.title_selector
            title = options.title_selector.call(shared_instance, p)
          else
            title = p.metadata[:page]['title']
          end

          url = p.url
          sections = []
          body = ''
          info = ''
          image = ''

          f = Nokogiri::HTML.fragment(p.render(:layout => false))

          # optionally edit html
          if options.process_html
            options.process_html.call(f)
          end
          body = f.text

          if options.generate_sections
            sections = options.generate_sections.call(p)
          end

          # optionally generate extra info
          if options.generate_info
            info = options.generate_info.call(f)
          end

          # optional image
          if options.generate_image
            image = options.generate_image.call(p)
          end

          if options.should_index
            should_index = options.should_index.call(p, title)
            next unless should_index
          end

          fields = [
            {:name => 'title', :value => title, :type => 'string'},
            {:name => 'url', :value => url, :type => 'enum'},
            {:name => 'body', :value => body, :type => 'string'},
            {:name => 'info', :value => info, :type => 'string'}
          ]

          if sections.length > 0
            {:name => 'sections', :value => sections, :type => 'string'}
          end

          if image
            fields << {:name => 'image', :value => image, :type => 'enum'}
          end

          records << {
            :external_id => external_id,
            :fields => fields
          }
        end

        records
      end
    end
  end
end
