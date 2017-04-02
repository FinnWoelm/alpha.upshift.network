# Allows for setting of anchor on ActiveRecord collections for use with
# InfinityScroll/WillPaginate

module InfinityScroll

  extend ActiveSupport::Concern

  attr_accessor :anchor


  class_methods do

    # paginate records with a given anchor. This is useful for models that might
    # increase in number over the course of pagination (such as private
    # messages). The anchor ensures that pagination will always be consistent
    # because the pagination anchor stays consistent.
    def paginate_with_anchor options
      rel                 = all
      rel.anchor          = options.delete(:anchor)
      anchor_column       = options.delete(:anchor_column)
      anchor_orientation  = options.delete(:anchor_orientation)

      # apply anchor query
      rel = rel.where("#{rel.model.table_name}.#{anchor_column} #{anchor_orientation == :greater_than ? '>=' : '<='} ?", rel.anchor) if rel.anchor

      # if anchor is not set, let's set it manually
      if rel.anchor.nil?

        # if we're loading page 1, then we can just set anchor to the respective attribute on
        # the first record
        if options[:page] == 1 or options[:page].nil?
          rel.anchor = rel.paginate(options)[0].try(anchor_column)

        # if not, we have to make an extra DB query for the first item
        else
          rel.anchor = rel.first.try(anchor_column)
        end
      end

      # apply pagination
      rel.paginate(options)
    end
  end

end

# include the extension
klasses = [::ActiveRecord::Relation, ::ActiveRecord::Base]

if defined? ::ActiveRecord::Associations::CollectionProxy
  klasses << ::ActiveRecord::Associations::CollectionProxy
else
  klasses << ::ActiveRecord::Associations::AssociationCollection
end

klasses.each { |klass| klass.send(:include, InfinityScroll) }
