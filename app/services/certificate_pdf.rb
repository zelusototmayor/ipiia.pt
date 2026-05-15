class CertificatePdf
  Prawn::Fonts::AFM.hide_m17n_warning = true

  def initialize(certificate)
    @certificate = certificate
    @enrollment = certificate.course_enrollment
    @learner = @enrollment.learner
    @course = @enrollment.course
  end

  def render
    Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 52) do |pdf|
      pdf.fill_color "071B34"
      pdf.fill_rectangle [ 0, pdf.bounds.top + 52 ], pdf.bounds.width + 104, pdf.bounds.height + 104

      pdf.stroke_color "D9A05B"
      pdf.line_width 2
      pdf.stroke_bounds

      pdf.fill_color "F5EFE6"
      pdf.move_down 38
      pdf.text "Instituto Português de Implementação de IA", align: :center, size: 13, character_spacing: 2
      pdf.move_down 44
      pdf.text @course.certificate_name, align: :center, size: 30, style: :bold
      pdf.move_down 32
      pdf.text "Certifica-se que", align: :center, size: 14
      pdf.move_down 12
      pdf.text @learner.name, align: :center, size: 34, style: :bold
      pdf.move_down 18
      pdf.text "concluiu com aproveitamento o curso #{@course.title}, emitido pelo Instituto Português de Implementação de IA, incluindo avaliação de conhecimentos e exercício prático aplicado.", align: :center, size: 15, leading: 5
      pdf.move_down 34
      pdf.text "Nota final: #{@certificate.final_score}%   |   Código: #{@certificate.code}", align: :center, size: 12
      pdf.move_down 10
      pdf.text "Emitido em #{@certificate.issued_at.strftime("%d/%m/%Y")}", align: :center, size: 12
      pdf.move_down 38
      pdf.text "Este certificado é emitido por entidade privada e independente. Não constitui certificação oficial, pública, regulatória ou universitária.", align: :center, size: 9
    end.render
  end
end
