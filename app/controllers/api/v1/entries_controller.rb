class Api::V1::EntriesController < Api::ApiController
  def index
    filter = params['filter'] || 'default'
    @entries = Entry.filter(@visitor, filter)
    respond_with @entries
  end
end
