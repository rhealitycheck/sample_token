require 'elasticsearch/model'

class Task < ActiveRecord::Base
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
            indexes :title, analyzer: 'english', index_options: 'offsets'
            indexes :text, analyzer: 'english'
        end
    end

    def self.search(query)
        __elasticsearch__.search(
            {
                query: {
                    multi_match: {
                        query: query,
                        fields: ['title^10', 'text']
                    }
                }
            },
            highlight: {
                pre_tags: ['<em>'],
                post_tags: ['</em>'],
                fields: {
                    title: {},
                    text: {}
                }
            }
        )
    end
end

# Delete the previous task index in elasticsearch
Task.__elasticsearch__.client.indices.delete index: Task.index_name rescue nil

# Create the new index with the new mapping
Task.__elasticsearch__.client.indices.create \
    index: Task.index_name,
    body: { settings: Task.settings.to_hash, mappings: Task.mappings.to_hash }

# Index all task records from db to elasticsearch
Task.import # for auto sync model w/ elasticsearch
