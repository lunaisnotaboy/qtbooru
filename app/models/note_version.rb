class NoteVersion < ApplicationRecord
  belongs_to_updater :counter_cache => "note_update_count"

  def self.search(params)
    q = super

    if params[:post_id]
      q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
    end

    if params[:note_id]
      q = q.where(note_id: params[:note_id].split(",").map(&:to_i))
    end

    q = q.attribute_matches(:is_active, params[:is_active])
    q = q.attribute_matches(:body, params[:body_matches])
    q = q.search_user_attribute(:updater, params)

    q.apply_default_order(params)
  end

  def previous
    NoteVersion.where("note_id = ? and updated_at < ?", note_id, updated_at).order("updated_at desc").first
  end
end
