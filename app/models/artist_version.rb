class ArtistVersion < ApplicationRecord
  array_attribute :urls
  array_attribute :other_names

  belongs_to_updater
  belongs_to :artist
  delegate :visible?, :to => :artist

  module SearchMethods
    def search(params)
      q = super

      if params[:name].present?
        q = q.where("name like ? escape E'\\\\'", params[:name].to_escaped_for_sql_like)
      end

      q = q.search_user_attribute(:updater, params)

      if params[:artist_id].present?
        q = q.where(artist_id: params[:artist_id].split(",").map(&:to_i))
      end

      q = q.attribute_matches(:is_active, params[:is_active])
      q = q.attribute_matches(:is_banned, params[:is_banned])

      params[:order] ||= params.delete(:sort)
      if params[:order] == "name"
        q = q.order("artist_versions.name").default_order
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def previous
    ArtistVersion.where("artist_id = ? and created_at < ?", artist_id, created_at).order("created_at desc").first
  end
end
