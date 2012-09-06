module Amfetamine
  module Relationships
    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(args={})
      #super(args)
      if self.class._relationship_children
        self.class._relationship_children.each do |klass|
          instance_variable_set("@#{klass}", Amfetamine::Relationship.new(:on => klass, :from => self, :type => :has_many))
        end
      end

      if self.class._relationship_parents
        self.class._relationship_parents.each do |klass|
          instance_variable_set("@#{klass}", Amfetamine::Relationship.new(:on => klass, :from => self, :type => :belongs_to))
        end
      end
    end

    def belongs_to_relationship?
      self.class._relationship_parents && self.class._relationship_parents.any?
    end

    def belongs_to_relationships
      if self.class._relationship_parents
        self.class._relationship_parents.collect { |e| self.send(e) }
      else
        []
      end
    end

    module ClassMethods
      def has_many_resources(name)
        self.class_eval do
          attr_reader name

          @_relationship_children ||= []
          @_relationship_children << name

          parent_id_field = self.name.to_s.downcase.singularize + "_id"

          define_method("build_#{name.to_s.singularize}") do |*args|
            args = args.shift || {}
            Amfetamine.parent.const_get(name.to_s.gsub('/', '::').singularize.gsub('_','').capitalize).new(args.merge(parent_id_field => self.id))
          end

          define_method("create_#{name.to_s.singularize}") do |*args|
            args = args.shift || {}
            Amfetamine.parent.const_get(name.to_s.gsub('/', '::').singularize.gsub('_','').capitalize).create(args.merge(parent_id_field => self.id))
          end
        end
      end

      def _relationship_children
        @_relationship_children
      end

      def belongs_to_resource(name)
        self.class_eval do
          attr_reader name

          @_relationship_parents ||= []
          @_relationship_parents << name
        end
      end

      def _relationship_parents
        @_relationship_parents
      end
    end
  end
end
