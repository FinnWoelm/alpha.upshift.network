class Democracy::Community::Decision::Comment < Comment

  default_scope -> { reorder('comments.created_at DESC') }

end
