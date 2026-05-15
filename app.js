(function () {
  'use strict';

  // ── Shared chrome (single source of truth across pages) ──
  const NAV_HTML = `
<nav class="nav" id="nav">
  <div class="container nav-inner">
    <a href="index.html" class="nav-logo">
      <img src="assets/logo-cube.png" alt="IPIIA">
      <div class="nav-wordmark">
        <div class="nav-name">Instituto Português de Implementação de IA</div>
        <div class="nav-tagline">TESTE · FORMAÇÃO · DIAGNÓSTICO · IMPLEMENTAÇÃO</div>
      </div>
    </a>
    <div class="nav-links">
      <a class="nav-link" href="missao.html">Missão</a>
      <a class="nav-link" href="metodo.html">Método</a>
      <a class="nav-link" href="servicos.html">Serviços</a>
      <a class="nav-link" href="teste.html">Teste IA</a>
      <a class="nav-link" href="casos.html">Casos</a>
      <a class="nav-link" href="sobre.html">Sobre</a>
      <a class="btn btn-primary nav-cta" href="book-call.html">Intro call 15 min →</a>
    </div>
  </div>
</nav>`;

  const FOOTER_HTML = `
<footer class="footer">
  <div class="container footer-inner">
    <div class="footer-logo-wrap">
      <a href="index.html" class="footer-logo">
        <img src="assets/logo-cube.png" alt="IPIIA">
        <span class="footer-logo-name">Instituto Português de Implementação de IA</span>
      </a>
      <p class="footer-disclaimer">
        Marca privada e independente. Não representa qualquer entidade pública,
        governamental ou reguladora.
      </p>
      <span class="footer-copy">© 2026 IPIIA</span>
    </div>
    <div class="footer-cols">
      <div class="footer-col">
        <span class="footer-col-label">Instituto</span>
        <a href="missao.html" class="footer-link">Missão</a>
        <a href="sobre.html" class="footer-link">Sobre</a>
        <a href="book-call.html" class="footer-link">Intro call</a>
        <a href="contacto.html" class="footer-link">Contacto</a>
      </div>
      <div class="footer-col">
        <span class="footer-col-label">Serviços</span>
        <a href="metodo.html" class="footer-link">Método</a>
        <a href="servicos.html" class="footer-link">Serviços</a>
        <a href="curso-fundamentos.html" class="footer-link">Curso fundamentos</a>
        <a href="curso-proficiencia.html" class="footer-link">Certificado avançado</a>
        <a href="casos.html" class="footer-link">Casos de uso</a>
      </div>
      <div class="footer-col">
        <span class="footer-col-label">Recursos</span>
        <a href="teste.html" class="footer-link">Teste IA gratuito</a>
        <a href="mailto:contacto@ipiia.pt" class="footer-link">contacto@ipiia.pt</a>
      </div>
    </div>
  </div>
</footer>`;

  function mountChrome() {
    const navSlot = document.getElementById('nav-mount');
    if (navSlot) navSlot.outerHTML = NAV_HTML;
    const footerSlot = document.getElementById('footer-mount');
    if (footerSlot) footerSlot.outerHTML = FOOTER_HTML;

    // Active nav link based on current page
    const file = (location.pathname.split('/').pop() || 'index.html').toLowerCase();
    document.querySelectorAll('.nav-link, .nav-cta').forEach((a) => {
      const href = (a.getAttribute('href') || '').toLowerCase();
      if (href === file) a.setAttribute('aria-current', 'page');
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
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      submit.disabled = true;
      const original = submit.textContent;
      submit.textContent = 'A enviar...';
      await new Promise((r) => setTimeout(r, 900));
      form.hidden = true;
      success.hidden = false;
      submit.textContent = original;
    });
  }

  function initAssessmentForm() {
    const form = document.getElementById('assessment-form');
    const success = document.getElementById('assessment-success');
    const submit = document.getElementById('assessment-submit');
    if (!form || !success || !submit) return;
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      submit.disabled = true;
      const original = submit.textContent;
      submit.textContent = 'A registar...';
      await new Promise((r) => setTimeout(r, 900));
      form.hidden = true;
      success.hidden = false;
      submit.textContent = original;
    });
  }

  function initReadinessTest() {
    const form = document.getElementById('ai-readiness-test');
    const result = document.getElementById('assessment-result');
    const title = document.getElementById('result-title');
    const body = document.getElementById('result-body');
    const bars = document.getElementById('score-bars');
    const link = document.getElementById('result-course-link');
    if (!form || !result || !title || !body || !bars || !link) return;

    const labels = {
      foundations: 'Fundações IA',
      prompting: 'Prompting e workflow',
      evaluation: 'Avaliação de outputs',
      responsible: 'Uso responsável',
      automation: 'Prontidão para automação',
    };

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const checked = Array.from(form.querySelectorAll('input[type="radio"]:checked'));
      const totals = {};
      const max = {};

      Object.keys(labels).forEach((key) => {
        totals[key] = 0;
        max[key] = 0;
      });

      Array.from(form.querySelectorAll('input[type="radio"]')).forEach((input) => {
        const dimension = input.dataset.dimension;
        if (dimension) max[dimension] += 2 / 3;
      });

      checked.forEach((input) => {
        const dimension = input.dataset.dimension;
        if (dimension) totals[dimension] += Number(input.dataset.score || 0);
      });

      const totalScore = Object.values(totals).reduce((sum, value) => sum + value, 0);
      const totalMax = Object.values(max).reduce((sum, value) => sum + value, 0);
      const overall = Math.round((totalScore / totalMax) * 100);
      const responsible = Math.round((totals.responsible / max.responsible) * 100);

      let profile;
      if (overall >= 70 && responsible >= 50) {
        profile = {
          title: `Resultado: ${overall}% · percurso avançado recomendado`,
          body: 'Mostra maturidade suficiente para avançar para workflows, automações e desenho de agentes com guardrails. O percurso recomendado é Proficiência em Implementação de IA.',
          href: 'curso-proficiencia.html',
          cta: 'Ver certificado avançado →',
        };
      } else if (overall >= 45) {
        profile = {
          title: `Resultado: ${overall}% · percurso de fundamentos recomendado`,
          body: 'Já há base para usar IA no trabalho, mas ainda há ganhos claros em prompting, avaliação e uso responsável. O percurso recomendado é Fundamentos de IA no Trabalho.',
          href: 'curso-fundamentos.html',
          cta: 'Ver curso de fundamentos →',
        };
      } else {
        profile = {
          title: `Resultado: ${overall}% · começar pelas bases`,
          body: 'O melhor próximo passo é criar literacia prática antes de automatizar processos. Comece pelo curso de fundamentos ou por uma formação de equipa.',
          href: 'curso-fundamentos.html',
          cta: 'Ver curso de fundamentos →',
        };
      }

      title.textContent = profile.title;
      body.textContent = profile.body;
      link.href = profile.href;
      link.textContent = profile.cta;

      bars.innerHTML = Object.keys(labels).map((key) => {
        const pct = Math.round((totals[key] / max[key]) * 100);
        return `
          <div class="score-bar">
            <div class="score-bar-top">
              <span>${labels[key]}</span>
              <strong>${pct}%</strong>
            </div>
            <div class="score-track"><div class="score-fill" style="width:${pct}%"></div></div>
          </div>`;
      }).join('');

      const lead = {
        name: form.nome.value,
        email: form.email.value,
        role: form.perfil.value,
        company: form.empresa.value,
        useCase: form.caso.value,
        overall,
        dimensions: Object.fromEntries(Object.keys(labels).map((key) => [
          key,
          Math.round((totals[key] / max[key]) * 100),
        ])),
        recommendedPath: profile.href,
        createdAt: new Date().toISOString(),
      };
      window.localStorage.setItem('ipiia_last_assessment', JSON.stringify(lead));

      result.hidden = false;
      result.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
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
    const form = document.getElementById('booking-form');
    const success = document.getElementById('booking-success');
    const state = { date: null, label: null, time: null };
    const slotTimes = ['10:00', '10:30', '11:00', '14:30', '15:00', '16:00'];

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
      return date.toISOString().slice(0, 10);
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
        if (slotsEl) {
          slotsEl.innerHTML = slotTimes.map((time) => `
            <button type="button" class="booking-slot" data-time="${time}">${time}</button>
          `).join('');
        }
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
        if (summary) summary.textContent = `${state.label} · ${state.time}`;
        showStep(3);
      });
    }

    widget.querySelectorAll('[data-booking-back]').forEach((button) => {
      button.addEventListener('click', () => showStep(Number(button.dataset.bookingBack)));
    });

    if (form && success) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        const booking = {
          date: dateInput.value,
          time: timeInput.value,
          name: form.name.value,
          email: form.email.value,
          company: form.company.value,
          topic: form.topic.value,
          notes: form.notes.value,
          createdAt: new Date().toISOString(),
        };
        window.localStorage.setItem('ipiia_last_booking', JSON.stringify(booking));
        form.hidden = true;
        success.hidden = false;
      });
    }
  }

  function initLucide() {
    if (window.lucide && typeof window.lucide.createIcons === 'function') {
      window.lucide.createIcons();
    }
  }

  function init() {
    mountChrome();
    initNavScroll();
    initFadeIn();
    initHeroCanvas();
    initContactForm();
    initAssessmentForm();
    initReadinessTest();
    initBookingWidget();
    initLucide();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
