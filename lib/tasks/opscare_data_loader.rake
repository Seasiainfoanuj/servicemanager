require "yaml"

namespace :opscare do
  namespace :db do
    namespace :data do

      class DBLoader
        attr_accessor :path, :verbose
        attr_accessor :data_dir, :loaded_tables

        def initialize(path="data", verbose=true)
          @path = path
          @verbose = verbose
          @data_dir = Rails.root.join("db", path)
          @loaded_tables = []
        end

        def execute
          import
        end

        # -----
        private
        # -----
          def import
            dir_entries.each do |filename|
              import_table filename
            end
          end

          def dir_entries
            Dir.entries(data_dir).reject { |e| invalid_item? e }
          end

          def invalid_item?(entry)
            File.basename(entry) =~ /^\./
          end

          def import_table(filename)
            preload_ref_tables(filename)
            load_table(filename)
          end

          def preload_ref_tables(filename)
            reference_tables(filename).each do |file|
              import_table(file)
            end
          end

          def load_table(filename)
            filespec = File.join(data_dir, filename)
            unless loaded_tables.include?(filename)
              if File.exist?(filespec)
                puts "Loading #{filename}" if verbose
                YamlDb::SerializationHelper::Base.new('YamlDb::Helper'.constantize).load(filespec, false)
              end
              loaded_tables << filename
            end
          end

          def reference_tables(filename)
            ext = File.extname(filename)
            table_name = filename.sub(/#{ext}/, "")
            begin
              model = table_name.classify.constantize
              assoc = model.reflect_on_all_associations(:belongs_to)
              result = assoc.map { |a| a.name.to_s.pluralize + ext }
            rescue
              result = []
            end
            result
          end
      end

      class DBSchema
        attr_accessor :schema_file, :verbose
        attr_accessor :schema

        def initialize(schema_file, verbose=true)
          @schema_file = schema_file
          @verbose = verbose
          read_schema
        end

        def prepare
          postgresql
          write_schema
        end

        #------
        private
        #------
          def read_schema
            @schema = File.open(schema_file, "rb").read
          end

          def write_schema
            File.open(schema_file, "w") { |f| f.write(schema) }
          end

          def postgresql
            if verbose
              puts "schema.rb -> Postgres:"
              puts "  a. remove 'create_table' block [:options]"
              puts "  b. remove data_type attribute [:limit]"
            end
            # Remove table options: attribute
            schema.gsub! /,\s*options:\s".*"/, ""
            # Remove text field limit: attribute
            schema.gsub! /,\s*limit:\s\d*/, ""
          end
      end

      desc "loads yaml data files from folder db/data/*.yml"
      task :load_dir, [:folder, :verbose] => :environment do |t,args|

        schema_file = Rails.root.join("db", "schema.rb")
        if File.exist?(schema_file)
          folder = args.folder || "data"
          verbose = args.verbose || true
          data_dir = Rails.root.join("db", folder)

          DBSchema.new(schema_file, verbose).prepare

          Rake::Task['db:drop'].invoke
          Rake::Task['db:create'].invoke
          Rake::Task['db:schema:load'].invoke

          DBLoader.new(data_dir, verbose).execute
        else
          puts "db/schema.rb file NOT FOUND!!"
        end
      end
    end
  end
end
