module Deliver
  # For all the information reading (e.g. version number)
  class ItunesConnect < FastlaneCore::ItunesConnect
    # This method will fetch the current status ({Deliver::App::AppStatus})
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_status(app)
      begin
        verify_app(app)

        open_app_page(app)

        if page.has_content?WAITING_FOR_REVIEW
          # That's either Upload Received or Waiting for Review
          if page.has_content?"To submit a new build, you must remove this version from review"
            return Deliver::App::AppStatus::WAITING_FOR_REVIEW
          else
            return Deliver::App::AppStatus::UPLOAD_RECEIVED
          end
        elsif page.has_content?BUTTON_STRING_NEW_VERSION
          return Deliver::App::AppStatus::READY_FOR_SALE
        elsif page.has_content?BUTTON_STRING_SUBMIT_FOR_REVIEW
          return Deliver::App::AppStatus::PREPARE_FOR_SUBMISSION
        else
          raise "App status not yet implemented"
        end
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This method will fetch the version number of the currently live version
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_live_version(app)
      begin
        verify_app(app)

        return (get_app_information(app)['version']['value'] rescue nil)
      rescue => ex
        error_occured(ex)
      end
    end
  end
end