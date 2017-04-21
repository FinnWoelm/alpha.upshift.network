class Notification::Action < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: false
  belongs_to :notification, optional: false

  default_scope { order(created_at: :desc) }

  # # Callback
  after_save :limit_actions_to_3
  before_create do
    Notification::Action.where(:notification => notification, :actor => actor).delete_all
  end

  private

    # limits the number of actors to 3
    def limit_actions_to_3
      if Notification::Action.where(:notification => self.notification).count > 3

        first_record_over_limit = Notification::Action.select(:id, :created_at).
          where(:notification => self.notification).
          offset(3).first

        # delete any actions done before the 3 that we are keeping
        Notification::Action.
          where(:notification => self.notification).
          where('created_at <= ?', first_record_over_limit.created_at).
          delete_all

        # set :others_acted_before on notification
        self.notification.update(
          :others_acted_before => first_record_over_limit.created_at
        )
      end
    end
end
