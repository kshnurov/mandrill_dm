require "mail"

# extend Mail::Message to store mandrill response
class Mail::Message
  def store_mandrill_response(result)
    @mandrill_response = result
  end

  def mandrill_response
    @mandrill_response
  end
end
