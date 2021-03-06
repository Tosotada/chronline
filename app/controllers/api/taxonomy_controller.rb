require 'will_paginate/array'

class Api::TaxonomyController < Api::BaseController
  def index
    nodes = Taxonomy.nodes(include_archived: true).paginate(
      page: params[:page],
      per_page: params[:limit]
    )
    render json: nodes
  end
end
