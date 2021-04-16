class Commontator::SubscriptionsMailer < Commontator.parent_mailer.constantize
  helper Commontator::SharedHelper

  def comment_created(comment, recipients)
    setup_variables(comment, recipients)

    @mail_params[:account_id] = @thread.commontable.account_id
    puts "comment created for account #{@mail_params[:account_id]}"
    mail_from_tenant(@mail_params)
  end

  protected

  def setup_variables(comment, recipients)
    @comment = comment
    @thread = @comment.thread
    @creator = @comment.creator

    @mail_params = { from: @thread.config.email_from_proc.call(@thread) }

    @recipient_emails = recipients.map do |recipient|
      Commontator.commontator_email(recipient, self)
    end

    @using_mailgun = Rails.application.config.action_mailer.delivery_method == :mailgun

    if @using_mailgun
      @recipients_header = :to
      @mailgun_recipient_variables = {}.tap do |mailgun_recipient_variables|
        @recipient_emails.each { |email| mailgun_recipient_variables[email] = {} }
      end
    else
      @recipients_header = :bcc
    end

    @mail_params[@recipients_header] = @recipient_emails

    @creator_name = Commontator.commontator_name(@creator)
    @commontable_name = Commontator.commontable_name(@thread)
    @comment_url = Commontator.comment_url(@comment, main_app)

    @mail_params[:subject] = t(
      'commontator.email.comment_created.subject',
      creator_name: @creator_name,
      commontable_name: @commontable_name,
      comment_url: @comment_url
    )
  end
end
