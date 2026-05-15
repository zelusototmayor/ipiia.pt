class CertificatesController < ApplicationController
  def show
    @certificate = Certificate.find_by!(code: params[:code])
    @enrollment = @certificate.course_enrollment
    @learner = @enrollment.learner
    @course = @enrollment.course
    @page_title = "#{@course.certificate_name} — #{@learner.name}"

    respond_to do |format|
      format.html
      format.pdf do
        send_data CertificatePdf.new(@certificate).render,
          filename: "#{@certificate.code}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
    end
  end
end
