class Task < ApplicationRecord
  generates_token_for :update_task, expires_in: 5.seconds
end
