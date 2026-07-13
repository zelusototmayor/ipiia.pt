(function () {
  'use strict';

  // ── Mobile nav toggle ──
  function initNavToggle() {
    const nav = document.getElementById('nav');
    const toggle = document.getElementById('nav-toggle');
    const links = document.getElementById('nav-links');
    if (!nav || !toggle || !links) return;

    function setOpen(open) {
      nav.classList.toggle('nav-open', open);
      toggle.setAttribute('aria-expanded', String(open));
      toggle.setAttribute('aria-label', open ? 'Fechar menu' : 'Abrir menu');
    }

    toggle.addEventListener('click', () => {
      setOpen(!nav.classList.contains('nav-open'));
    });

    links.addEventListener('click', (e) => {
      if (e.target.closest('a')) setOpen(false);
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') setOpen(false);
    });
  }

  // ── Sticky nav scroll shadow ──
  function initNavScroll() {
    const nav = document.getElementById('nav');
    if (!nav) return;
    const onScroll = () => nav.classList.toggle('scrolled', window.scrollY > 20);
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ── Scroll fade-in observer ──
  function initFadeIn() {
    const fadeEls = document.querySelectorAll('.fade-in');
    if (!fadeEls.length) return;
    if (!('IntersectionObserver' in window)) {
      fadeEls.forEach((el) => el.classList.add('visible'));
      return;
    }
    const obs = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          obs.unobserve(e.target);
        }
      });
    }, { threshold: 0.12 });
    fadeEls.forEach((el) => obs.observe(el));
  }

  // ── Hero network canvas ──
  function initHeroCanvas() {
    const canvas = document.getElementById('hero-canvas');
    if (!canvas || !canvas.getContext) return;
    const ctx = canvas.getContext('2d');
    const N = 84;
    const DIST = 120;
    const SPEED = 0.2;
    let w, h, nodes, raf;

    function resize() {
      w = canvas.width = canvas.offsetWidth;
      h = canvas.height = canvas.offsetHeight;
    }
    function init() {
      nodes = Array.from({ length: N }, () => ({
        x: Math.random() * w,
        y: Math.random() * h,
        vx: (Math.random() - 0.5) * SPEED,
        vy: (Math.random() - 0.5) * SPEED,
        r: Math.random() * 1.6 + 0.8,
      }));
    }
    function draw() {
      ctx.clearRect(0, 0, w, h);
      for (const n of nodes) {
        n.x += n.vx;
        n.y += n.vy;
        if (n.x < 0 || n.x > w) n.vx *= -1;
        if (n.y < 0 || n.y > h) n.vy *= -1;
      }
      for (let i = 0; i < nodes.length; i++) {
        for (let j = i + 1; j < nodes.length; j++) {
          const dx = nodes[i].x - nodes[j].x;
          const dy = nodes[i].y - nodes[j].y;
          const d = Math.sqrt(dx * dx + dy * dy);
          if (d < DIST) {
            ctx.beginPath();
            ctx.moveTo(nodes[i].x, nodes[i].y);
            ctx.lineTo(nodes[j].x, nodes[j].y);
            ctx.strokeStyle = `rgba(11,31,58,${(1 - d / DIST) * 0.1})`;
            ctx.lineWidth = 0.8;
            ctx.stroke();
          }
        }
      }
      for (const n of nodes) {
        ctx.beginPath();
        ctx.arc(n.x, n.y, n.r, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(194,90,58,0.22)';
        ctx.fill();
      }
      raf = requestAnimationFrame(draw);
    }

    resize();
    init();
    draw();
    window.addEventListener('resize', () => {
      resize();
      init();
    });
  }

  // ── Contact form ──
  function initContactForm() {
    const form = document.getElementById('contact-form');
    const success = document.getElementById('contact-success');
    const submit = document.getElementById('contact-submit');
    if (!form || !success || !submit) return;

    function csrfToken() {
      return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
    }

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      submit.disabled = true;
      const original = submit.textContent;
      submit.textContent = 'A enviar...';

      const payload = {
        contact_message: {
          name: form.elements['contact_message[name]']?.value || '',
          email: form.elements['contact_message[email]']?.value || '',
          company: form.elements['contact_message[company]']?.value || '',
          role: form.elements['contact_message[role]']?.value || '',
          message: form.elements['contact_message[message]']?.value || '',
        },
      };

      try {
        const response = await fetch(form.dataset.endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': csrfToken(),
          },
          body: JSON.stringify(payload),
        });
        const data = await response.json();
        if (!response.ok) throw new Error((data.errors || ['Não foi possível enviar o pedido.']).join(' '));

        form.hidden = true;
        success.hidden = false;
      } catch (error) {
        alert(error.message);
      } finally {
        submit.disabled = false;
        submit.textContent = original;
      }
    });
  }

  // ── Course waitlist form ──
  function initWaitlistForm() {
    const form = document.getElementById('waitlist-form');
    const success = document.getElementById('waitlist-success');
    const successMessage = document.getElementById('waitlist-success-message');
    const submit = document.getElementById('waitlist-submit');
    if (!form || !success || !submit) return;

    function csrfToken() {
      return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
    }

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      submit.disabled = true;
      const original = submit.textContent;
      submit.textContent = 'A registar...';

      const payload = {
        course_waitlist_entry: {
          name: form.elements['course_waitlist_entry[name]']?.value || '',
          email: form.elements['course_waitlist_entry[email]']?.value || '',
        },
      };

      try {
        const response = await fetch(form.dataset.endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': csrfToken(),
          },
          body: JSON.stringify(payload),
        });
        const data = await response.json();
        if (!response.ok) throw new Error((data.errors || ['Não foi possível registar o email.']).join(' '));

        if (successMessage && data.message) successMessage.textContent = data.message;
        form.hidden = true;
        success.hidden = false;
      } catch (error) {
        alert(error.message);
      } finally {
        submit.disabled = false;
        submit.textContent = original;
      }
    });
  }

  function initReadinessTest() {
    const shell = document.getElementById('ai-test-shell');
    const questionsNode = document.getElementById('ai-test-questions');
    const startPanel = document.getElementById('ai-test-start-panel');
    const card = document.getElementById('ai-test-card');
    const leadForm = document.getElementById('ai-test-lead-form');
    const complete = document.getElementById('ai-test-complete');
    const completeMessage = document.getElementById('ai-test-complete-message');
    const progressLabel = document.getElementById('ai-test-progress-label');
    const progressFill = document.getElementById('ai-test-progress-fill');
    const questionText = document.getElementById('ai-test-question-text');
    const optionsEl = document.getElementById('ai-test-options');
    const prevButton = document.getElementById('ai-test-prev');
    const nextButton = document.getElementById('ai-test-next');
    const backButton = document.getElementById('ai-test-back-to-questions');
    const submitButton = document.getElementById('ai-test-submit');
    if (!shell || !questionsNode || !startPanel || !card || !leadForm || !complete) return;

    const questions = JSON.parse(questionsNode.textContent || '[]');
    const state = { index: 0, answers: {} };

    function csrfToken() {
      return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
    }

    function showPanel(panel) {
      startPanel.hidden = panel !== 'start';
      card.hidden = panel !== 'question';
      leadForm.hidden = panel !== 'lead';
      complete.hidden = panel !== 'complete';
    }

    function renderQuestion() {
      const question = questions[state.index];
      const selected = state.answers[question.id];
      const progress = Math.round(((state.index + 1) / questions.length) * 100);

      progressLabel.textContent = `Pergunta ${state.index + 1} de ${questions.length}`;
      progressFill.style.width = `${progress}%`;
      questionText.textContent = question.text;
      prevButton.disabled = state.index === 0;
      nextButton.disabled = !selected;
      nextButton.textContent = state.index === questions.length - 1 ? 'Finalizar respostas →' : 'Seguinte →';

      optionsEl.innerHTML = question.options.map((option, optionIndex) => `
        <button class="test-option${selected === option.id ? ' is-selected' : ''}" type="button" data-option-id="${option.id}">
          <span class="test-option-letter">${String.fromCharCode(65 + optionIndex)}</span>
          <span>${option.text}</span>
        </button>
      `).join('');
    }

    function startTest() {
      showPanel('question');
      renderQuestion();
      shell.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    document.querySelectorAll('[data-ai-test-start]').forEach((button) => {
      button.addEventListener('click', startTest);
    });

    optionsEl.addEventListener('click', (e) => {
      const option = e.target.closest('[data-option-id]');
      if (!option) return;
      const question = questions[state.index];
      state.answers[question.id] = option.dataset.optionId;
      renderQuestion();
    });

    prevButton.addEventListener('click', () => {
      if (state.index === 0) return;
      state.index -= 1;
      renderQuestion();
    });

    nextButton.addEventListener('click', () => {
      const question = questions[state.index];
      if (!state.answers[question.id]) return;

      if (state.index === questions.length - 1) {
        showPanel('lead');
        leadForm.scrollIntoView({ behavior: 'smooth', block: 'start' });
        return;
      }

      state.index += 1;
      renderQuestion();
    });

    backButton.addEventListener('click', () => {
      showPanel('question');
      renderQuestion();
    });

    leadForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      submitButton.disabled = true;
      const originalText = submitButton.textContent;
      submitButton.textContent = 'A preparar relatório...';

      const payload = {
        ai_assessment: {
          name: leadForm.elements.name.value,
          email: leadForm.elements.email.value,
          role: leadForm.elements.role.value,
          company: leadForm.elements.company.value,
          use_case: leadForm.elements.use_case.value,
          answers: state.answers,
        },
      };

      try {
        const response = await fetch(shell.dataset.endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': csrfToken(),
          },
          body: JSON.stringify(payload),
        });
        const data = await response.json();
        if (!response.ok) throw new Error((data.errors || ['Não foi possível enviar o diagnóstico.']).join(' '));

        completeMessage.textContent = data.message || completeMessage.textContent;
        showPanel('complete');
        complete.scrollIntoView({ behavior: 'smooth', block: 'start' });
      } catch (error) {
        alert(error.message);
      } finally {
        submitButton.disabled = false;
        submitButton.textContent = originalText;
      }
    });

    showPanel('start');
  }

  function initBookingWidget() {
    const widget = document.getElementById('booking-widget');
    if (!widget) return;

    const daysEl = document.getElementById('booking-days');
    const slotsEl = document.getElementById('booking-slots');
    const selectedDateTitle = document.getElementById('booking-selected-date');
    const summary = document.getElementById('booking-summary');
    const dateInput = document.getElementById('booking-date');
    const timeInput = document.getElementById('booking-time');
    const state = { date: null, label: null, time: null };

    function showStep(step) {
      widget.querySelectorAll('[data-booking-step]').forEach((el) => {
        const current = Number(el.dataset.bookingStep);
        el.classList.toggle('is-active', current === step);
        el.classList.toggle('is-completed', current < step);
      });
      widget.querySelectorAll('[data-booking-panel]').forEach((el) => {
        el.hidden = Number(el.dataset.bookingPanel) !== step;
      });
    }

    function nextBusinessDays(count) {
      const days = [];
      const date = new Date();
      date.setDate(date.getDate() + 1);
      while (days.length < count) {
        const day = date.getDay();
        if (day !== 0 && day !== 6) days.push(new Date(date));
        date.setDate(date.getDate() + 1);
      }
      return days;
    }

    function formatDay(date) {
      return new Intl.DateTimeFormat('pt-PT', {
        weekday: 'short',
        day: 'numeric',
        month: 'short',
      }).format(date);
    }

    function isoDay(date) {
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${date.getFullYear()}-${month}-${day}`;
    }

    async function loadSlots(date) {
      if (!slotsEl) return;
      slotsEl.innerHTML = '<p class="booking-slots-empty">A verificar disponibilidade...</p>';
      try {
        const response = await fetch(`/bookings/availability?date=${encodeURIComponent(date)}`, {
          headers: { 'Accept': 'application/json' },
        });
        if (!response.ok) throw new Error('unavailable');
        const data = await response.json();
        const slots = data.slots || [];
        if (!slots.length) {
          slotsEl.innerHTML = '<p class="booking-slots-empty">Sem horários livres neste dia. Escolha outro dia, por favor.</p>';
          return;
        }
        slotsEl.innerHTML = slots.map((time) => `
          <button type="button" class="booking-slot" data-time="${time}">${time}</button>
        `).join('');
      } catch (error) {
        slotsEl.innerHTML = '<p class="booking-slots-empty">Não foi possível verificar a disponibilidade. Tente novamente.</p>';
      }
    }

    if (daysEl) {
      daysEl.innerHTML = nextBusinessDays(10).map((date) => `
        <button type="button" class="booking-day" data-date="${isoDay(date)}" data-label="${formatDay(date)}">
          <span>${formatDay(date).split(',')[0]}</span>
          <strong>${formatDay(date).split(',').slice(1).join(',').trim() || formatDay(date)}</strong>
        </button>
      `).join('');

      daysEl.addEventListener('click', (e) => {
        const button = e.target.closest('.booking-day');
        if (!button) return;
        state.date = button.dataset.date;
        state.label = button.dataset.label;
        if (selectedDateTitle) selectedDateTitle.textContent = state.label;
        loadSlots(state.date);
        showStep(2);
      });
    }

    if (slotsEl) {
      slotsEl.addEventListener('click', (e) => {
        const button = e.target.closest('.booking-slot');
        if (!button) return;
        state.time = button.dataset.time;
        if (dateInput) dateInput.value = state.date;
        if (timeInput) timeInput.value = state.time;
        const timezoneInput = document.getElementById('booking-timezone');
        if (timezoneInput) timezoneInput.value = Intl.DateTimeFormat().resolvedOptions().timeZone || 'Europe/Lisbon';
        if (summary) summary.textContent = `${state.label} · ${state.time}`;
        showStep(3);
      });
    }

    widget.querySelectorAll('[data-booking-back]').forEach((button) => {
      button.addEventListener('click', () => showStep(Number(button.dataset.bookingBack)));
    });
  }

  function initLucide() {
    if (window.lucide && typeof window.lucide.createIcons === 'function') {
      window.lucide.createIcons();
    }
  }

  function initCopyTemplates() {
    document.querySelectorAll('.copy-template-button').forEach((button) => {
      button.addEventListener('click', async () => {
        const template = button.parentElement?.querySelector('.copy-template');
        if (!template) return;
        await navigator.clipboard.writeText(template.value);
        const original = button.textContent;
        button.textContent = 'Copiado';
        window.setTimeout(() => { button.textContent = original; }, 1400);
      });
    });
  }

  function init() {
    initNavToggle();
    initNavScroll();
    initFadeIn();
    initHeroCanvas();
    initContactForm();
    initWaitlistForm();
    initReadinessTest();
    initBookingWidget();
    initCopyTemplates();
    initLucide();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
