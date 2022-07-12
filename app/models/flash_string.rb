module FlashString
  TO_LOGIN = "You must be logged in to access this section"

  class UploadString
    INVALID_TOPIC = "Invalid topic input!"
    ADD_FAIL = "Update failed!"
    UPLOAD_DELETED = "Upload deleted!"

    def self.get_duplicate_upload(upload)
      "Current article already includes %{upload}!" % {upload: upload}
    end

    def self.get_added_topic(topic)
      "%{topic} successfully updated!" % {topic: topic}
    end
  end

  class UploadLinkString
    DELETED_TOPIC = "Successfully deleted!"
  end

  class TopicString
    def self.get_added_topic(topic)
      "%{topic} added." % {topic:topic}
    end

    def self.get_updated_tag(old_tag, new_tag)
      "%{old} updated into %{new}." % {old: old_tag, new: new_tag}
    end

    def self.get_deleted_topic(topic)
      "Deleted %{topic}." % {topic: topic}
    end
  end

end