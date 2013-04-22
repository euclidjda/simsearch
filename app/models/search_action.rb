# Roles to be used for authorization during various stages. 
module SearchActionTypes
  Create = 1
  Share = 2
  Favorite = 3
end

class SearchAction < ActiveRecord::Base
  # user, search and action are references.
  # If the same action is taken more than once, the timestamps contain
  # the last update time. (created_at, updated_at)

  # Action => SearchActionTypes::Create/Share/Favorite

  attr_accessible :user_id, :search_id, :action_id
  attr_accessor :ticker, :name

  def self.find_or_create(attributes)
    SearchAction.where(attributes).first || SearchAction.create(attributes)
  end

  def self.actions_for_user(_user_id)

    obj_array = Array.new

    sqlstr = SearchAction::get_search_actions_sql(_user_id)

    result = SearchAction.connection.select_all(sqlstr) 

    if result.size > 0

      result.each do |record|
        obj = SearchAction::new( 
            :user_id => record['user_id'],
            :search_id => record['search_id'],
            :action_id => record['action_id'],
            )
        obj.created_at = record['created_at']
        obj.updated_at = record['updated_at']
        obj.ticker = record['ticker']
        obj.name = record['name']

        obj_array.push(obj)

      end

    end

    obj_array

  end

private
  def self.get_search_actions_sql(_user_id)
<<GET_SEARCH_ACTIONS_SQL
  SELECT e.ticker, e.name, sa.*
  FROM search_actions sa, users u,searches s, ex_securities e 
  where sa.user_id = u.id and sa.search_id=s.id and 
  e.cid = s.cid and e.sid = s.sid and
  u.id = '#{_user_id}' order by sa.created_at desc;
GET_SEARCH_ACTIONS_SQL

  end

end
