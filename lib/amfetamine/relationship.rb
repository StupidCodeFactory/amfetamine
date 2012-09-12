module Amfetamine
  class Relationship
    include Enumerable

    attr_reader :on_resource_name, :on_class_name, :type, :from

    def initialize(opts)
      @type             = opts[:type]
      @on_resource_name = opts[:on_resource_name]                          # Target resource name
      @on_class_name    = opts.fetch(:on_class_name) { @on_resource_name } # Target class name
      @from             = opts[:from]                                      # Receiving object
      @foreign_key      = opts.fetch(:foreign_key) { build_foreign_key }   # Foreign key
    end

    def << (other)
      other.send("#{@foreign_key}=", @from.id)
      other.instance_variable_set("@#{from_singular_name}", Amfetamine::Relationship.new(on_resource_name: @from, on_class_name: @from, foreign_key: @foreign_key, from: other, type: :belongs_to))
      @children ||= [] # No need to do a request here, but it needs to be an array if it isn't yet.
      @children << other
    end

    def on_class
      if @on_class_name.is_a?(Symbol) or @on_class_name.is_a?(String)
        Amfetamine.parent.const_get(@on_class_name.to_s.singularize.split('/').map { |s| s.split('_').map(&:capitalize).join }.join('::'))
      else
        @on_class_name.class
      end
    end

    # Id of object this relationship references
    def parent_id
      if @on_class_name.is_a?(Symbol) or @on_class_name.is_a?(String)
        @from.send(@foreign_key) if @type == :belongs_to
      else
        @on_class_name.id
      end
    end

    # Id of the receiving object
    def from_id
      @from.id
    end

    def from_plural_name
      @from.class.name.to_s.downcase.pluralize
    end

    def from_singular_name
      @from.class.name.to_s.downcase
    end

    def on_plural_name
      if @on_resource_name.is_a?(Symbol) or @on_resource_name.is_a?(String)
        @on_resource_name.to_s.pluralize
      else
        @on_resource_name.class.name.to_s.pluralize.downcase
      end
    end

    def rest_path
      on_class.rest_path(:relationship => self)
    end

    def find_path(id)
      on_class.find_path(id, :relationship => self)
    end

    def singular_path
      find_path(@from.id)
    end

    def full_path
      if @type == :has_many
        raise InvalidPath if from_id == nil
        "#{from_plural_name}/#{from_id}/#{on_plural_name}"
      elsif @type == :belongs_to
        raise InvalidPath if parent_id == nil
        "#{on_plural_name}/#{parent_id}/#{from_plural_name}"
      end
    end

    def each
      all.each { |c| yield c }
    end

    # Delegates the all method to child class with a nested path set
    def all(opts={})
      on_class.all({ :nested_path => rest_path }.merge(opts))
    end

    # Delegates the find method to child class with a nested path set
    def find(id, opts={})
      on_class.find(id, {:nested_path => find_path(id)}.merge(opts))
    end

    def include?(other)
      self.all
      @children.include?(other)
    end

    private

    def build_foreign_key
      if @type == :has_many
        "#{from_singular_name}_id"
      elsif @type == :belongs_to
        @on_class_name.to_s.downcase.gsub('/', '_') + "_id"
      end
    end
  end
end
