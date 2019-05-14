module Helpers

    # Store the picture locally and return the file name.
    #
    # @param pic [Object] The file Object of which to store locally here.
    def self.store_pic(pic)
        if pic.nil?
            return nil
        else
            file_name = SecureRandom.uuid
            FileUtils.copy(pic['tempfile'], "./public/img/#{file_name}")
            return file_name
        end
    end
end