# encoding: UTF-8

require 'yaml'
require 'rosette/serializers/serializer'
require 'rosette/serializers/yaml/trie'
require 'yaml-write-stream'

module Rosette
  module Serializers

    class YamlSerializer < Serializer
      attr_reader :writer, :encoding

      def initialize(stream, encoding = Encoding::UTF_8)
        @encoding = encoding
        @writer = YamlWriteStream.from_stream(stream, encoding)
        super(stream)
      end

      def close
        raise NotImplementedError, 'please use a derived class.'
      end

      class RailsSerializer < YamlSerializer
        attr_reader :trie

        def initialize(stream, encoding)
          super(stream, encoding)
          @trie = Trie.new
        end

        def write_translation(trans)
          meta_key_parts = trans.phrase.meta_key.split('.')
          translation = trans.translation.encode(encoding)
          trie.add(meta_key_parts, translation)
        end

        def close
          write_node(trie.root, nil)
          writer.close
        end

        protected

        # depth-first
        def write_node(node, parent_key)
          if node.has_children?
            if children_are_array(node)
              write_array(node, parent_key)
            else
              write_hash(node, parent_key)
            end
          elsif node.has_value?
            write_value(node, parent_key)
          end
        end

        def write_value(node, parent_key)
          if writer.in_hash?
            writer.write_key_value(parent_key, node.value)
          else
            writer.write_element(node.value)
          end
        end

        def write_hash(node, parent_key)
          if writer.in_hash?
            writer.write_hash(parent_key)
          else
            writer.write_hash
          end

          node.each_child do |key, child|
            write_node(child, key)
          end

          writer.close_hash
        end

        def write_array(node, parent_key)
          if writer.in_hash?
            writer.write_array(parent_key)
          else
            writer.write_array
          end

          generate_array(node).each do |element|
            write_node(element, nil)
          end

          writer.close_array
        end

        def children_are_array(node)
          node.children.all? { |key, _| key =~ /[\d]+/ }
        end

        def generate_array(node)
          keys = node.children.keys.map(&:to_i)
          keys.each_with_object(Array.new(keys.max)) do |idx, arr|
            arr[idx] = node.children[idx.to_s]
          end
        end

      end
    end

  end
end
