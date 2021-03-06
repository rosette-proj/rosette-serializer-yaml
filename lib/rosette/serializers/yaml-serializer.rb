# encoding: UTF-8

require 'yaml'
require 'rosette/serializers/serializer'
require 'rosette/serializers/yaml/trie'
require 'yaml-write-stream'

module Rosette
  module Serializers

    class YamlSerializer < Serializer
      attr_reader :writer

      def initialize(stream, locale, encoding = Encoding::UTF_8)
        super
        @writer = YamlWriteStream.from_stream(stream, encoding)
      end

      def self.default_extension
        '.yml'
      end

      class RailsSerializer < YamlSerializer
        attr_reader :trie

        def initialize(stream, locale, encoding = Encoding::UTF_8)
          super
          @trie = Trie.new
        end

        def write_raw(text)
          writer.stream.write(text)
        end

        def write_key_value(key, value)
          key_parts = split_key(key)
          encoded_value = value.encode(encoding)
          trie.add(key_parts, encoded_value)
        end

        def flush
          writer.write_map(locale.language)
          write_node(trie.root, locale.language)
          writer.flush
          stream.flush
        end

        protected

        def split_key(key)
          # Doesn't allow dots to come before spaces or at the end of the key.
          # Uses regex negative lookahead, that's what the (?!) sections are.
          # Examples:
          # 'timezones.Solomon Is.'     => ['timezones', 'Solomon Is.']
          # 'timezones.Solomon Is.foo'  => ['timezones', 'Solomon Is', 'foo']
          # 'timezones.Solomon Is..foo' => ['timezones', 'Solomon Is.', 'foo']
          key.split(/\.(?!\s)(?!\z)(?!\.)/)
        end

        # depth-first
        def write_node(node, parent_key)
          if node
            if node.has_children?
              if children_are_sequence(node)
                write_sequence(node, parent_key)
              else
                write_map(node, parent_key)
              end
            elsif node.has_value?
              write_value(node, parent_key)
            end
          else
            write_value(node, parent_key)
          end
        end

        def write_value(node, parent_key)
          value = node ? node.value : ''
          if writer.in_map?
            writer.write_key_value(parent_key, value)
          else
            writer.write_element(value)
          end
        end

        def write_map(node, parent_key)
          if writer.in_map?
            writer.write_map(parent_key)
          else
            writer.write_map
          end

          node.each_child do |key, child|
            write_node(child, key)
          end

          writer.close_map
        end

        def write_sequence(node, parent_key)
          if writer.in_map?
            writer.write_sequence(parent_key)
          else
            writer.write_sequence
          end

          generate_sequence(node).each do |element|
            write_node(element, nil)
          end

          writer.close_sequence
        end

        def children_are_sequence(node)
          node.children.all? { |key, _| key =~ /\A[\d]+\z/ }
        end

        def generate_sequence(node)
          keys = node.children.keys.map(&:to_i)
          keys.each_with_object(Array.new(keys.max)) do |idx, arr|
            arr[idx] = node.children[idx.to_s]
          end
        end

      end
    end

  end
end
