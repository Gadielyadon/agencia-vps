/* app.js
   Propósito: Lógica de frontend (catálogo + calculadora).
*/

(function () {
  'use strict';

  // ---- Configuración ----
  const API_BASE = '';
  const PLACEHOLDER_IMG = 'https://via.placeholder.com/600x400?text=Sin+imagen';
  const CURRENCY = 'COP';

  // ---- Estado ----
  let productos = [];
  let categorias = [];
  let selectedCategoryId = null;

  // ---- Utils ----
  function formatCurrency(value) {
    try {
      return new Intl.NumberFormat('es-CO', {
        style: 'currency',
        currency: CURRENCY,
        maximumFractionDigits: 0
      }).format(value);
    } catch {
      return `$${value}`;
    }
  }

  function escapeHtml(str) {
    return String(str || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // ---- Categorías ----
  function renderCategoryFilters() {
    const ul = document.getElementById('categoryFilters');
    if (!ul) return;

    ul.innerHTML = '';
    const makeLi = (id, label, active) => {
      const li = document.createElement('li');
      li.className = 'nav-item';
      li.innerHTML = `
        <button class="nav-link ${active ? 'active' : ''}"
                data-role="cat-filter"
                data-id="${id ?? ''}">
          ${escapeHtml(label)}
        </button>`;
      return li;
    };

    ul.appendChild(makeLi('', 'Todos', !selectedCategoryId));
    categorias.forEach(c =>
      ul.appendChild(
        makeLi(String(c.id), c.nombre || `Cat ${c.id}`, selectedCategoryId === c.id)
      )
    );
  }

  // ---- Productos ----
  function renderProducts(list) {
    const grid = document.getElementById('productsGrid');
    if (!grid) return;

    grid.innerHTML = '';

    if (!list.length) {
      grid.innerHTML = `
        <div class="col-12">
          <div class="alert alert-light border">No hay autos para mostrar</div>
        </div>`;
      return;
    }

    list.forEach(p => {
      const col = document.createElement('div');
      col.className = 'col-12 col-sm-6 col-md-4 col-lg-3';
      col.innerHTML = `
        <div class="catalog-card">
          <div class="catalog-img-wrap">
            <img src="${p.imagen_url || PLACEHOLDER_IMG}"
                 alt="${escapeHtml(p.nombre)}">
          </div>

          <div class="catalog-body">
            <h3 class="catalog-title">${escapeHtml(p.nombre)}</h3>

            <div class="catalog-price">
              $${Number(p.precio).toLocaleString('es-CO')}
            </div>

            <p class="catalog-desc">${escapeHtml(p.descripcion || '')}</p>

            <button class="catalog-btn"
                    data-action="calc"
                    data-id="${p.id}">
              Calcular entrega
            </button>
          </div>
        </div>`;
      grid.appendChild(col);
    });
  }

  // ---- Calculadora ----
  function updateCalculator() {
    const autoSelect = document.getElementById('autoSelect');
    const slider = document.getElementById('descuentoInput');

    const precioOriginalEl = document.getElementById('precioOriginal');
    const montoDescuentoEl = document.getElementById('montoDescuento');
    const totalPagarEl = document.getElementById('totalPagar');

    const anticipoPorcentajeEl = document.getElementById('anticipoPorcentaje');
    const anticipoMontoEl = document.getElementById('anticipoMonto');

    if (!autoSelect || !slider) return;

    const selectedId = Number(autoSelect.value);
    if (!selectedId) return;

    const auto = productos.find(p => p.id === selectedId);
    if (!auto) return;

    const porcentaje = Number(slider.value);
    const anticipo = auto.precio * (porcentaje / 100);
    const saldo = auto.precio - anticipo;

    // UI superior
    anticipoPorcentajeEl.textContent = `Anticipo: ${porcentaje}%`;
    anticipoMontoEl.textContent = formatCurrency(anticipo);

    // Resultado
    precioOriginalEl.textContent = formatCurrency(auto.precio);
    montoDescuentoEl.textContent = formatCurrency(anticipo);
    totalPagarEl.textContent = formatCurrency(saldo);

    document.getElementById('resultadoCalc').style.display = 'block';
  }

  // ---- Select autos ----
  function cargarAutosSelect() {
    const autoSelect = document.getElementById('autoSelect');
    if (!autoSelect) return;

    autoSelect.innerHTML =
      '<option value="">Selecciona un auto</option>' +
      productos.map(p =>
        `<option value="${p.id}">
          ${p.nombre} - ${formatCurrency(p.precio)}
        </option>`
      ).join('');
  }

  // ---- Eventos globales ----
  document.addEventListener('click', async (ev) => {

    // Filtros
    const btn = ev.target.closest('[data-role="cat-filter"]');
    if (btn) {
      const id = btn.getAttribute('data-id');
      selectedCategoryId = id ? Number(id) : null;
      renderCategoryFilters();
      await loadAndRenderProducts();
      return;
    }

    // Calcular desde card
    const calcBtn = ev.target.closest('[data-action="calc"]');
    if (calcBtn) {
      const id = Number(calcBtn.dataset.id);
      const autoSelect = document.getElementById('autoSelect');

      autoSelect.value = id;
      document.getElementById('catalogo').style.display = 'none';
      document.getElementById('calcSection').style.display = 'block';

      updateCalculator();
    }
  });

  document.getElementById('autoSelect')?.addEventListener('change', updateCalculator);
  document.getElementById('descuentoInput')?.addEventListener('input', updateCalculator);

  // ---- Load productos ----
  async function loadAndRenderProducts() {
    const params = new URLSearchParams();
    if (selectedCategoryId) params.set('categoria_id', selectedCategoryId);

    const res = await fetch(`${API_BASE}/api/productos?${params}`);
    productos = await res.json();

    renderProducts(productos);
    cargarAutosSelect();
  }

  // ---- Init ----
  async function init() {
    const catRes = await fetch(`${API_BASE}/api/categorias`);
    categorias = (await catRes.json()).filter(c => c.activo);

    renderCategoryFilters();
    await loadAndRenderProducts();
  }

  document.addEventListener('DOMContentLoaded', init);

})();
// ---- Botón "Ver catálogo" (desde cualquier lado) ----
document.addEventListener('click', (e) => {
  const link = e.target.closest('a[href="#catalogo"]');
  if (!link) return;

  e.preventDefault();

  const catalogo = document.getElementById('catalogo');
  const calc = document.getElementById('calcSection');

  if (calc) calc.style.display = 'none';
  if (catalogo) {
    catalogo.style.display = 'block';
    catalogo.scrollIntoView({ behavior: 'smooth' });
  }
});
