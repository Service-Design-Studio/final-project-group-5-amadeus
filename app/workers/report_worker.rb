class ReportWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    # This method that will be called when the worker is queued.
    def perform(zip_id, upload_id)
        if zip_id != ""
            ZipUpload.unzip_file(zip_id)
        elsif upload_id != ""
            Upload.run_nltk(upload_id)
        else return true
        end
    
    end

end