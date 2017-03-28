class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_to do |format|
          format.html{
            respond_with resource, :location => after_sign_up_path_for(resource)
          }
          format.json{
            data = resource
            render :json => {
                       :status => :true,
                       :data => data
                   }

          }
        end
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_to do |format|
          format.html{
            respond_with resource, :location => after_inactive_sign_up_path_for(resource)
          }
          format.json{
            data = resource
            render :json => {
                       :status => :true,
                       :data => data
                   }
          }
        end
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.html{
          respond_with resource
        }
        format.json {
          render json: {
                     status: :false,
                     error: {
                         code: 500,
                         message: resource.errors.full_messages.join(", ").to_s
                     }
                 }
        }
      end
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = if needs_password?(resource, account_update_params)
                         resource.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
                       else
                          resource.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
                       end

    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      # respond_with resource, location: after_update_path_for(resource)
      render json: {
                 status: :true
             }
    else
      clean_up_passwords resource
      render json: {
                 status: :false,
                 error: {
                     code: 500,
                     message: resource.errors.full_messages.join(", ").to_s
                 }
             }
    end
  end

  def after_sign_up_path_for(resource)
    update_profile_users_path
  end


  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:email] || params[:password].present?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name, :phone, :gender, :dob, :postal_code)
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :postal_code, :phone, :gender, :dob)
    end
  end

end