# encoding: UTF-8

module Decider
  module Clustering
    
    class Tree
      
      def initialize
        @root_node = Node.new(:root, [0])
      end
      
      def root
        @root_node
      end
      
      def insert(name, vector)
        @root_node.attach(Node.new(name, vector))
      end
      
    end
    
    class Node
      include Vectorize
      
      attr_accessor :parent, :children, :vector, :foreign_id, :name
      
      N = 2
      
      def initialize(name, vector)
        @name, @children, @vector = name.to_s, [], vector
      end
      
      def attach(node)
        if children.size >= N
          @children << create_subnode(node)
        else
          node.parent = self
          @children << node
        end
        self
      end
      
      def create_subnode(node)
        closest_child = @children.delete_at(index_of_child_closest_to(node))
        avg_vector = avg_binary_vectors(closest_child.vector, node.vector)
        subnode = self.class.new(subnode_name(closest_child, node), avg_vector)
        subnode.attach(closest_child).attach(node)
      end
      
      def index_of_child_closest_to(node)
        index_of_closest_node, best_distance_measure = 0, 0.0
        @children.size.times do |i|
          distance_measure = tanimoto_coefficient(@children[i].vector, node.vector)
          if distance_measure > best_distance_measure
            best_distance_measure = distance_measure
            index_of_closest_node = i
          end
        end
        index_of_closest_node
      end
      
      def <<(node)
        @children << node
      end
      
      def leaf?
        @children.empty?
      end
      
      def print_tree(depth=0, opts={})
        if depth == 0
          puts "(root)"
        else
          tree_vis = ""
          (depth - 1).times { |i| tree_vis << "|  " }
          tree_vis << ("|--" + name)
          tree_vis = (tree_vis +  " ").ljust(60) + vector.inspect if opts[:include_vectors]
          puts tree_vis
        end
        unless leaf?
          children.each { |c| c.print_tree(depth + 1, opts) }
        end
      end
      
      private
      
      def subnode_name(node1, node2)
        node1.name.split("::").first + "::" + node2.name.split("::").last
      end
      
    end
  end
end