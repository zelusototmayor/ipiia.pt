# IPIIA production roadmap

This site is currently a static HTML/CSS/JS prototype with working frontend flows.
The next production version should add a backend while preserving the current visual layer.

## Current frontend flows

- `teste.html`
  - Collects name, email, role, company and open use case.
  - Scores 12 questions across:
    - foundations
    - prompting
    - evaluation
    - responsible use
    - automation readiness
  - Recommends:
    - `curso-fundamentos.html` for lower/intermediate readiness.
    - `curso-proficiencia.html` for high readiness with responsible-use threshold.
  - Stores last result in `localStorage` as `ipiia_last_assessment`.

- `book-call.html`
  - Simulates the custom Calendly flow.
  - Lets the user pick date, time and submit details.
  - Stores last booking in `localStorage` as `ipiia_last_booking`.

- `curso-fundamentos.html`
  - Course landing page scaffold for the beginner paid product.

- `curso-proficiencia.html`
  - Course landing page scaffold for the advanced certificate.

## Recommended backend modules

Use a backend app instead of keeping this purely static. Rails is the most natural
choice because the existing `zelusottomayor-portfolio` project already has booking,
Google Calendar and email patterns that can be reused.

### Data models

- Lead
  - name
  - email
  - role
  - company
  - source
  - consent fields

- AssessmentAttempt
  - lead_id
  - open_use_case
  - total_score
  - dimension_scores JSON
  - recommended_path
  - raw_answers JSON

- Booking
  - reuse the portfolio structure:
    - guest_name
    - guest_email
    - guest_company
    - starts_at
    - ends_at
    - timezone
    - status
    - google_event_id
    - google_meet_link
    - notes
    - confirmation_token

- Course
  - title
  - slug
  - level
  - status

- Module
  - course_id
  - title
  - position

- Lesson
  - module_id
  - title
  - content
  - video_url
  - position

- Enrollment
  - lead/user_id
  - course_id
  - stripe_checkout_session_id
  - status

- Certificate
  - enrollment_id
  - certificate_code
  - issued_at
  - score

## Integrations

- Email: use Resend or Postmark rather than domain SMTP.
- Payments: Stripe Checkout for course purchases.
- Calendar: reuse Google Calendar integration from `zelusottomayor-portfolio`.
- Analytics: keep lightweight event tracking for:
  - assessment started
  - assessment completed
  - recommended path
  - booking submitted
  - checkout started
  - course purchased

## Email triggers

- Assessment completed:
  - send result summary
  - include recommended course
  - include secondary intro-call CTA

- Booking submitted:
  - send confirmation email
  - send host notification
  - create Google Calendar event

- Course purchased:
  - send access email
  - create enrollment

- Course completed:
  - send certificate
  - send implementation/diagnostic CTA

## Advanced certificate logic

The advanced certificate should be automatic but not passive.

- Final quiz: objective, auto-graded.
- Practical challenge: open answer with fixed rubric.
- AI evaluation: score against:
  - process clarity
  - appropriate use of AI
  - data and privacy handling
  - human review points
  - measurable success criteria
  - operational usability
- Certificate threshold: only issue certificate above a defined score.

## Migration approach

1. Create Rails app or copy the portfolio Rails base into a new IPIIA app.
2. Move current HTML into Rails views/partials.
3. Convert shared nav/footer from `app.js` into Rails partials.
4. Move the assessment from frontend-only to persisted backend submission.
5. Replace `localStorage` booking with real booking model and Google Calendar sync.
6. Add Stripe Checkout for course landing pages.
7. Add course area with authentication and enrollment checks.
8. Add privacy/cookies/terms before public launch.
