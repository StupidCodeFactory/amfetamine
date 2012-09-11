module Amfetamine
  module Relationships
    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(args={})
      #super(args)
      if self.class._relationship_children
        self.class._relationship_children.each do |rel|
          resource_name = rel[:resource_name]
          class_name    = rel[:class_name]
          instance_variable_set("@#{resource_name}", Amfetamine::Relationship.new(:on_resource_name => resource_name, :on_class_name => class_name, :from => self, :type => :has_many))
        end
      end

      if self.class._relationship_parents
        self.class._relationship_parents.each do |rel|
          resource_name = rel[:resource_name]
          class_name    = rel[:class_name]
          instance_variable_set("@#{resource_name}", Amfetamine::Relationship.new(:on_resource_name => resource_name, :on_class_name => class_name, :from => self, :type => :belongs_to))
        end
      end
    end

    def belongs_to_relationship?
      self.class._relationship_parents && self.class._relationship_parents.any?
    end

    def belongs_to_relationships
      if self.class._relationship_parents
        self.class._relationship_parents.collect { |rel| self.send(rel[:class_name]) }
      else
        []
      end
    end

    module ClassMethods
      # has_many_resources :pupils, class_name: 'Child', foreign_key: 'dummy_id'
      def has_many_resources(resource_name, opts = {})
        self.class_eval do
          class_name = opts.delete(:class_name) { resource_name }
          foreign_key = opts.delete(:foreign_key) { self.name.to_s.downcase.gsub('/', '_').singularize + "_id" }

          attr_reader resource_name
          attr_reader class_name

          @_relationship_children ||= []
          @_relationship_children << { resource_name: resource_name, class_name: class_name }

          define_method("build_#{resource_name.to_s.downcase.gsub('/', '_').singularize}") do |*args|
            args = args.shift || {}
            # "my_module/my_companies" => "MyModule::MyCompany"
            Amfetamine.parent.const_get(class_name.to_s.singularize.split('/').map { |s| s.split('_').map(&:capitalize).join }.join('::')).new(args.merge(foreign_key => self.id))
          end

          define_method("create_#{resource_name.to_s.downcase.gsub('/', '_').singularize}") do |*args|
            args = args.shift || {}
            Amfetamine.parent.const_get(class_name.to_s.singularize.split('/').map { |s| s.split('_').map(&:capitalize).join }.join('::')).create(args.merge(foreign_key => self.id))
          end
        end
      end

      def _relationship_children
        @_relationship_children
      end

      def belongs_to_resource(resource_name, opts = {})
        self.class_eval do
          class_name = opts.delete(:class_name) { resource_name }

          attr_reader resource_name
          attr_reader class_name

          @_relationship_parents ||= []
          @_relationship_parents << { resource_name: resource_name, class_name: class_name }
        end
      end

      def _relationship_parents
        @_relationship_parents
      end
    end
  end
end
