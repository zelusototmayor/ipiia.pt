class ContactMessagesController < ApplicationController
  protect_from_forgery with: :exception

  def create
    @contact_message = ContactMessage.new(contact_message_params)

    if @contact_message.save
      ContactMessageMailer.host_notification(@contact_message).deliver_later
      render json: {
        ok: true,
        message: "Recebemos o seu pedido. Entraremos em contacto nas próximas 24 horas úteis."
      }, status: :created
    else
      render json: { ok: false, errors: @contact_message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :company, :role, :message)
  end
end
